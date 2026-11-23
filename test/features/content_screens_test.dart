import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/theme/app_icons.dart';
import 'package:knowledge_hub/core/content/content.dart';
import 'package:knowledge_hub/core/widgets/ltr_text.dart';
import 'package:knowledge_hub/core/widgets/trust/trust.dart';
import 'package:knowledge_hub/features/content/item_detail_screen.dart';
import 'package:knowledge_hub/features/content/review_screen.dart';
import 'package:knowledge_hub/features/content/section_screen.dart';

import '../helpers/pump_app.dart';

/// The visible vertical list (skips preloaded tabs and horizontal strips).
Finder get mainScroll => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .hitTestable()
    .first;

/// Scrolls [target] into view and aligns it near the top so taps land.
Future<void> reveal(
  WidgetTester tester,
  Finder target, {
  double delta = 200,
}) async {
  await tester.scrollUntilVisible(target, delta, scrollable: mainScroll);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

void main() {
  Future<void> openSection(WidgetTester tester, String key) async {
    final card = find.byKey(ValueKey('section-card-$key'));
    await reveal(tester, card);
    await tester.tap(card);
    await tester.pumpAndSettle();
  }

  Future<void> openItem(WidgetTester tester, String id) async {
    final row = find.byKey(ValueKey('item-row-$id'));
    await reveal(tester, row, delta: 200);
    await tester.tap(row);
    await tester.pumpAndSettle();
  }

  group('Home', () {
    testWidgets('section cards show counts, strip and as-of', (tester) async {
      await pumpApp(tester);
      expect(find.byKey(const ValueKey('must-know-strip')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('must-know-num-test-hotline')),
        findsOneWidget,
      );
      await reveal(
        tester,
        find.byKey(const ValueKey('section-card-packages')),
        delta: 200,
      );
      expect(find.text('5 بنود'), findsOneWidget); // packages
      await reveal(
        tester,
        find.byKey(const ValueKey('content-as-of')),
        delta: 200,
      );
      expect(find.textContaining('1 مارس 2026'), findsOneWidget);
    });

    testWidgets('quick strip opens the contact detail', (tester) async {
      await pumpApp(tester);
      final tile = find.byKey(const ValueKey('must-know-num-test-hotline'));
      await reveal(tester, tile, delta: 200);
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(find.byType(ItemDetailScreen), findsOneWidget);
      // Large title + the (hidden until scrolled) app-bar title.
      expect(find.text('خدمة العملاء التجريبية'), findsWidgets);
    });
  });

  group('Section screen', () {
    testWidgets('groups by category, status pills, unverified last, filters', (
      tester,
    ) async {
      await pumpApp(tester);
      await openSection(tester, 'packages');
      expect(find.byType(SectionScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('group-باقات تجريبية')), findsOneWidget);
      // Jump-to-category capsules, one per group.
      expect(find.byKey(const ValueKey('category-capsules')), findsOneWidget);
      expect(find.byKey(const ValueKey('jump-باقات أخرى')), findsOneWidget);
      expect(find.byKey(const ValueKey('status-confirmed')), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data == 'مؤكد حسب الدليل' ||
                  w.data == 'مؤكد من الموقع الرسمي'),
        ),
        findsWidgets,
      );
      expect(find.text('غير مؤكد — راجع داخليًا'), findsWidgets);

      // Unverified group header is after the others.
      await reveal(
        tester,
        find.byKey(const ValueKey('group-بنود غير مؤكدة')),
        delta: 200,
      );
      final unverifiedY = tester.getTopLeft(find.text('بند للمراجعة')).dy;
      await reveal(tester, find.text('باقة جاما'), delta: -200);
      expect(
        tester.getTopLeft(find.text('باقة جاما')).dy,
        lessThan(unverifiedY),
      );

      // Filter: confirmed only.
      await reveal(
        tester,
        find.byKey(const ValueKey('filter-confirmed')),
        delta: -300,
      );
      await tester.tap(find.byKey(const ValueKey('filter-confirmed')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('item-row-pkg-test-alpha')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('item-row-pkg-test-beta')),
        findsNothing,
      );
      await tester.tap(find.byKey(const ValueKey('filter-unconfirmed')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('item-row-pkg-test-alpha')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('item-row-pkg-test-beta')),
        findsOneWidget,
      );
    });

    testWidgets('empty section shows empty state', (tester) async {
      await pumpApp(tester);
      await openSection(tester, 'company');
      expect(find.text('لا يوجد محتوى في هذا القسم بعد'), findsOneWidget);
    });

    testWidgets('numbers section rows expose copyable codes', (tester) async {
      await pumpApp(tester);
      await openSection(tester, 'numbers');
      expect(find.byType(CodeText), findsWidgets);
      expect(find.byIcon(AppIcons.copy), findsWidgets);
    });
  });

  group('Item detail', () {
    testWidgets('answer card, facts, body, sources, pages, related', (
      tester,
    ) async {
      await pumpApp(tester);
      await openSection(tester, 'packages');
      await openItem(tester, 'pkg-test-alpha');
      expect(find.byType(ItemDetailScreen), findsOneWidget);
      // type == package → dedicated package layout.
      expect(find.byKey(const ValueKey('package-hero')), findsOneWidget);
      expect(find.byKey(const ValueKey('answer-card')), findsNothing);
      expect(find.byKey(const ValueKey('package-metrics')), findsOneWidget);
      expect(find.byKey(const ValueKey('package-code')), findsOneWidget);
      expect(find.byKey(const ValueKey('conflict-banner')), findsNothing);
      expect(find.byKey(const ValueKey('unconfirmed-banner')), findsNothing);
      for (final k in ['facts-table', 'item-body', 'pdf-pages']) {
        await reveal(tester, find.byKey(ValueKey(k)), delta: 200);
        if (k == 'facts-table') expect(find.byType(CodeText), findsWidgets);
      }
      expect(find.text('من الدليل صفحة 7'), findsOneWidget);
      expect(find.byType(SourceBadge), findsNWidgets(2));
      expect(find.text('https://example.com/alpha'), findsOneWidget);
      await reveal(
        tester,
        find.byKey(const ValueKey('item-row-pkg-test-beta')),
        delta: 200,
      );
    });

    testWidgets('unconfirmed item shows amber banner with note', (
      tester,
    ) async {
      await pumpApp(tester);
      await openSection(tester, 'packages');
      await openItem(tester, 'pkg-test-beta');
      expect(find.byKey(const ValueKey('unconfirmed-banner')), findsOneWidget);
      expect(find.text('غير مؤكد في الدليل الوهمي'), findsOneWidget);
    });

    testWidgets('conflict item shows ConflictBanner with both values', (
      tester,
    ) async {
      await pumpApp(tester);
      await openSection(tester, 'packages');
      await openItem(tester, 'pkg-test-gamma');
      expect(find.byType(ConflictBanner), findsOneWidget);
      expect(find.text('33 ج'), findsOneWidget);
      expect(find.text('34 ج'), findsOneWidget);
    });

    testWidgets('steps checklist toggles', (tester) async {
      await pumpApp(tester);
      await openSection(tester, 'procedures');
      await openItem(tester, 'proc-test-replace-sim');
      // Non-package items keep the generic Answer Card layout.
      expect(find.byKey(const ValueKey('answer-card')), findsOneWidget);
      expect(find.byKey(const ValueKey('package-hero')), findsNothing);
      final step = find.byKey(const ValueKey('step-0'));
      await reveal(tester, step, delta: 200);
      await tester.tap(step);
      await tester.pumpAndSettle();
      expect(tester.widget<CheckboxListTile>(step).value, isTrue);
    });

    testWidgets('swipe back / back button returns to section', (tester) async {
      await pumpApp(tester);
      await openSection(tester, 'packages');
      await openItem(tester, 'pkg-test-alpha');
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(ItemDetailScreen), findsNothing);
      expect(find.byType(SectionScreen), findsOneWidget);
    });
  });

  group('Search', () {
    Future<void> type(WidgetTester tester, String q) async {
      await tester.enterText(find.byKey(const ValueKey('search-field')), q);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
    }

    testWidgets('instant results, code in Arabic digits, open detail', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.byKey(const ValueKey('nav-2')));
      await tester.pumpAndSettle();
      await type(tester, '*٩٩٩#');
      expect(
        find.byKey(const ValueKey('item-row-pkg-test-alpha')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('search-count')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('item-row-pkg-test-alpha')));
      await tester.pumpAndSettle();
      expect(find.byType(ItemDetailScreen), findsOneWidget);
    });

    testWidgets('zero-result state and section filter', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byKey(const ValueKey('nav-2')));
      await tester.pumpAndSettle();
      await type(tester, 'زززززز');
      expect(find.byKey(const ValueKey('search-empty')), findsOneWidget);

      await type(tester, 'رصيد');
      expect(
        find.byKey(const ValueKey('item-row-code-test-balance')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('search-filter-packages')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('item-row-code-test-balance')),
        findsNothing,
      );
    });
  });

  testWidgets('Training review entry lists unconfirmed items', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('nav-3')));
    await tester.pumpAndSettle();
    expect(find.text('4 بنود تحتاج مراجعة داخلية'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('training-review-entry')));
    await tester.pumpAndSettle();
    expect(find.byType(ReviewScreen), findsOneWidget);
    expect(
      find.byKey(const ValueKey('item-row-pkg-test-beta')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('item-row-pkg-test-alpha')), findsNothing);
  });

  testWidgets('works with no content at all', (tester) async {
    await pumpApp(tester, content: const MemoryContentSource({}));
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('must-know-strip')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('nav-2')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('search-field')), 'x');
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('search-empty')), findsOneWidget);
  });
}
