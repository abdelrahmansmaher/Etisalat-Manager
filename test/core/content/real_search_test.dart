import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/content/content.dart';

/// Counter queries against the REAL bundled content.
void main() {
  late ContentLibrary library;
  late ContentSearchIndex index;

  setUpAll(() async {
    library = await ContentLoader.load(
      MemoryContentSource({
        for (final s in ContentSection.values)
          s: File(s.assetPath).readAsStringSync(),
      }),
    );
    index = ContentSearchIndex(library.all);
  });

  List<ContentItem> search(String q) => [
    for (final r in index.search(q)) r.item,
  ];

  String describe(List<ContentItem> items) =>
      items.take(6).map((i) => '${i.id} (${i.title})').join(' | ');

  for (final q in ['emerald', 'emrald', 'emerlad', 'Emerald']) {
    test('"$q" finds Emerald', () {
      final r = search(q);
      expect(r, isNotEmpty);
      for (final i in r.take(3)) {
        expect(
          '${i.title} ${i.titleEn ?? ''}'.toLowerCase(),
          contains('emerald'),
          reason: describe(r),
        );
      }
    });
  }

  test('"حكايه" ranks Hekaya packages above codes', () {
    final r = search('حكايه');
    final firstOther = r.indexWhere((i) => i.type != ItemType.package);
    final packages = r.where((i) => i.type == ItemType.package).length;
    expect(packages, greaterThan(3), reason: describe(r));
    expect(r.first.title, contains('حكاية'));
    final firstCode = r.indexWhere((i) => i.type == ItemType.code);
    if (firstCode >= 0) {
      expect(
        r.take(firstCode).where((i) => i.type == ItemType.package).length,
        greaterThanOrEqualTo(5),
        reason: describe(r),
      );
    }
    expect(firstOther == -1 || firstOther >= 5, isTrue, reason: describe(r));
  });

  for (final q in ['333', '٣٣٣', 'خدمة العملا', 'خدمة العملاء']) {
    test('"$q" puts customer service 333 first', () {
      final r = search(q);
      expect(r.first.phones, contains('333'), reason: describe(r));
      expect(r.first.type, ItemType.contact, reason: describe(r));
    });
  }

  for (final q in ['نقل ملكية', 'نقل الملكية']) {
    test('"$q" puts the ownership transfer procedure first', () {
      final r = search(q);
      expect(r.first.section, ContentSection.procedures, reason: describe(r));
      expect(r.first.title, contains('الملكية'), reason: describe(r));
    });
  }

  test('"777" puts the main wallet code first', () {
    final r = search('777');
    expect(r.first.codes.first, '*777#', reason: describe(r));
    expect(r.first.type, ItemType.code, reason: describe(r));
    expect(r.first.section, ContentSection.wallet, reason: describe(r));
  });

  for (final q in ['سيم', 'شريحة ضاعت', 'بدل فاقد']) {
    test('"$q" finds SIM replacement', () {
      final r = search(q);
      final top = r.take(q == 'سيم' ? 12 : 3);
      expect(
        top.any((i) => i.title.contains('فاقد')),
        isTrue,
        reason: describe(r),
      );
    });
  }

  test('"نت البيت" finds home internet', () {
    final r = search('نت البيت');
    expect(r, isNotEmpty);
    expect(
      r.take(5).every(
        (i) => RegExp(
          'منزلي|المنزلي|هوائي|أرضي|eHome|Home|البيت',
        ).hasMatch('${i.title} ${i.category} ${i.summary}'),
      ),
      isTrue,
      reason: describe(r),
    );
  });

  test('"رصيدي" finds the balance code', () {
    final r = search('رصيدي');
    expect(
      r.take(5).any((i) => i.codes.contains('*888#')),
      isTrue,
      reason: describe(r),
    );
  });

  test('every bundled item is confirmed', () {
    expect(
      [
        for (final i in library.all)
          if (i.status != ItemStatus.confirmed) i.id,
      ],
      isEmpty,
      reason: 'the app ships only confirmed content',
    );
  });

  test('a query takes less than 50 ms', () {
    final watch = Stopwatch();
    for (final q in [
      'emrald',
      'باقات انترنت منزلي',
      'حكايه',
      '333',
      'نقل ملكية خط متوفى',
      'زززززززز',
    ]) {
      index.search(q); // warm
      watch
        ..reset()
        ..start();
      index.search(q);
      watch.stop();
      expect(watch.elapsedMilliseconds, lessThan(50), reason: q);
    }
  });

  test('editDistance: one swap is one edit, bounded', () {
    expect(editDistance('emerlad', 'emerald', max: 2), 1);
    expect(editDistance('emrald', 'emerald', max: 2), 1);
    expect(editDistance('abc', 'abc', max: 1), 0);
    expect(editDistance('abcdef', 'xyzdef', max: 2), greaterThan(2));
  });
}
