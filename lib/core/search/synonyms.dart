/// Query-time synonym expansion (see
/// `docs/discovery/03-technical-architecture.md` §4.4).
///
/// The dictionary is data: the editor maintains it in the `search_synonyms`
/// table and it is synced to the device. This file only provides the
/// mechanism plus a tiny generic seed used until real data arrives (and in
/// tests). Pure Dart: no Flutter imports, no dependencies.
library;

import 'arabic_normalizer.dart';

/// One dictionary row: someone typing [term] should also find [canonical].
///
/// Mirrors a `search_synonyms` row. Terms may be multi-word phrases
/// (`تحويل رصيد`). Both sides are normalized with [ArabicNormalizer] when the
/// [SynonymExpander] is built, so spelling variants that the normalizer
/// already unifies (`باقة`/`باقه`, `فاتورة`/`فاتوره`) need no entry.
class SynonymEntry {
  /// Creates a dictionary row.
  const SynonymEntry(
    this.term,
    this.canonical, {
    this.bidirectional = true,
    this.weight = 0.8,
  });

  /// Builds an entry from a `search_synonyms` row / synced JSON map with the
  /// keys `term_norm`, `canonical_norm`, and optional `bidirectional`
  /// (default true) and `weight` (default 0.8).
  factory SynonymEntry.fromMap(Map<String, Object?> map) => SynonymEntry(
    map['term_norm']! as String,
    map['canonical_norm']! as String,
    bidirectional: (map['bidirectional'] as bool?) ?? true,
    weight: (map['weight'] as num?)?.toDouble() ?? 0.8,
  );

  /// What the user types.
  final String term;

  /// The word/phrase used in the content.
  final String canonical;

  /// When true, typing [canonical] also finds [term].
  final bool bidirectional;

  /// Ranking weight of matches through this synonym, below 1.0 so literal
  /// matches rank higher.
  final double weight;
}

/// A term the query should also match, with its ranking [weight].
class WeightedTerm {
  /// Creates a weighted term.
  const WeightedTerm(this.text, this.weight);

  /// Normalized term (may contain spaces for phrases).
  final String text;

  /// 1.0 for the literal text, the entry weight for synonyms.
  final double weight;

  @override
  bool operator ==(Object other) =>
      other is WeightedTerm && other.text == text && other.weight == weight;

  @override
  int get hashCode => Object.hash(text, weight);

  @override
  String toString() => '$text($weight)';
}

/// A span of consecutive query tokens and everything it may match.
class ExpandedGroup {
  /// Creates a group.
  const ExpandedGroup(this.original, this.alternatives);

  /// The literal token(s) of the query covered by this group, joined by a
  /// space.
  final String original;

  /// The literal text first (weight 1.0), then synonyms in dictionary order.
  /// Contains only the literal when no synonym applies.
  final List<WeightedTerm> alternatives;

  @override
  String toString() => 'ExpandedGroup($original → $alternatives)';
}

/// Expands normalized query tokens with dictionary synonyms.
///
/// Semantics (one hop, no transitive closure, matching how the SQL side
/// applies `search_synonyms`):
/// * `term → canonical` always.
/// * `canonical → term` additionally when the entry is bidirectional.
/// So with entries `نت→انترنت` and `داتا→انترنت`, typing `نت` expands to
/// `انترنت`, and typing `انترنت` expands to `نت` and `داتا`; `نت` does not
/// expand to `داتا` directly (content uses the canonical word).
///
/// Multi-word terms are matched greedily, longest phrase first, over the
/// token list.
class SynonymExpander {
  /// Builds the lookup from [entries]; both sides are normalized here.
  /// Entries whose sides normalize to the same text or to empty are ignored.
  SynonymExpander(Iterable<SynonymEntry> entries) {
    for (final e in entries) {
      final term = ArabicNormalizer.normalize(e.term);
      final canonical = ArabicNormalizer.normalize(e.canonical);
      if (term.isEmpty || canonical.isEmpty || term == canonical) continue;
      _add(term, canonical, e.weight);
      if (e.bidirectional) _add(canonical, term, e.weight);
    }
  }

  /// An expander built from [genericSynonymSeed].
  factory SynonymExpander.seed() => SynonymExpander(genericSynonymSeed);

  final Map<String, Map<String, double>> _map = {};
  int _maxPhraseTokens = 1;

  void _add(String from, String to, double weight) {
    final targets = _map.putIfAbsent(from, () => {});
    final existing = targets[to];
    if (existing == null || weight > existing) targets[to] = weight;
    final n = ' '.allMatches(from).length + 1;
    if (n > _maxPhraseTokens) _maxPhraseTokens = n;
  }

  /// Number of distinct terms that have at least one synonym.
  int get size => _map.length;

  /// Synonyms of a single already-normalized term or phrase (without the
  /// term itself). Empty if none.
  List<WeightedTerm> synonymsOf(String normalizedTerm) {
    final targets = _map[normalizedTerm];
    if (targets == null) return const [];
    return [for (final e in targets.entries) WeightedTerm(e.key, e.value)];
  }

  /// Groups [tokens] (already normalized, in query order) and attaches
  /// synonyms. Every token ends up in exactly one group.
  List<ExpandedGroup> expand(List<String> tokens) {
    final groups = <ExpandedGroup>[];
    var i = 0;
    while (i < tokens.length) {
      var matched = false;
      final maxN = _maxPhraseTokens < tokens.length - i
          ? _maxPhraseTokens
          : tokens.length - i;
      for (var n = maxN; n >= 1 && !matched; n--) {
        final phrase = tokens.sublist(i, i + n).join(' ');
        final syns = synonymsOf(phrase);
        if (syns.isEmpty && n > 1) continue;
        groups.add(ExpandedGroup(phrase, [WeightedTerm(phrase, 1.0), ...syns]));
        i += n;
        matched = true;
      }
    }
    return groups;
  }
}

/// A tiny, generic seed of Egyptian-dialect / telecom vocabulary.
///
/// Deliberately contains **no** operator package names, prices, codes or
/// phone numbers: those belong in editor-maintained data. The real
/// dictionary from the database replaces this seed.
const List<SynonymEntry> genericSynonymSeed = [
  // Line / SIM.
  SynonymEntry('شريحة', 'خط'),
  SynonymEntry('سيم', 'خط'),
  SynonymEntry('sim', 'خط'),
  SynonymEntry('سيم كارت', 'خط'),
  SynonymEntry('sim card', 'خط'),
  SynonymEntry('سيم', 'شريحة', weight: 0.95),
  SynonymEntry('sim', 'شريحة', weight: 0.95),
  SynonymEntry('ضاعت', 'فاقد', bidirectional: false, weight: 0.95),
  SynonymEntry('ضاع', 'فاقد', bidirectional: false, weight: 0.95),
  SynonymEntry('ضايع', 'فاقد', bidirectional: false, weight: 0.95),
  SynonymEntry('ضايعة', 'فاقد', bidirectional: false, weight: 0.95),
  SynonymEntry('مسروق', 'فاقد', bidirectional: false),
  SynonymEntry('اتسرقت', 'فاقد', bidirectional: false),
  SynonymEntry('تالفة', 'تالف', bidirectional: false),
  // Home internet.
  SynonymEntry('البيت', 'منزلي', bidirectional: false, weight: 0.95),
  SynonymEntry('بيت', 'منزلي', bidirectional: false, weight: 0.95),
  SynonymEntry('البيت', 'هوم', bidirectional: false),
  SynonymEntry('بيت', 'home', bidirectional: false),
  SynonymEntry('البيت', 'home', bidirectional: false),
  SynonymEntry('البيت', 'ارضي', bidirectional: false),
  // Internet / data.
  SynonymEntry('نت', 'انترنت'),
  SynonymEntry('إنترنت', 'انترنت'),
  SynonymEntry('داتا', 'انترنت'),
  SynonymEntry('data', 'انترنت'),
  SynonymEntry('internet', 'انترنت'),
  SynonymEntry('net', 'انترنت'),
  // Balance.
  SynonymEntry('balance', 'رصيد'),
  SynonymEntry('شحن', 'رصيد'),
  SynonymEntry('رصيدي', 'رصيد', bidirectional: false, weight: 1),
  SynonymEntry('باقتي', 'باقة', bidirectional: false, weight: 0.95),
  SynonymEntry('رقمي', 'رقم', bidirectional: false, weight: 0.95),
  SynonymEntry('خطي', 'خط', bidirectional: false, weight: 0.95),
  SynonymEntry('محفظتي', 'محفظة', bidirectional: false, weight: 0.95),
  // Bundle / package.
  SynonymEntry('bundle', 'باقة'),
  SynonymEntry('package', 'باقة'),
  SynonymEntry('بكدج', 'باقة'),
  SynonymEntry('باكدج', 'باقة'),
  // Postpaid / invoice.
  SynonymEntry('bill', 'فاتورة'),
  SynonymEntry('postpaid', 'فاتورة'),
  SynonymEntry('بيل', 'فاتورة'),
  // Prepaid / card.
  SynonymEntry('prepaid', 'كارت'),
  SynonymEntry('كرت', 'كارت'),
  // Balance transfer.
  SynonymEntry('balance transfer', 'تحويل رصيد'),
  SynonymEntry('حول رصيد', 'تحويل رصيد'),
  // Data units.
  SynonymEntry('ميجابايت', 'ميجا'),
  SynonymEntry('ميجات', 'ميجا'),
  SynonymEntry('mb', 'ميجا'),
  SynonymEntry('megabyte', 'ميجا'),
  SynonymEntry('جيجابايت', 'جيجا'),
  SynonymEntry('جيجات', 'جيجا'),
  SynonymEntry('gb', 'جيجا'),
  SynonymEntry('gigabyte', 'جيجا'),
];
