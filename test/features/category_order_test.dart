import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/content/content.dart';
import 'package:knowledge_hub/features/content/section_screen.dart';

ContentItem _item(String id, ItemType type, String category) => ContentItem(
  id: id,
  section: ContentSection.packages,
  title: id,
  type: type,
  category: category,
);

void main() {
  test('groups keep the file order; unverified groups go last', () {
    final items = [
      _item('u1', ItemType.unverified, 'بنود غير مؤكدة'),
      _item('faq', ItemType.faq, 'أسئلة سريعة'),
      _item('svc', ItemType.service, 'خدمات الرصيد'),
      _item('p1', ItemType.package, 'حكاية ميكسات'),
      _item('a1', ItemType.article, 'حكاية ميكسات'),
      _item('faq2', ItemType.faq, 'أسئلة سريعة'),
    ];
    final groups = groupInOrder(items, (i) => i.category);
    expect(groups.keys.toList(), [
      'أسئلة سريعة',
      'خدمات الرصيد',
      'حكاية ميكسات',
      'بنود غير مؤكدة',
    ]);
    expect(groups['أسئلة سريعة']!.map((i) => i.id), ['faq', 'faq2']);
    expect(groups['حكاية ميكسات']!.map((i) => i.id), ['p1', 'a1']);
  });

  test('a new line and SIM replacement come before roaming', () {
    final raw = File('assets/content/procedures.json').readAsStringSync();
    final items = ContentLoader.parseSection(
      ContentSection.procedures,
      raw,
    )!.items;
    final groups = groupInOrder(items, (i) => i.category).keys.toList();
    final roaming = groups.indexOf('التجوال الدولي');
    expect(groups.indexOf('بيع خط جديد'), lessThan(roaming));
    expect(groups.indexOf('بدل فاقد وبدل تالف'), lessThan(roaming));
  });
}
