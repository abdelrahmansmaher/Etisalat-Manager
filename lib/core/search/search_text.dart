/// Builds indexable text and query terms on top of the normalizer:
/// normalize → tokenize → conservative light stemming (see
/// `docs/discovery/03-technical-architecture.md` §4.2 "Light stemmer").
///
/// Pure Dart: no Flutter imports, no dependencies.
library;

import 'arabic_normalizer.dart';
import 'query_classifier.dart';
import 'synonyms.dart';

/// Splits already-normalized text into tokens.
///
/// * Separators: whitespace and punctuation `, ; ? ! . : ( ) [ ] { } " '
///   « » / \ | < > = ~ ^ \` … - _ ‘ ’ “ ”`.
/// * Kept inside tokens: letters, digits and `* # + & %`, so USSD codes
///   (`*999#`), `+20…` and `e&` survive as single tokens.
/// * `.` and `,` between two digits are kept (`1.5`, `1,500`).
List<String> tokenize(String normalized) {
  final tokens = <String>[];
  final s = normalized;
  var start = -1;
  for (var i = 0; i < s.length; i++) {
    final c = s.codeUnitAt(i);
    var sep = _separators.contains(c);
    if (sep &&
        (c == 0x2E || c == 0x2C) &&
        i > 0 &&
        i + 1 < s.length &&
        _isDigit(s.codeUnitAt(i - 1)) &&
        _isDigit(s.codeUnitAt(i + 1))) {
      sep = false;
    }
    if (sep) {
      if (start >= 0) tokens.add(s.substring(start, i));
      start = -1;
    } else if (start < 0) {
      start = i;
    }
  }
  if (start >= 0) tokens.add(s.substring(start));
  return tokens;
}

const Set<int> _separators = {
  0x09, 0x0A, 0x0D, 0x20, // whitespace (normalized text has only 0x20)
  0x21, 0x22, 0x27, 0x28, 0x29, 0x2C, 0x2D, 0x2E, 0x2F, // ! " ' ( ) , - . /
  0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F, // : ; < = > ?
  0x5B, 0x5C, 0x5D, 0x5E, 0x5F, 0x60, // [ \ ] ^ _ `
  0x7B, 0x7C, 0x7D, 0x7E, // { | } ~
  0xAB, 0xBB, // « »
  0x2018, 0x2019, 0x201C, 0x201D, 0x2026, // ‘ ’ “ ” …
};

bool _isDigit(int c) => c >= 0x30 && c <= 0x39;

/// True if every code unit of [token] is an Arabic letter `U+0621–U+064A`.
bool isArabicWord(String token) {
  if (token.isEmpty) return false;
  for (var i = 0; i < token.length; i++) {
    final c = token.codeUnitAt(i);
    if (c < 0x0621 || c > 0x064A) return false;
  }
  return true;
}

// Longest first. Applied to normalized text, so ة is already ه.
const List<String> _prefixes = ['وال', 'بال', 'كال', 'فال', 'لل', 'ال', 'و'];
const List<String> _suffixes = [
  'ات', 'ين', 'ون', 'يه', 'ها', 'هم', 'كم', 'نا', 'ه', //
];

/// Minimum letters that must remain after removing an affix.
const int _minStem = 3;

/// Conservative light stem of a normalized Arabic [token], or the token
/// itself when nothing applies.
///
/// * Only pure Arabic-letter tokens are stemmed; Latin words, numbers and
///   codes are returned unchanged.
/// * At most one prefix, longest first: `وال بال كال فال لل ال و`.
/// * Then at most one suffix, longest first: `ات ين ون يه ها هم كم نا ه`.
/// * An affix is removed only if at least 3 letters remain.
///
/// Example: `الباقات` → `باق`, `باقه` (from `باقة`) → `باق`, so singular and
/// plural meet. The stem is indexed as an *extra*, lower-weight term; it
/// never replaces the literal word, so over-stemming (`وصول` → `صول`) only
/// adds weak recall, never removes a match.
String lightStem(String token) {
  if (!isArabicWord(token)) return token;
  var t = token;
  for (final p in _prefixes) {
    if (t.startsWith(p) && t.length - p.length >= _minStem) {
      t = t.substring(p.length);
      break;
    }
  }
  for (final s in _suffixes) {
    if (t.endsWith(s) && t.length - s.length >= _minStem) {
      t = t.substring(0, t.length - s.length);
      break;
    }
  }
  return t;
}

/// What gets stored for one searchable text (title, body, keywords…).
class IndexText {
  /// Creates an index text. Normally produced by [buildIndexText].
  const IndexText({
    required this.normalized,
    required this.tokens,
    required this.stems,
    required this.codes,
  });

  /// The full normalized text (store in `*_norm` columns / FTS).
  final String normalized;

  /// Tokens of [normalized], in order.
  final List<String> tokens;

  /// Distinct light stems that differ from their token (lower-weight
  /// lexemes).
  final List<String> stems;

  /// Canonical USSD codes and phone numbers found in the raw text (see
  /// [QueryClassifier.extractCodes]).
  final Set<String> codes;

  /// [normalized] followed by the extra stems, ready for a single FTS
  /// column when separate weighting is not available.
  String get withStems =>
      stems.isEmpty ? normalized : '$normalized ${stems.join(' ')}';
}

/// Produces the [IndexText] for [raw] content text.
IndexText buildIndexText(String raw) {
  final normalized = ArabicNormalizer.normalize(raw);
  final tokens = tokenize(normalized);
  final stems = <String>{};
  for (final t in tokens) {
    final s = lightStem(t);
    if (s != t) stems.add(s);
  }
  return IndexText(
    normalized: normalized,
    tokens: tokens,
    stems: stems.toList(growable: false),
    codes: QueryClassifier.extractCodes(raw),
  );
}

/// A query prepared for the search engine.
class SearchQuery {
  /// Creates a query. Normally produced by [buildSearchQuery].
  const SearchQuery({
    required this.classification,
    required this.tokens,
    required this.groups,
    required this.lastTokenIsPrefix,
  });

  /// Whole-query classification (code / phone / number / text). When the
  /// kind is not [QueryKind.text], run the exact lookup first.
  final QueryClassification classification;

  /// Normalized query tokens.
  final List<String> tokens;

  /// One group per token (or synonym phrase). Each group's alternatives are
  /// OR-ed; groups are AND-ed (with an OR fallback when that returns
  /// nothing). Alternatives: the literal (1.0), its light stem (0.9) when
  /// different, then synonyms with their dictionary weights.
  final List<ExpandedGroup> groups;

  /// True when the raw query does not end in whitespace, i.e. the user is
  /// still typing the last token: match it as a prefix (`token*`).
  final bool lastTokenIsPrefix;

  /// Convenience: the normalized query.
  String get normalized => classification.normalized;
}

/// Weight given to a light-stem alternative.
const double stemWeight = 0.9;

/// Prepares [raw] for searching: classify, tokenize, stem and (optionally)
/// expand with [synonyms].
SearchQuery buildSearchQuery(String raw, {SynonymExpander? synonyms}) {
  final classification = QueryClassifier.classify(raw);
  final tokens = tokenize(classification.normalized);
  final base =
      synonyms?.expand(tokens) ??
      [
        for (final t in tokens) ExpandedGroup(t, [WeightedTerm(t, 1.0)]),
      ];
  final groups = <ExpandedGroup>[];
  for (final g in base) {
    final alts = [...g.alternatives];
    final stem = lightStem(g.original);
    if (stem != g.original && !alts.any((a) => a.text == stem)) {
      alts.insert(1, WeightedTerm(stem, stemWeight));
    }
    groups.add(ExpandedGroup(g.original, alts));
  }
  final trimmedEnd = raw.isNotEmpty && raw.trimRight().length == raw.length;
  return SearchQuery(
    classification: classification,
    tokens: tokens,
    groups: groups,
    lastTokenIsPrefix: tokens.isNotEmpty && trimmedEnd,
  );
}
