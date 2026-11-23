/// Arabic/English text normalization shared by indexing, querying and the
/// offline search engine.
///
/// The exact same rules must be implemented by the server-side SQL function
/// (`app.normalize_ar`, see `docs/discovery/03-technical-architecture.md`
/// §4.2). Both implementations are tested against the shared golden fixture
/// `test/core/search/fixtures/normalizer_cases.json`; any change here must be
/// mirrored there (and followed by a full re-index).
///
/// Pure Dart: no Flutter imports, no dependencies.
library;

import 'dart:typed_data';

/// Normalizes [input] for search. Shorthand for [ArabicNormalizer.normalize].
String normalizeArabic(String input) => ArabicNormalizer.normalize(input);

/// Single-pass, table-driven Arabic search normalizer.
///
/// Rules (applied conceptually in this order; implemented as one pass over
/// the UTF-16 code units using a precomputed 64K lookup table, so the cost
/// per keystroke is O(n) with no regex):
///
/// 1. **Compatibility forms (NFKC subset).** Dart has no built-in NFKC and we
///    take no dependencies, so only the subset relevant to Arabic/English
///    input is implemented:
///    * Arabic Presentation Forms-B `U+FE70–U+FEFC` (isolated/initial/medial/
///      final letter shapes and the lam-alef ligatures `ﻻ ﻷ ﻹ ﻵ` → `لا`).
///      The spacing tashkeel forms `U+FE70, FE72, …, FE7E` become a space
///      (NFKC maps them to space + mark), the tatweel+mark forms `U+FE71,
///      FE77, …, FE7F` disappear.
///    * A few Presentation Forms-A: `ﭐ ﭑ` (alef wasla), Keheh `ﮎ–ﮑ`, Farsi
///      yeh `ﯼ–ﯿ`, `ﷲ` → `الله`, `﷼` → `ريال`.
///    * Fullwidth ASCII `U+FF01–U+FF5E` → ASCII (e.g. `＊１２３＃` → `*123#`)
///      and ideographic space `U+3000` → space.
///    Decomposed Arabic hamza/madda sequences (e.g. `ا` + `U+0654`) end up
///    identical to NFKC + rule 5/8 because the combining mark is removed by
///    rule 3 and the base letter is already the folded letter.
/// 2. **Invisible characters removed:** `U+200B–U+200F` (ZWSP, ZWNJ, ZWJ,
///    LRM, RLM), bidi embeddings `U+202A–U+202E`, isolates `U+2066–U+2069`,
///    BOM `U+FEFF`. Note: ZWSP is *removed*, not turned into a space.
/// 3. **Tashkeel removed:** `U+064B–U+065F` (fatha, damma, kasra, sukun,
///    shadda, tanween, hamza above/below, maddah…), `U+0670` (superscript /
///    dagger alef) and Quranic annotation marks `U+06D6–U+06ED`.
/// 4. **Tatweel removed:** `U+0640` (`ـ`).
/// 5. **Alef unified:** `أ إ آ ٱ` → `ا`.
/// 6. **Yeh unified:** alef maqsura `ى` → `ي`, Farsi yeh `ی` → `ي`.
/// 7. **Teh marbuta:** `ة` → `ه`.
/// 8. **Hamza on a carrier:** `ؤ` → `و`, `ئ` → `ي`. The standalone hamza
///    `ء` is **kept** (it is a real letter in words like `ماء`/`سماء` and
///    dropping it would merge unrelated words).
/// 9. **Persian keheh:** `ک` → `ك`.
/// 10. **Digits:** Arabic-Indic `٠–٩` (`U+0660–0669`) and Persian `۰–۹`
///     (`U+06F0–06F9`) → `0–9`.
/// 11. **Arabic punctuation:** `،` → `,`, `؛` → `;`, `؟` → `?`. Other
///     punctuation (`* # + & . -` …) is **kept**: USSD codes and phone
///     numbers are extracted separately by the query classifier.
/// 12. **Latin lowercase:** `A–Z` and the uppercase letters of Latin-1,
///     Latin Extended-A/B/Additional, Greek and Cyrillic are lowercased
///     (one-to-one mappings only). No accent stripping (`unaccent` is
///     optional in the spec and not applied).
/// 13. **Elongation collapsed:** a run of **3 or more** identical Arabic
///     letters (`U+0621–U+064A`, compared *after* rules 1–9) becomes one
///     letter (`عااااجل` → `عاجل`). Runs of 2 are kept (`الله`, `مدد`).
///     Never applied to digits (`10000` stays) or Latin letters.
/// 14. **Whitespace:** every run of whitespace (ASCII whitespace, NBSP,
///     `U+2000–U+200A`, `U+2028/2029`, `U+202F`, `U+205F`, `U+3000`, `U+1680`,
///     `U+0085`) becomes one ASCII space; leading/trailing whitespace is
///     trimmed.
///
/// What is deliberately **not** done:
/// * No removal of `ال` or other affixes (that is the light stemmer's job,
///   see `search_text.dart`).
/// * **Franco-Arabic (Arabizi) digits are not converted.** `ba2a` stays
///   `ba2a`; `3` is never turned into `ع`. Converting digits inside words
///   would corrupt real prices, codes and model numbers (`4g`, `5g`, `*999#`).
///   Common Arabizi terms are handled through the synonym dictionary instead.
/// * No spell correction (trigram similarity handles typos downstream).
///
/// The function is idempotent: `normalize(normalize(x)) == normalize(x)`.
abstract final class ArabicNormalizer {
  /// Table value meaning "drop this code unit".
  static const int _drop = 0;

  /// Table value meaning "replace with a multi-character string from
  /// [_multi]".
  static const int _multiMarker = 0xFFFF;

  static const int _space = 0x20;

  /// Lookup table for every UTF-16 code unit: the folded code unit, [_drop],
  /// or [_multiMarker]. Built once, lazily.
  static final Uint16List _table = _buildTable();

  /// Replacements that expand to more than one character.
  static const Map<int, String> _multi = {
    0xFEF5: 'لا', 0xFEF6: 'لا', // ﻵ ﻶ  lam + alef madda
    0xFEF7: 'لا', 0xFEF8: 'لا', // ﻷ ﻸ  lam + alef hamza above
    0xFEF9: 'لا', 0xFEFA: 'لا', // ﻹ ﻺ  lam + alef hamza below
    0xFEFB: 'لا', 0xFEFC: 'لا', // ﻻ ﻼ  lam + alef
    0xFDF2: 'الله', // ﷲ
    0xFDFC: 'ريال', // ﷼ (NFKC gives ریال with Farsi yeh, folded to ي)
  };

  /// Returns the normalized search form of [input]. See the class
  /// documentation for the full rule list. Never throws; returns `''` for
  /// empty or whitespace-only input.
  static String normalize(String input) {
    if (input.isEmpty) return '';
    final table = _table;
    final out = <int>[];
    var pendingSpace = false;
    var lastLetter = -1; // last emitted Arabic letter, -1 if none
    var run = 0; // length of the current run of [lastLetter]

    void emit(int c) {
      if (c == _space) {
        if (out.isNotEmpty) pendingSpace = true;
        lastLetter = -1;
        run = 0;
        return;
      }
      if (pendingSpace) {
        out.add(_space);
        pendingSpace = false;
      }
      if (c >= 0x0621 && c <= 0x064A) {
        if (c == lastLetter) {
          run++;
          if (run == 3) {
            // Third identical letter: collapse the run to a single letter.
            out.removeLast();
          }
          if (run >= 3) return;
        } else {
          lastLetter = c;
          run = 1;
        }
      } else {
        lastLetter = -1;
        run = 0;
      }
      out.add(c);
    }

    for (var i = 0; i < input.length; i++) {
      final c = input.codeUnitAt(i);
      final m = table[c];
      if (m == _drop) continue;
      if (m == _multiMarker) {
        final s = _multi[c];
        if (s == null) {
          emit(c);
        } else {
          for (var j = 0; j < s.length; j++) {
            emit(s.codeUnitAt(j));
          }
        }
        continue;
      }
      emit(m);
    }
    return String.fromCharCodes(out);
  }

  static Uint16List _buildTable() {
    final t = Uint16List(0x10000);
    for (var c = 0; c < t.length; c++) {
      t[c] = c;
    }
    // U+0000 maps to 0 == _drop, which is fine (NUL is never meaningful).
    t[0xFFFF] = _multiMarker; // noncharacter; passed through via emit(c).

    void drop(int from, int to) {
      for (var c = from; c <= to; c++) {
        t[c] = _drop;
      }
    }

    void map(int from, int to, int target) {
      for (var c = from; c <= to; c++) {
        t[c] = target;
      }
    }

    // (12) Lowercase. One-to-one mappings only, in scripts we may see.
    const lowerRanges = [
      [0x0041, 0x005A],
      [0x00C0, 0x024F],
      [0x0370, 0x03FF],
      [0x0400, 0x052F],
      [0x1E00, 0x1EFF],
    ];
    for (final r in lowerRanges) {
      for (var c = r[0]; c <= r[1]; c++) {
        final lower = String.fromCharCode(c).toLowerCase();
        if (lower.length == 1) t[c] = lower.codeUnitAt(0);
      }
    }

    // (1) Fullwidth ASCII → ASCII (lowercased), ideographic space.
    for (var c = 0xFF01; c <= 0xFF5E; c++) {
      t[c] = t[c - 0xFEE0];
    }

    // (14) Whitespace → space.
    for (final c in const [
      0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x20, 0x85, 0xA0, 0x1680, //
      0x2028, 0x2029, 0x202F, 0x205F, 0x3000,
    ]) {
      t[c] = _space;
    }
    map(0x2000, 0x200A, _space);

    // (2) Invisible characters.
    drop(0x200B, 0x200F);
    drop(0x202A, 0x202E);
    drop(0x2066, 0x2069);
    t[0xFEFF] = _drop;

    // (3) Tashkeel and Quranic marks, (4) tatweel.
    drop(0x064B, 0x065F);
    t[0x0670] = _drop;
    drop(0x06D6, 0x06ED);
    t[0x0640] = _drop;

    // (5)–(9) Letter folding.
    const alef = 0x0627, yeh = 0x064A, heh = 0x0647, waw = 0x0648;
    const kaf = 0x0643;
    t[0x0623] = alef; // أ
    t[0x0625] = alef; // إ
    t[0x0622] = alef; // آ
    t[0x0671] = alef; // ٱ
    t[0x0649] = yeh; // ى
    t[0x06CC] = yeh; // ی
    t[0x0629] = heh; // ة
    t[0x0624] = waw; // ؤ
    t[0x0626] = yeh; // ئ
    t[0x06A9] = kaf; // ک

    // (10) Digits.
    for (var d = 0; d < 10; d++) {
      t[0x0660 + d] = 0x30 + d;
      t[0x06F0 + d] = 0x30 + d;
    }

    // (11) Arabic punctuation.
    t[0x060C] = 0x2C; // ، → ,
    t[0x061B] = 0x3B; // ؛ → ;
    t[0x061F] = 0x3F; // ؟ → ?

    // (1) Presentation Forms-B: spacing tashkeel forms.
    for (var c = 0xFE70; c <= 0xFE7F; c++) {
      if (c == 0xFE73 || c == 0xFE75) continue; // tail fragment / unassigned
      t[c] = c.isEven ? _space : _drop;
    }
    // (1) Presentation Forms-B: letter shapes, in code point order starting
    // at U+FE80. Each entry: base letter, number of contextual forms.
    const formsB = <(int, int)>[
      (0x0621, 1), (0x0622, 2), (0x0623, 2), (0x0624, 2), (0x0625, 2), //
      (0x0626, 4), (0x0627, 2), (0x0628, 4), (0x0629, 2), (0x062A, 4),
      (0x062B, 4), (0x062C, 4), (0x062D, 4), (0x062E, 4), (0x062F, 2),
      (0x0630, 2), (0x0631, 2), (0x0632, 2), (0x0633, 4), (0x0634, 4),
      (0x0635, 4), (0x0636, 4), (0x0637, 4), (0x0638, 4), (0x0639, 4),
      (0x063A, 4), (0x0641, 4), (0x0642, 4), (0x0643, 4), (0x0644, 4),
      (0x0645, 4), (0x0646, 4), (0x0647, 4), (0x0648, 2), (0x0649, 2),
      (0x064A, 4),
    ];
    var p = 0xFE80;
    for (final (base, count) in formsB) {
      for (var k = 0; k < count; k++) {
        t[p++] = t[base]; // already folded by rules 5–9
      }
    }
    assert(p == 0xFEF5, 'Presentation Forms-B table misaligned');
    map(0xFEF5, 0xFEFC, _multiMarker); // lam-alef ligatures

    // (1) Selected Presentation Forms-A.
    map(0xFB50, 0xFB51, alef); // ٱ forms
    map(0xFB8E, 0xFB91, kaf); // keheh forms
    map(0xFBFC, 0xFBFF, yeh); // Farsi yeh forms
    t[0xFDF2] = _multiMarker;
    t[0xFDFC] = _multiMarker;

    return t;
  }
}
