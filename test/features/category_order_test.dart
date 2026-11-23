import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/content/content.dart';
import 'package:knowledge_hub/features/content/section_screen.dart';

import '../helpers/pump_app.dart';

ContentItem _item(String id, ItemType type, String category) => ContentItem(
  id: id,
  section: ContentSection.packages,
  title: id,
  type: type,
  category: category,
);

void main() {
  test('groups are ordered by the usefulness of their dominant type', () {
    final items = [
      _item('intro', ItemType.article, 'مقدمة القسم'),
      _item('history', ItemType.article, 'تاريخ تحريك الأسعار'),
      _item('u1', ItemType.unverified, 'بنود غير مؤكدة'),
      _item('faq', ItemType.faq, 'أسئلة شائعة'),
      _item('svc', ItemType.service, 'خدمات الرصيد'),
      _item('p1', ItemType.package, 'حكاية ميكسات'),
      _item('p2', ItemType.package, 'حكاية ميكسات'),
      _item('a1', ItemType.article, 'حكاية ميكسات'),
      _item('p3', ItemType.package, 'أنظمة الفاتورة'),
    ];
    final groups = groupByUsefulness(items, (i) => i.category);
    expect(groups.keys.toList(), [
      'حكاية ميكسات', // packages (dominant), first-seen order kept
      'أنظمة الفاتورة',
      'خدمات الرصيد', // services / codes / procedures
      'مقدمة القسم', // articles / FAQ / rules, original order
      'تاريخ تحريك الأسعار',
      'أسئلة شائعة',
      'بنود غير مؤكدة', // unconfirmed last
    ]);
    expect(groups['حكاية ميكسات']!.map((i) => i.id), ['p1', 'p2', 'a1']);
  });

  testWidgets('category capsules follow the group order', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('quick-section-packages')));
    await tester.pumpAndSettle();
    // RTL: earlier capsules sit further right.
    final xs = [
      for (final g in ['باقات تجريبية', 'باقات أخرى', 'بنود غير مؤكدة'])
        tester.getCenter(find.byKey(ValueKey('jump-$g'))).dx,
    ];
    expect(xs[0], greaterThan(xs[1]));
    expect(xs[1], greaterThan(xs[2]));
    // The first group header is the package group.
    final first = tester.getTopLeft(
      find.byKey(const ValueKey('group-باقات تجريبية')),
    );
    final count = tester.getTopLeft(
      find.byKey(const ValueKey('group-count-باقات تجريبية')),
    );
    // The count sits next to its title (not at the far edge).
    expect((first.dy - count.dy).abs(), lessThan(12));
    final titleRect = tester.getRect(
      find.byKey(const ValueKey('group-باقات تجريبية')),
    );
    final countRect = tester.getRect(
      find.byKey(const ValueKey('group-count-باقات تجريبية')),
    );
    expect((titleRect.left - countRect.right).abs(), lessThan(16));
  });
}
