import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/search/query_classifier.dart';
import 'package:knowledge_hub/core/search/search_text.dart';
import 'package:knowledge_hub/core/search/synonyms.dart';

void main() {
  group('tokenize', () {
    test('splits on whitespace and punctuation', () {
      expect(tokenize('باقه, نت; رصيد? (خط) "sim"'), [
        'باقه',
        'نت',
        'رصيد',
        'خط',
        'sim',
      ]);
    });
    test('keeps codes, plus and ampersand inside tokens', () {
      expect(tokenize('اطلب *999*1# او +201000000000 e& money'), [
        'اطلب',
        '*999*1#',
        'او',
        '+201000000000',
        'e&',
        'money',
      ]);
    });
    test('keeps decimal point and thousands comma between digits', () {
      expect(tokenize('1.5 جيجا 1,500 جنيه. نهايه,'), [
        '1.5',
        'جيجا',
        '1,500',
        'جنيه',
        'نهايه',
      ]);
    });
    test('dash splits', () {
      expect(tokenize('واي-فاي'), ['واي', 'فاي']);
    });
    test('empty', () {
      expect(tokenize(''), isEmpty);
      expect(tokenize(' , . '), isEmpty);
    });
  });

  group('lightStem', () {
    const cases = {
      'الباقات': 'باق',
      'باقه': 'باق',
      'والباقه': 'باق',
      'بالرصيد': 'رصيد',
      'للتحويل': 'تحويل',
      'فالتحويل': 'تحويل',
      'كالعاده': 'عاد',
      'المشتركين': 'مشترك',
      'المشتركون': 'مشترك',
      'رسايلها': 'رسايل',
      'خطوطهم': 'خطوط',
      'وصول': 'صول',
    };
    cases.forEach((input, expected) {
      test('$input → $expected', () => expect(lightStem(input), expected));
    });

    test('never leaves fewer than 3 letters', () {
      expect(lightStem('الخط'), 'الخط');
      expect(lightStem('للخط'), 'للخط');
      expect(lightStem('وات'), 'وات');
      expect(lightStem('خطه'), 'خطه');
      expect(lightStem('نت'), 'نت');
    });
    test('only one prefix and one suffix', () {
      expect(lightStem('والالات'), 'الات');
    });
    test('latin, numbers and codes untouched', () {
      for (final t in ['internet', 'data', '50', '*999#', 'e&', 'al3ab']) {
        expect(lightStem(t), t);
      }
    });
    test('unnormalized input is not an arabic word', () {
      expect(isArabicWord('باقة1'), isFalse);
      expect(isArabicWord(''), isFalse);
      expect(isArabicWord('باقه'), isTrue);
    });
  });

  group('buildIndexText', () {
    test('normalizes, tokenizes, stems and extracts codes', () {
      final t = buildIndexText('الباقات الجديدة — اطلب *٩٩٩# أو ٠١٠٠٠٠٠٠٠٠٠');
      expect(t.normalized, 'الباقات الجديده — اطلب *999# او 01000000000');
      expect(t.tokens, [
        'الباقات',
        'الجديده',
        '—',
        'اطلب',
        '*999#',
        'او',
        '01000000000',
      ]);
      expect(t.stems, containsAll(['باق', 'جديد']));
      expect(t.stems, isNot(contains('اطلب')));
      expect(t.codes, {'*999#', '01000000000', '201000000000'});
      expect(t.withStems, startsWith(t.normalized));
    });
    test('empty text', () {
      final t = buildIndexText('');
      expect(t.normalized, '');
      expect(t.tokens, isEmpty);
      expect(t.stems, isEmpty);
      expect(t.codes, isEmpty);
      expect(t.withStems, '');
    });
  });

  group('buildSearchQuery', () {
    test('singular query matches plural content via stem', () {
      final q = buildSearchQuery('باقة');
      final index = buildIndexText('كل الباقات');
      final queryTerms = q.groups.single.alternatives
          .map((a) => a.text)
          .toSet();
      final indexTerms = {...index.tokens, ...index.stems};
      expect(queryTerms.intersection(indexTerms), isNotEmpty);
    });

    test('stem alternative sits right after the literal', () {
      final q = buildSearchQuery('الباقات');
      expect(q.groups.single.alternatives[0].text, 'الباقات');
      expect(q.groups.single.alternatives[1].text, 'باق');
      expect(q.groups.single.alternatives[1].weight, stemWeight);
    });

    test('synonyms are attached when an expander is given', () {
      final q = buildSearchQuery('باقة نت', synonyms: SynonymExpander.seed());
      expect(q.tokens, ['باقه', 'نت']);
      expect(q.groups[1].alternatives.map((a) => a.text), contains('انترنت'));
      expect(
        q.groups[0].alternatives.map((a) => a.text),
        containsAll(['باقه', 'باق', 'bundle']),
      );
    });

    test('last token is a prefix while typing', () {
      expect(buildSearchQuery('باق').lastTokenIsPrefix, isTrue);
      expect(buildSearchQuery('باقه ').lastTokenIsPrefix, isFalse);
      expect(buildSearchQuery('').lastTokenIsPrefix, isFalse);
    });

    test('code queries carry their classification', () {
      final q = buildSearchQuery('* ٩٩٩ #');
      expect(q.classification.kind, QueryKind.ussd);
      expect(q.classification.canonical, '*999#');
    });

    test('empty query', () {
      final q = buildSearchQuery('   ');
      expect(q.classification.kind, QueryKind.empty);
      expect(q.tokens, isEmpty);
      expect(q.groups, isEmpty);
    });
  });
}
