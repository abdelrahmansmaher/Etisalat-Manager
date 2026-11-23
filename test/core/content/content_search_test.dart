import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/content/content.dart';

import '../../helpers/content_fixtures.dart';

void main() {
  late ContentSearchIndex index;
  setUpAll(() async {
    final lib = await fixtureLibrary();
    index = ContentSearchIndex(lib.all);
  });

  List<String> ids(String q, {ContentSection? section}) =>
      index.search(q, section: section).map((r) => r.item.id).toList();

  test('empty query → no results', () {
    expect(index.search(''), isEmpty);
    expect(index.search('   '), isEmpty);
  });

  test('exact code match ranks first, also with Arabic digits', () {
    expect(ids('*999#').first, 'pkg-test-alpha');
    final r = index.search('*٩٩٩#').first;
    expect(r.item.id, 'pkg-test-alpha');
    expect(r.codeMatch, isTrue);
    expect(r.snippet, contains('*999#'));
    expect(r.highlights, isNotEmpty);
  });

  test('code without # and partial code prefix', () {
    expect(ids('*555').first, 'code-test-balance');
    expect(ids('*888').first, 'pkg-test-beta');
  });

  test(
    'phone lookup: hotline, mobile in international form and Arabic digits',
    () {
      expect(ids('7777').first, 'num-test-hotline');
      expect(ids('+20 100 000 0000').first, 'num-test-mobile');
      expect(ids('٠١٠٠٠٠٠٠٠٠٠').first, 'num-test-mobile');
    },
  );

  test('title beats summary', () {
    // "ألفا" is in alpha's title and beta's summary.
    final r = ids('ألفا');
    expect(r, contains('pkg-test-beta'));
    expect(r.indexOf('pkg-test-alpha'), lessThan(r.indexOf('pkg-test-beta')));
  });

  test('Arabic spelling variants normalize (hamza, ta marbuta)', () {
    expect(ids('الفا'), contains('pkg-test-alpha'));
    expect(ids('باقه بيتا').first, 'pkg-test-beta');
  });

  test('prefix while typing and stem matching', () {
    expect(ids('استبد'), contains('proc-test-replace-sim'));
    expect(ids('الباقات'), containsAll(['pkg-test-alpha', 'pkg-test-beta']));
  });

  test('tags and body are searchable', () {
    expect(ids('فلوس'), contains('code-test-balance'));
    expect(ids('هوية'), contains('proc-test-replace-sim'));
  });

  test('confirmed ranks above unconfirmed on ties', () {
    final tie = ContentSearchIndex([
      const ContentItem(
        id: 'u',
        section: ContentSection.packages,
        title: 'عرض تجريبي',
        status: ItemStatus.unconfirmed,
      ),
      const ContentItem(
        id: 'c',
        section: ContentSection.packages,
        title: 'عرض تجريبي',
        status: ItemStatus.confirmed,
      ),
    ]);
    expect(tie.search('عرض').map((r) => r.item.id), ['c', 'u']);
  });

  test('field ranking: title > tags > summary > body', () {
    final idx = ContentSearchIndex([
      const ContentItem(
        id: 'body',
        section: ContentSection.packages,
        title: 'أ',
        body: 'كلمة زمرد هنا',
      ),
      const ContentItem(
        id: 'summary',
        section: ContentSection.packages,
        title: 'ب',
        summary: 'زمرد',
      ),
      const ContentItem(
        id: 'tags',
        section: ContentSection.packages,
        title: 'ج',
        tags: ['زمرد'],
      ),
      const ContentItem(
        id: 'title',
        section: ContentSection.packages,
        title: 'باقة زمرد',
      ),
    ]);
    expect(idx.search('زمرد').map((r) => r.item.id), [
      'title',
      'tags',
      'summary',
      'body',
    ]);
  });

  test('section filter', () {
    expect(
      index
          .search('باقة', section: ContentSection.numbers)
          .every((r) => r.item.section == ContentSection.numbers),
      isTrue,
    );
    expect(ids('رصيد', section: ContentSection.numbers), isNotEmpty);
  });

  test('zero results for nonsense', () {
    expect(index.search('زززززز'), isEmpty);
  });

  test('highlights point at the matching word', () {
    // Beta mentions "ألفا" only in its summary.
    final r = index
        .search('الفا')
        .firstWhere((r) => r.item.id == 'pkg-test-beta');
    final words = [
      for (final h in r.highlights) r.snippet.substring(h.start, h.end),
    ];
    expect(words, ['ألفا']);
  });

  test('builds and searches ~1000 items fast', () {
    final items = [
      for (var i = 0; i < 1000; i++)
        ContentItem(
          id: 'i$i',
          section: ContentSection.values[i % 7],
          title: 'باقة تجريبية رقم $i',
          summary: 'ملخص وهمي للعنصر $i مع كلمات عن الإنترنت والرصيد',
          body: 'نص طويل وهمي ' * 20,
          tags: ['وسم$i', 'كارت'],
          codes: ['*${100 + i}#'],
          status: i.isEven ? ItemStatus.confirmed : ItemStatus.unconfirmed,
        ),
    ];
    final big = ContentSearchIndex(items);
    big.search('باقة'); // warm up
    final sw = Stopwatch()..start();
    for (final q in ['باقات الانترنت', 'رصيد', '*150#', 'كار']) {
      big.search(q);
    }
    sw.stop();
    expect(sw.elapsedMilliseconds / 4, lessThan(50));
    expect(big.search('*150#').first.item.id, 'i50');
  });
}
