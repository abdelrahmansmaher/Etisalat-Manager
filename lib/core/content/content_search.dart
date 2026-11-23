/// In-memory search over the bundled content.
///
/// Built once from all items with the shared search core (normalizer,
/// tokenizer, light stemmer, synonyms, query classifier). Ranking:
/// exact code/phone > title > tags/category > summary/facts > body;
/// confirmed before unconfirmed on ties.
///
/// Pure Dart (no Flutter imports).
library;

import '../search/arabic_normalizer.dart';
import '../search/query_classifier.dart';
import '../search/search_text.dart';
import '../search/synonyms.dart';
import 'content_models.dart';

/// A highlighted range in [ContentSearchResult.snippet].
typedef Highlight = ({int start, int end});

class ContentSearchResult {
  const ContentSearchResult({
    required this.item,
    required this.score,
    required this.snippet,
    this.highlights = const [],
    this.codeMatch = false,
  });

  final ContentItem item;
  final double score;
  final String snippet;
  final List<Highlight> highlights;

  /// Matched through an exact/prefix code or phone lookup.
  final bool codeMatch;
}

enum _FieldKind { title, tags, summary, body }

const _fieldWeight = {
  _FieldKind.title: 100.0,
  _FieldKind.tags: 60.0,
  _FieldKind.summary: 30.0,
  _FieldKind.body: 12.0,
};

const double _exactCodeScore = 10000;
const double _prefixCodeScore = 5000;
const double _stemQuality = 0.85;
const double _lastPrefixQuality = 0.75;
const double _prefixQuality = 0.6;
const int _snippetMax = 140;

class _Field {
  _Field(String raw) {
    final it = buildIndexText(raw);
    normalized = it.normalized;
    tokens = it.tokens.toSet();
    stems = {for (final t in tokens) lightStem(t)};
  }

  late final String normalized;
  late final Set<String> tokens;
  late final Set<String> stems;

  /// Match quality of one normalized term, 0 when absent.
  double match(
    String term,
    String stem, {
    required bool prefix,
    required bool lastPrefix,
  }) {
    if (term.contains(' ')) return normalized.contains(term) ? 1 : 0;
    if (tokens.contains(term)) return 1;
    if (stems.contains(stem)) return _stemQuality;
    if (lastPrefix || (prefix && term.length >= 3)) {
      for (final t in tokens) {
        if (t.length > term.length && t.startsWith(term)) {
          return lastPrefix ? _lastPrefixQuality : _prefixQuality;
        }
      }
    }
    return 0;
  }
}

class _Doc {
  _Doc(this.item)
    : fields = {
        _FieldKind.title: _Field('${item.title} ${item.titleEn ?? ''}'),
        _FieldKind.tags: _Field('${item.category} ${item.tags.join(' ')}'),
        _FieldKind.summary: _Field(
          [
            item.summary,
            for (final f in item.facts) '${f.label} ${f.display}',
          ].join(' \n '),
        ),
        _FieldKind.body: _Field([item.body ?? '', ...item.steps].join(' \n ')),
      },
      normalizedTitle = ArabicNormalizer.normalize(item.title),
      codeKeys = _codeKeys(item);

  final ContentItem item;
  final Map<_FieldKind, _Field> fields;
  final String normalizedTitle;
  final Set<String> codeKeys;

  static Set<String> _codeKeys(ContentItem item) {
    final out = <String>{};
    final raw = [
      ...item.codes,
      ...item.phones,
      for (final f in item.facts)
        if (f.kind == FactKind.code || f.kind == FactKind.phone) f.value,
    ];
    for (final s in raw) {
      final c = QueryClassifier.classify(s);
      if (c.canonical != null) {
        out.add(c.canonical!);
        out.addAll(c.lookupKeys);
      }
      final compact = ArabicNormalizer.normalize(s).replaceAll(' ', '');
      if (compact.isNotEmpty) out.add(compact);
    }
    return out;
  }
}

class _Scored {
  _Scored(this.doc, this.score, this.bestField, this.codeMatch);
  final _Doc doc;
  final double score;
  final _FieldKind? bestField;
  final bool codeMatch;
}

/// Search index over a set of items.
class ContentSearchIndex {
  ContentSearchIndex(Iterable<ContentItem> items, {SynonymExpander? synonyms})
    : _docs = [for (final i in items) _Doc(i)],
      _synonyms = synonyms ?? SynonymExpander.seed();

  final List<_Doc> _docs;
  final SynonymExpander _synonyms;

  int get length => _docs.length;

  /// Ranked results for [raw], optionally limited to [section].
  List<ContentSearchResult> search(
    String raw, {
    ContentSection? section,
    int limit = 100,
  }) {
    final q = buildSearchQuery(raw, synonyms: _synonyms);
    if (q.classification.kind == QueryKind.empty || q.groups.isEmpty) {
      return const [];
    }
    final docs = section == null
        ? _docs
        : [
            for (final d in _docs)
              if (d.item.section == section) d,
          ];

    final cls = q.classification;
    final codeKeys = switch (cls.kind) {
      QueryKind.ussd || QueryKind.phone => cls.lookupKeys,
      QueryKind.number => [?cls.canonical],
      _ => const <String>[],
    };
    final codePrefix =
        (cls.kind == QueryKind.ussd || cls.kind == QueryKind.phone) &&
        !cls.isComplete;

    final groupStems = [
      for (final g in q.groups)
        [for (final a in g.alternatives) lightStem(a.text)],
    ];

    List<_Scored> run({required bool requireAll}) {
      final out = <_Scored>[];
      for (final d in docs) {
        var code = 0.0;
        for (final k in codeKeys) {
          if (d.codeKeys.contains(k)) {
            code = _exactCodeScore;
            break;
          }
        }
        if (code == 0 && codePrefix) {
          outer:
          for (final k in codeKeys) {
            for (final dk in d.codeKeys) {
              if (dk.startsWith(k)) {
                code = _prefixCodeScore;
                break outer;
              }
            }
          }
        }

        var text = 0.0;
        var matched = 0;
        _FieldKind? best;
        var bestValue = 0.0;
        for (var gi = 0; gi < q.groups.length; gi++) {
          final g = q.groups[gi];
          final lastPrefix = q.lastTokenIsPrefix && gi == q.groups.length - 1;
          var groupBest = 0.0;
          _FieldKind? groupField;
          for (final entry in d.fields.entries) {
            final w = _fieldWeight[entry.key]!;
            if (w <= groupBest) continue;
            for (var ai = 0; ai < g.alternatives.length; ai++) {
              final a = g.alternatives[ai];
              final m = entry.value.match(
                a.text,
                groupStems[gi][ai],
                prefix: true,
                lastPrefix: lastPrefix && ai == 0,
              );
              final s = w * a.weight * m;
              if (s > groupBest) {
                groupBest = s;
                groupField = entry.key;
              }
            }
          }
          if (groupBest > 0) {
            matched++;
            text += groupBest;
            if (groupBest > bestValue) {
              bestValue = groupBest;
              best = groupField;
            }
          }
        }
        if (requireAll && matched < q.groups.length) text = 0;
        if (!requireAll) text *= 0.5;
        if (text > 0 && d.normalizedTitle == cls.normalized) text += 50;
        final score = code + text;
        if (score > 0) out.add(_Scored(d, score, best, code > 0));
      }
      return out;
    }

    var scored = run(requireAll: true);
    if (scored.isEmpty && q.groups.length > 1) scored = run(requireAll: false);

    scored.sort((a, b) {
      final c = b.score.compareTo(a.score);
      if (c != 0) return c;
      final sa = a.doc.item.status == ItemStatus.confirmed ? 0 : 1;
      final sb = b.doc.item.status == ItemStatus.confirmed ? 0 : 1;
      if (sa != sb) return sa - sb;
      return a.doc.item.title.compareTo(b.doc.item.title);
    });

    final hl = _Highlighter(q, codeKeys);
    return [for (final s in scored.take(limit)) _result(s, hl)];
  }

  ContentSearchResult _result(_Scored s, _Highlighter hl) {
    final item = s.doc.item;
    final factLines = [for (final f in item.facts) '${f.label}: ${f.display}'];
    final bodyLines = [
      for (final l in (item.body ?? '').split('\n'))
        if (l.trim().isNotEmpty)
          l.trim().startsWith('- ') ? l.trim().substring(2) : l.trim(),
      ...item.steps,
    ];
    final List<String> order;
    if (s.codeMatch) {
      order = [...factLines, ...item.codes, ...item.phones, item.summary];
    } else {
      order = switch (s.bestField) {
        _FieldKind.body => [...bodyLines, item.summary],
        _FieldKind.summary => [item.summary, ...factLines],
        _ => [item.summary],
      };
    }
    for (final line in order) {
      if (line.isEmpty) continue;
      final h = hl.ranges(line);
      if (h.isNotEmpty) return _truncate(s, line, h);
    }
    final fallback = item.summary.isNotEmpty ? item.summary : item.title;
    return _truncate(s, fallback, hl.ranges(fallback));
  }

  ContentSearchResult _truncate(_Scored s, String line, List<Highlight> h) {
    var text = line;
    var hs = h;
    if (text.length > _snippetMax) {
      final first = h.isEmpty ? 0 : h.first.start;
      var start = first > 40 ? first - 40 : 0;
      final end = (start + _snippetMax).clamp(0, text.length);
      if (end - start < _snippetMax) start = (end - _snippetMax).clamp(0, end);
      final prefix = start > 0 ? '…' : '';
      final suffix = end < text.length ? '…' : '';
      final shift = prefix.length - start;
      text = '$prefix${text.substring(start, end)}$suffix';
      hs = [
        for (final r in h)
          if (r.start >= start && r.end <= end)
            (start: r.start + shift, end: r.end + shift),
      ];
    }
    return ContentSearchResult(
      item: s.doc.item,
      score: s.score,
      snippet: text,
      highlights: hs,
      codeMatch: s.codeMatch,
    );
  }
}

/// Finds whole words in raw text that match the query.
class _Highlighter {
  _Highlighter(SearchQuery q, this.codeKeys) {
    for (var gi = 0; gi < q.groups.length; gi++) {
      for (final a in q.groups[gi].alternatives) {
        for (final t in a.text.split(' ')) {
          if (t.isEmpty) continue;
          terms.add(t);
          stems.add(lightStem(t));
          if (t.length >= 2) prefixes.add(t);
        }
      }
    }
  }

  final List<String> codeKeys;
  final Set<String> terms = {};
  final Set<String> stems = {};
  final Set<String> prefixes = {};
  static final RegExp _word = RegExp(r'\S+');

  List<Highlight> ranges(String text) {
    final out = <Highlight>[];
    for (final m in _word.allMatches(text)) {
      final n = ArabicNormalizer.normalize(m[0]!);
      if (n.isEmpty) continue;
      var hit = false;
      for (final k in codeKeys) {
        if (k.isNotEmpty && n.contains(k)) hit = true;
      }
      if (!hit) {
        for (final t in tokenize(n)) {
          if (terms.contains(t) || stems.contains(lightStem(t))) {
            hit = true;
            break;
          }
          for (final p in prefixes) {
            if (t.startsWith(p)) {
              hit = true;
              break;
            }
          }
          if (hit) break;
        }
      }
      if (hit) out.add((start: m.start, end: m.end));
    }
    return out;
  }
}
