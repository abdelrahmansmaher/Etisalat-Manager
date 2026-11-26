import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/content/content.dart';
import 'package:knowledge_hub/features/content/package_facts.dart';
import 'package:knowledge_hub/features/content/package_family.dart';
import 'package:knowledge_hub/features/tools/package_info.dart';
import 'package:knowledge_hub/l10n/app_localizations_ar.dart';

/// The owner's rules, checked on the REAL bundled content: only confirmed
/// items ship, references resolve, and a number shown to a customer is the
/// number the source states.
void main() {
  late List<ContentItem> items;
  final l10n = AppLocalizationsAr();

  setUpAll(() async {
    final library = await ContentLoader.load(
      MemoryContentSource({
        for (final s in ContentSection.values)
          s: File(s.assetPath).readAsStringSync(),
      }),
    );
    items = library.all.toList();
  });

  test('every bundled item is confirmed and has a source', () {
    for (final i in items) {
      expect(i.status, ItemStatus.confirmed, reason: i.id);
      expect(i.type, isNot(ItemType.unverified), reason: i.id);
      expect(i.sources, isNotEmpty, reason: i.id);
    }
  });

  test('no doubt wording and no disclaimer reaches the screen', () {
    final banned = RegExp(r'غير مؤكد|غير رسمي|متعارض|مؤكد بشكل متوسط');
    for (final i in items) {
      final text = [
        i.title,
        i.summary,
        i.body ?? '',
        ...i.steps,
        for (final f in i.facts) '${f.label} ${f.value}',
      ].join(' ');
      expect(banned.hasMatch(text), isFalse, reason: i.id);
    }
  });

  test('related ids exist; code and phone facts can be searched', () {
    final ids = {for (final i in items) i.id};
    for (final i in items) {
      for (final r in i.related) {
        expect(ids, contains(r), reason: i.id);
      }
      for (final f in i.facts) {
        if (f.kind == FactKind.code) expect(i.codes, contains(f.value));
        if (f.kind == FactKind.phone) expect(i.phones, contains(f.value));
      }
    }
  });

  test('every package price was checked on the official site', () {
    for (final i in items.where((i) => i.type == ItemType.package)) {
      expect(i.officiallyVerified, isTrue, reason: i.id);
    }
  });

  test('a package row shows the internet quota exactly as stated', () {
    var checked = 0;
    for (final i in items.where((i) => i.type == ItemType.package)) {
      final stated = PackageFacts.of(i).internetQuota;
      if (stated == null || i.quotaGb == null) continue;
      final number = RegExp(r'[\d.,]+').firstMatch(stated.value)![0]!;
      expect(
        PackageLine.of(i, l10n).details,
        contains(number),
        reason: '${i.id}: stated ${stated.display}',
      );
      expect(PackageInfo.of(i).gbText, contains(number), reason: i.id);
      checked++;
    }
    expect(checked, greaterThan(50));
  });

  test('family names are words, never data slugs', () {
    for (final i in items.where((i) => i.type == ItemType.package)) {
      expect(
        RegExp('[؀-ۿ]').hasMatch(familyOf(i)),
        isTrue,
        reason: '${i.id}: ${familyOf(i)}',
      );
    }
  });
}
