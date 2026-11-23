import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/search/synonyms.dart';

void main() {
  List<String> texts(List<WeightedTerm> terms) => [
    for (final t in terms) t.text,
  ];

  group('seed', () {
    final x = SynonymExpander.seed();

    test('seed contains no digits, codes or prices', () {
      for (final e in genericSynonymSeed) {
        expect(
          RegExp(r'[0-9٠-٩*#+]').hasMatch('${e.term}${e.canonical}'),
          isFalse,
          reason: '${e.term} → ${e.canonical}',
        );
      }
    });

    test('dialect term expands to the canonical word', () {
      expect(texts(x.synonymsOf('نت')), ['انترنت']);
      expect(texts(x.synonymsOf('sim')), ['خط']);
      expect(texts(x.synonymsOf('شريحه')), ['خط']);
    });

    test('canonical expands back to its terms (bidirectional)', () {
      expect(
        texts(x.synonymsOf('انترنت')),
        containsAll(['نت', 'داتا', 'data', 'internet']),
      );
      expect(texts(x.synonymsOf('باقه')), containsAll(['bundle', 'package']));
    });

    test('entries are normalized: spelling variants collapse', () {
      // 'إنترنت' normalizes to the canonical itself and is dropped.
      expect(texts(x.synonymsOf('انترنت')), isNot(contains('إنترنت')));
      // 'شريحة' was stored as 'شريحه'.
      expect(x.synonymsOf('شريحة'), isEmpty);
    });

    test('no transitive expansion', () {
      expect(texts(x.synonymsOf('نت')), isNot(contains('داتا')));
    });

    test('unknown term has no synonyms', () {
      expect(x.synonymsOf('قطه'), isEmpty);
    });

    test('synonym weight is below literal weight', () {
      expect(x.synonymsOf('نت').single.weight, lessThan(1.0));
    });
  });

  group('expand', () {
    final x = SynonymExpander.seed();

    test('each token gets a group with the literal first', () {
      final g = x.expand(['رصيد', 'قطه']);
      expect(g.length, 2);
      expect(g[0].alternatives.first, const WeightedTerm('رصيد', 1.0));
      expect(texts(g[0].alternatives), containsAll(['balance', 'شحن']));
      expect(texts(g[1].alternatives), ['قطه']);
    });

    test('multi-word phrase matched greedily', () {
      final g = x.expand(['تحويل', 'رصيد', 'نت']);
      expect(g.map((e) => e.original), ['تحويل رصيد', 'نت']);
      expect(
        texts(g[0].alternatives),
        containsAll(['تحويل رصيد', 'balance transfer']),
      );
    });

    test('latin phrase matched', () {
      final g = x.expand(['sim', 'card']);
      expect(g.single.original, 'sim card');
      expect(texts(g.single.alternatives), contains('خط'));
    });

    test('empty input', () {
      expect(x.expand(const []), isEmpty);
    });
  });

  group('data-driven dictionary', () {
    test('fromMap reads a search_synonyms row', () {
      final e = SynonymEntry.fromMap({
        'term_norm': 'نمره',
        'canonical_norm': 'رقم',
        'bidirectional': false,
        'weight': 0.7,
      });
      final x = SynonymExpander([e]);
      expect(x.synonymsOf('نمره'), [const WeightedTerm('رقم', 0.7)]);
      expect(x.synonymsOf('رقم'), isEmpty);
    });

    test('fromMap defaults', () {
      final e = SynonymEntry.fromMap({'term_norm': 'a', 'canonical_norm': 'b'});
      expect(e.bidirectional, isTrue);
      expect(e.weight, 0.8);
    });

    test('duplicate pairs keep the highest weight', () {
      final x = SynonymExpander(const [
        SynonymEntry('a', 'b', weight: 0.5),
        SynonymEntry('a', 'b', weight: 0.9),
      ]);
      expect(x.synonymsOf('a'), [const WeightedTerm('b', 0.9)]);
    });

    test('empty or self-referencing entries are ignored', () {
      final x = SynonymExpander(const [
        SynonymEntry('', 'b'),
        SynonymEntry('باقة', 'باقه'),
      ]);
      expect(x.size, 0);
    });
  });
}
