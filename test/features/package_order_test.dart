import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/content/content.dart';
import 'package:knowledge_hub/features/content/package_facts.dart';
import 'package:knowledge_hub/features/content/section_screen.dart';

/// Runs on the REAL bundled content: every group a user can open must list
/// its packages from cheapest to most expensive.
void main() {
  List<ContentItem> load(ContentSection s) {
    final j = jsonDecode(
      File('assets/content/${s.key}.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    return [
      for (final e in j['items'] as List)
        ContentItem.fromJson(e as Map<String, dynamic>, s),
    ];
  }

  test('firstNumber reads the leading price', () {
    expect(firstNumber('1,250 ج بدل 2,500'), 1250);
    expect(firstNumber('4.5'), 4.5);
    expect(firstNumber('–'), isNull);
  });

  for (final s in ContentSection.values) {
    test('${s.key}: packages are ascending in every group', () {
      final groups = groupInOrder(load(s), (i) => i.category);
      groups.forEach((name, items) {
        final prices = [
          for (final i in items)
            if (i.type == ItemType.package) ?packageSortPrice(i),
        ];
        expect(prices, [...prices]..sort(), reason: name);
      });
    });
  }

  test('"confirmed on the official site" requires a dated check', () {
    for (final s in ContentSection.values) {
      for (final i in load(s).where((i) => i.officiallyVerified)) {
        expect(i.sources.any((x) => x.checkedAt != null), isTrue, reason: i.id);
      }
    }
  });
}
