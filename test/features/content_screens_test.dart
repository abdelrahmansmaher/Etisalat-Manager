import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_hub/core/content/content.dart';
import 'package:knowledge_hub/core/theme/app_icons.dart';
import 'package:knowledge_hub/core/widgets/ltr_text.dart';
import 'package:knowledge_hub/features/content/content_widgets.dart';
import 'package:knowledge_hub/features/content/item_detail_screen.dart';
import 'package:knowledge_hub/features/content/section_screen.dart';
import 'package:knowledge_hub/features/home/home_screen.dart';
import 'package:knowledge_hub/features/packages/packages_screen.dart';

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
  await Scrollable.ensureVisible(tester.element(target), alignment: 0.3);
  await tester.pumpAndSettle();
}

void main() {
  Future<void> openItem(WidgetTester tester, String id) async {
    GoRouter.of(tester.element(find.byType(HomeScreen))).push('/item/$id');
    await tester.pumpAndSettle();
    expect(find.byType(ItemDetailScreen), findsOneWidget);
  }

  group('Home', () {
    testWidgets('hotlines, section counts and content date', (tester) async {
      await pumpApp(tester);
      expect(find.byKey(const ValueKey('must-know-strip')), findsOneWidget);
      final card = find.byKey(const ValueKey('section-card-numbers'));
      await reveal(tester, card);
      expect(
        find.descendant(of: card, matching: find.text('3')),
        findsOneWidget,
      );
      await reveal(tester, find.byKey(const ValueKey('content-as-of')));
      expect(find.textContaining('1 مارس 2026'), findsOneWidget);
    });

    testWidgets('a hotline row opens its page', (tester) async {
      await pumpApp(tester);
      final tile = find.byKey(const ValueKey('must-know-num-test-hotline'));
      await reveal(tester, tile);
      await tester.tap(
        find.descendant(
          of: tile,
          matching: find.text('خدمة العملاء التجريبية'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ItemDetailScreen), findsOneWidget);
    });

    testWidgets('the header link sits on the far edge', (tester) async {
      await pumpApp(tester);
      final link = find.text('عرض الكل');
      await reveal(tester, link);
      expect(tester.getRect(link).left, lessThan(40)); // RTL: far = left
    });
  });

  group('Section screen', () {
    testWidgets('groups rows under their category', (tester) async {
      await pumpApp(tester);
      final card = find.byKey(const ValueKey('section-card-procedures'));
      await reveal(tester, card);
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(find.byType(SectionScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('group-إجراءات الخط')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('confirmed-proc-test-replace-sim')),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(const ValueKey('item-row-proc-test-replace-sim')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(SectionScreen), findsOneWidget);
    });

    testWidgets('empty section shows empty state', (tester) async {
      await pumpApp(tester);
      GoRouter.of(tester.element(find.byType(HomeScreen)))
          .push('/section/company');
      await tester.pumpAndSettle();
      expect(find.text('لا يوجد محتوى في هذا القسم بعد'), findsOneWidget);
    });
  });

  group('Packages tab', () {
    testWidgets('only confirmed packages look confirmed', (tester) async {
      await pumpApp(tester, size: const Size(375, 900));
      await tester.tap(find.byKey(const ValueKey('nav-1')));
      await tester.pumpAndSettle();
      expect(find.byType(PackagesScreen), findsOneWidget);
      expect(
        find.byKey(const ValueKey('confirmed-pkg-test-alpha')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('confirmed-pkg-test-beta')),
        findsNothing,
      );
      // A conflicting price is never quoted.
      expect(find.byKey(const ValueKey('price-pkg-test-gamma')), findsNothing);
    });

    testWidgets('one tap copies the code without opening the page', (
      tester,
    ) async {
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pumpApp(tester, size: const Size(375, 900));
      await tester.tap(find.byKey(const ValueKey('nav-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('copy-code-pkg-test-alpha')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(copied, ['*999#']);
      expect(find.text('تم النسخ'), findsOneWidget);
      expect(find.byType(ItemDetailScreen), findsNothing);
      await tester.pumpAndSettle();
    });

    testWidgets('segments and families stay pinned while scrolling', (
      tester,
    ) async {
      await pumpApp(tester, size: const Size(360, 420));
      await tester.tap(find.byKey(const ValueKey('nav-1')));
      await tester.pumpAndSettle();
      await tester.drag(mainScroll, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('package-segments')).hitTestable(),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('package-sort')).hitTestable(),
        findsOneWidget,
      );
    });
  });

  testWidgets('codes tab: every row has its kind, value and copy', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(375, 900));
    await tester.tap(find.byKey(const ValueKey('nav-2')));
    await tester.pumpAndSettle();
    expect(find.byType(CodeRow), findsNWidgets(3));
    expect(find.byType(CodeActions), findsNWidgets(3));
    final hotline = find.byKey(const ValueKey('item-row-num-test-hotline'));
    expect(
      find.descendant(of: hotline, matching: find.byIcon(AppIcons.catHotline)),
      findsOneWidget,
    );
  });

  group('Item detail', () {
    testWidgets('package page: hero, code, notes, sources, related', (
      tester,
    ) async {
      await pumpApp(tester);
      await openItem(tester, 'pkg-test-alpha');
      expect(find.byKey(const ValueKey('package-hero')), findsOneWidget);
      expect(find.byKey(const ValueKey('answer-card')), findsNothing);
      expect(find.byKey(const ValueKey('package-code')), findsOneWidget);
      expect(find.byKey(const ValueKey('review-note')), findsNothing);
      for (final k in ['facts-table', 'item-body', 'pdf-pages']) {
        await reveal(tester, find.byKey(ValueKey(k)));
      }
      expect(find.text('من الدليل صفحة 7'), findsOneWidget);
      expect(find.text('https://example.com/alpha'), findsOneWidget);
      await reveal(
        tester,
        find.byKey(const ValueKey('item-row-pkg-test-beta')),
      );
    });

    testWidgets('an unconfirmed item says so and never looks confirmed', (
      tester,
    ) async {
      await pumpApp(tester);
      await openItem(tester, 'pkg-test-beta');
      final note = find.byKey(const ValueKey('review-note'));
      expect(note, findsOneWidget);
      expect(
        find.descendant(
          of: note,
          matching: find.textContaining('غير مؤكد في الدليل الوهمي'),
        ),
        findsOneWidget,
      );
      expect(find.text('غير مؤكد — راجع داخليًا'), findsOneWidget);
    });

    testWidgets('steps keep their place, count and reset', (tester) async {
      await pumpApp(tester);
      await openItem(tester, 'proc-test-replace-sim');
      expect(find.byKey(const ValueKey('answer-card')), findsOneWidget);
      expect(find.byKey(const ValueKey('package-hero')), findsNothing);
      expect(find.byKey(const ValueKey('steps-progress')), findsNothing);

      final step = find.byKey(const ValueKey('step-0'));
      await reveal(tester, step);
      await tester.tap(step);
      await tester.pumpAndSettle();
      expect(tester.widget<CheckboxListTile>(step).value, isTrue);
      expect(find.text('1 من 3'), findsOneWidget);

      // Leaving to look something up does not lose the place.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await openItem(tester, 'proc-test-replace-sim');
      await reveal(tester, step);
      expect(tester.widget<CheckboxListTile>(step).value, isTrue);

      await tester.tap(find.byKey(const ValueKey('steps-reset')));
      await tester.pumpAndSettle();
      expect(tester.widget<CheckboxListTile>(step).value, isFalse);
      expect(find.byKey(const ValueKey('steps-progress')), findsNothing);
    });

    testWidgets('a missing item says so', (tester) async {
      await pumpApp(tester);
      await openItem(tester, 'nope');
      expect(find.text('البند غير موجود'), findsWidgets);
    });
  });

  group('Search', () {
    Future<void> open(WidgetTester tester) async {
      await tester.tap(find.byKey(const ValueKey('search-pill')).hitTestable());
      await tester.pumpAndSettle();
    }

    Future<void> type(WidgetTester tester, String q) async {
      await tester.enterText(find.byKey(const ValueKey('search-field')), q);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
    }

    testWidgets('instant results, code in Arabic digits, open detail', (
      tester,
    ) async {
      await pumpApp(tester);
      await open(tester);
      await type(tester, '*٩٩٩#');
      final row = find.byKey(const ValueKey('item-row-pkg-test-alpha'));
      expect(row, findsOneWidget);
      expect(find.byKey(const ValueKey('search-count')), findsOneWidget);
      await tester.tap(find.text('باقة ألفا التجريبية'));
      await tester.pumpAndSettle();
      expect(find.byType(ItemDetailScreen), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('quick searches only offer what the content has', (
      tester,
    ) async {
      await pumpApp(tester);
      await open(tester);
      final quick = find.byKey(const ValueKey('quick-search-خدمة العملاء'));
      expect(quick, findsOneWidget);
      expect(find.byKey(const ValueKey('quick-search-إيميرالد')), findsNothing);
      await tester.tap(quick);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('item-row-num-test-hotline')),
        findsOneWidget,
      );
    });

    testWidgets('no result is never a dead end', (tester) async {
      await pumpApp(tester);
      await open(tester);
      await type(tester, 'زززززز');
      expect(find.byKey(const ValueKey('search-empty')), findsOneWidget);
      expect(find.byKey(const ValueKey('search-add-item')), findsOneWidget);

      // A section filter that hides everything offers all sections.
      await type(tester, 'رصيد');
      expect(
        find.byKey(const ValueKey('item-row-code-test-balance')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('search-filters')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('search-filter-packages')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('item-row-code-test-balance')),
        findsNothing,
      );
      await tester.tap(find.byKey(const ValueKey('search-all-sections')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('item-row-code-test-balance')),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 2));
    });
  });

  testWidgets('works with no content at all', (tester) async {
    await pumpApp(tester, content: const MemoryContentSource({}));
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('must-know-strip')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('search-pill')).hitTestable());
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('search-field')), 'x');
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('search-empty')), findsOneWidget);
  });
}
