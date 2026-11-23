/// Detects whether a search query is a USSD code, a phone number, a
/// price-like number or free text, and produces canonical keys for exact
/// lookup (see `docs/discovery/03-technical-architecture.md` §4.5).
///
/// Pure Dart: no Flutter imports, no dependencies.
library;

import 'arabic_normalizer.dart';

/// The kind of a whole search query.
enum QueryKind {
  /// Empty or whitespace-only input.
  empty,

  /// A USSD / MMI code such as `*999#`, `#999#` or `*999*1#`.
  ussd,

  /// A phone number: mobile, landline, international, a short (hotline)
  /// number, or a partially typed mobile/landline number.
  phone,

  /// A price-like amount: a number with a currency marker, a decimal
  /// number, or a bare number that is not a phone/short number.
  number,

  /// Anything else; goes to full-text search.
  text,
}

/// Sub-type of a [QueryKind.phone] query.
enum PhoneType {
  /// Egyptian mobile: `01` + 9 digits (11 digits total, local form).
  mobile,

  /// Egyptian landline: `0` (not `01`) + 8–9 digits (9–10 digits total).
  landline,

  /// A 3–5 digit number with no leading zero (hotline / short code). Also
  /// plausibly a price, so [QueryClassification.number] is set too.
  shortNumber,

  /// A number written with a non-Egyptian country code (`+` or `00`).
  foreign,

  /// The beginning of a mobile/landline number (starts with `0`, 3+ digits,
  /// still too short). Use [QueryClassification.lookupKeys] as prefixes.
  partial,
}

/// Result of [QueryClassifier.classify].
class QueryClassification {
  /// Creates a classification. Normally produced by
  /// [QueryClassifier.classify].
  const QueryClassification({
    required this.kind,
    required this.normalized,
    this.canonical,
    this.lookupKeys = const [],
    this.isComplete = false,
    this.phoneType,
    this.number,
    this.hasCurrency = false,
  });

  /// The detected kind.
  final QueryKind kind;

  /// The whole query passed through [ArabicNormalizer.normalize].
  final String normalized;

  /// The canonical exact-lookup form, or `null` for [QueryKind.text] /
  /// [QueryKind.empty].
  ///
  /// * USSD: digits converted, spaces removed, trailing `#` added when the
  ///   code ends in a digit (`* ١٢٣` → `*123#`).
  /// * Egyptian phone: local digits-only form (`+20 100-000-0000` →
  ///   `01000000000`).
  /// * Foreign phone: digits only including the country code.
  /// * Short/partial number: the digits as typed.
  /// * Number: the amount without thousands separators or trailing decimal
  ///   zeros (`1,500.50 ج` → `1500.5`).
  final String? canonical;

  /// All keys worth an exact (then prefix) lookup, [canonical] first.
  ///
  /// * USSD: `[canonical]`, plus the code without its trailing `#` when the
  ///   user did not type it (useful as a prefix: `*999` → `*999*1#`).
  /// * Complete Egyptian phone: `[local, international]`
  ///   (`01000000000`, `201000000000`).
  final List<String> lookupKeys;

  /// USSD: the user typed the closing `#`. Phone: the number has a full
  /// valid length (always true for [PhoneType.shortNumber]). Number: always
  /// true.
  final bool isComplete;

  /// Set only when [kind] is [QueryKind.phone].
  final PhoneType? phoneType;

  /// The numeric value (canonical string) whenever the whole query is a
  /// plain amount — for [QueryKind.number] and also for
  /// [PhoneType.shortNumber], which is ambiguous (`500` may be a hotline or
  /// a price). Callers can look it up in both places.
  final String? number;

  /// The query carried a currency marker (`جنيه`, `ج`, `ج.م`, `egp`, `le`,
  /// `£`…). Only for [QueryKind.number].
  final bool hasCurrency;

  @override
  String toString() =>
      'QueryClassification($kind, canonical: $canonical, keys: $lookupKeys, '
      'complete: $isComplete, phone: $phoneType, number: $number, '
      'currency: $hasCurrency)';
}

/// Classifies whole queries and extracts codes/numbers from free text.
///
/// All regular expressions are compiled once (static finals); the per-call
/// work is a normalization pass plus a few anchored matches.
abstract final class QueryClassifier {
  // Characters allowed between digits of a phone number in a query.
  static final RegExp _phoneSeparators = RegExp(r'[\s\-()]');

  // Compact USSD: starts with * or #, only digits/*/#, at least one digit.
  static final RegExp _ussdCompact = RegExp(r'^[*#][0-9*#]{0,30}$');

  static final RegExp _digitsOnly = RegExp(r'^\d+$');

  // Currency markers, already normalized (ة→ه, lowercase).
  static const String _currency =
      r'(?:جنيهات|جنيها|جنيه|ج\.م\.?|ج ?م|ج|egp|l\.e\.?|le|pounds?|e?£)';

  static final RegExp _amount = RegExp(
    '^(?:($_currency)\\s*)?'
    r'(\d{1,3}(?:[,٬]\d{3})+|\d+)(?:[.٫](\d+))?'
    '\\s*($_currency)?\$',
  );

  // USSD inside text: a space is tolerated right after `*` or right before
  // `*`/`#` (`* 999 #`), but not after `#`, so `*999# 5` does not glue.
  static final RegExp _ussdInText = RegExp(
    r'[*#](?:[\d*#]|(?<=\*) | (?=[*#]))*',
  );

  // Phone-like digit runs inside text: digits joined by single spaces or
  // dashes, optional leading +, not touching other digits or code symbols.
  static final RegExp _phoneInText = RegExp(
    r'(?<![\d*#+])\+?\d(?:\d|[ \-](?=\d)){2,16}(?![\d*#])',
  );

  static final RegExp _spaces = RegExp(r'\s+');

  static final RegExp _thousands = RegExp('[,٬]');

  /// Classifies the whole [raw] query.
  ///
  /// The query is first normalized with [ArabicNormalizer.normalize], so
  /// Arabic-Indic/Persian digits, fullwidth symbols and stray whitespace are
  /// handled. Detection order:
  ///
  /// 1. **USSD** – after removing spaces (and mapping the Arabic star `٭` to
  ///    `*`): starts with `*` or `#`, contains only digits/`*`/`#`, and has
  ///    at least one digit. A missing trailing `#` is tolerated
  ///    ([QueryClassification.isComplete] is then false).
  /// 2. **Phone** – after removing spaces, `-`, `(`, `)`: optional `+`
  ///    or `00` then digits only.
  ///    * `+20…` / `0020…` / `201` + 9 digits (12 digits, no plus) are
  ///      converted to the local `0…` form (a redundant `0` after `+20` is
  ///      tolerated).
  ///    * `01` + 9 digits → mobile; `1` + 9 digits → mobile missing its
  ///      leading zero (canonical gets the `0`).
  ///    * `0[2-9]` with 9–10 digits total → landline.
  ///    * starting with `0`, 3+ digits but shorter → partial.
  ///    * 3–5 digits, no leading zero → short number (also a [number]).
  ///    * other `+`-prefixed numbers → foreign.
  /// 3. **Number** – an amount with optional thousands separators (`,` or
  ///    `٬`), optional decimals (`.` or `٫`) and an optional currency marker
  ///    before or after. Digit runs too long for this (and not a phone) fall
  ///    through to text.
  /// 4. Otherwise **text**.
  static QueryClassification classify(String raw) {
    final normalized = ArabicNormalizer.normalize(raw);
    if (normalized.isEmpty) {
      return const QueryClassification(kind: QueryKind.empty, normalized: '');
    }

    final ussd = _classifyUssd(normalized);
    if (ussd != null) return ussd;

    final phone = _classifyPhone(normalized);
    if (phone != null) return phone;

    final amount = _classifyAmount(normalized);
    if (amount != null) return amount;

    return QueryClassification(kind: QueryKind.text, normalized: normalized);
  }

  /// Extracts canonical USSD codes and phone numbers found anywhere in
  /// [raw] text, for indexing into `search_documents.codes` (and for
  /// boosting free-text queries that contain a code).
  ///
  /// * USSD codes are returned in canonical form (`*999#`); a code without
  ///   its closing `#` gets one added if it ends in a digit.
  /// * Complete Egyptian mobile/landline numbers are returned in both local
  ///   (`01000000000`) and international (`201000000000`) digit forms;
  ///   foreign numbers as digits only.
  /// * Short 3–5 digit numbers are **not** returned unless
  ///   [includeShortNumbers] is true: in prose they are far more often
  ///   prices or quotas than hotlines, and an exact code match pins a result
  ///   to the top. Hotlines live in the contacts table with their own exact
  ///   key.
  static Set<String> extractCodes(
    String raw, {
    bool includeShortNumbers = false,
  }) {
    final text = ArabicNormalizer.normalize(raw).replaceAll('٭', '*');
    final out = <String>{};
    for (final m in _ussdInText.allMatches(text)) {
      final r = _classifyUssd(m[0]!);
      if (r != null) out.add(r.canonical!);
    }
    for (final m in _phoneInText.allMatches(text)) {
      final r = _classifyPhone(m[0]!);
      if (r == null) continue;
      switch (r.phoneType) {
        case PhoneType.mobile || PhoneType.landline || PhoneType.foreign:
          out.addAll(r.lookupKeys);
        case PhoneType.shortNumber when includeShortNumbers:
          out.add(r.canonical!);
        default:
          break;
      }
    }
    return out;
  }

  static QueryClassification? _classifyUssd(String normalized) {
    final compact = normalized.replaceAll(_spaces, '').replaceAll('٭', '*');
    if (!_ussdCompact.hasMatch(compact)) return null;
    if (!compact.codeUnits.any((c) => c >= 0x30 && c <= 0x39)) return null;
    final complete = compact.length > 1 && compact.endsWith('#');
    final lastIsDigit = _isDigit(compact.codeUnitAt(compact.length - 1));
    final canonical = lastIsDigit ? '$compact#' : compact;
    return QueryClassification(
      kind: QueryKind.ussd,
      normalized: normalized,
      canonical: canonical,
      lookupKeys: canonical == compact ? [canonical] : [canonical, compact],
      isComplete: complete,
    );
  }

  static QueryClassification? _classifyPhone(String normalized) {
    var s = normalized.replaceAll(_phoneSeparators, '');
    var international = false;
    if (s.startsWith('+')) {
      international = true;
      s = s.substring(1);
    } else if (s.startsWith('00') && s.length > 4) {
      international = true;
      s = s.substring(2);
    }
    if (s.isEmpty || !_digitsOnly.hasMatch(s)) return null;

    QueryClassification phone(
      PhoneType type,
      String canonical,
      List<String> keys, {
      bool complete = true,
      String? number,
    }) => QueryClassification(
      kind: QueryKind.phone,
      normalized: normalized,
      canonical: canonical,
      lookupKeys: keys,
      isComplete: complete,
      phoneType: type,
      number: number,
    );

    if (international) {
      if (s.startsWith('20') && s.length > 2) {
        final rest = s.substring(2);
        return _egyptianLocal(rest.startsWith('0') ? rest : '0$rest', phone) ??
            phone(PhoneType.partial, '0$rest', ['0$rest'], complete: false);
      }
      if (s.length < 7) return null;
      return phone(PhoneType.foreign, s, [s]);
    }

    // 20 + mobile without plus: 201XXXXXXXXX (12 digits).
    if (s.length == 12 && s.startsWith('201')) {
      return _egyptianLocal('0${s.substring(2)}', phone);
    }
    // Mobile missing its leading zero: 1XXXXXXXXX (10 digits).
    if (s.length == 10 && s.startsWith('1')) {
      return _egyptianLocal('0$s', phone);
    }
    if (s.startsWith('0')) {
      final local = _egyptianLocal(s, phone);
      if (local != null) return local;
      final maxLen = s.startsWith('01') ? 11 : 10;
      if (s.length >= 3 && s.length < maxLen) {
        return phone(PhoneType.partial, s, [s], complete: false);
      }
      return null;
    }
    if (s.length >= 3 && s.length <= 5) {
      return phone(PhoneType.shortNumber, s, [s], number: s);
    }
    return null;
  }

  /// Returns a complete mobile/landline classification for a local `0…`
  /// number, or `null` if [local] is not a complete Egyptian number.
  static QueryClassification? _egyptianLocal(
    String local,
    QueryClassification Function(PhoneType, String, List<String>) phone,
  ) {
    if (local.length < 2 || local[0] != '0') return null;
    final international = '20${local.substring(1)}';
    if (local[1] == '1') {
      return local.length == 11
          ? phone(PhoneType.mobile, local, [local, international])
          : null;
    }
    if (local.length >= 9 && local.length <= 10 && local[1] != '0') {
      return phone(PhoneType.landline, local, [local, international]);
    }
    return null;
  }

  static QueryClassification? _classifyAmount(String normalized) {
    final m = _amount.firstMatch(normalized);
    if (m == null) return null;
    final currency = m[1] != null || m[4] != null;
    final intPart = m[2]!.replaceAll(_thousands, '');
    var frac = m[3] ?? '';
    // A bare long digit run (no currency, no decimals) is not an amount.
    if (!currency && frac.isEmpty && intPart.length > 8) return null;
    while (frac.endsWith('0')) {
      frac = frac.substring(0, frac.length - 1);
    }
    final value = _stripLeadingZeros(intPart) + (frac.isEmpty ? '' : '.$frac');
    return QueryClassification(
      kind: QueryKind.number,
      normalized: normalized,
      canonical: value,
      lookupKeys: [value],
      isComplete: true,
      number: value,
      hasCurrency: currency,
    );
  }

  static String _stripLeadingZeros(String s) {
    var i = 0;
    while (i < s.length - 1 && s.codeUnitAt(i) == 0x30) {
      i++;
    }
    return s.substring(i);
  }

  static bool _isDigit(int c) => c >= 0x30 && c <= 0x39;
}
