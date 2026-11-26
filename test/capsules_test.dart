import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/app.dart';
import 'package:knowledge_hub/core/content/content.dart';
import 'package:knowledge_hub/core/router/app_router.dart';
import 'package:knowledge_hub/core/router/tab_pager.dart';
import 'package:knowledge_hub/core/settings/preferences.dart';
import 'package:knowledge_hub/core/widgets/app_bottom_nav.dart';
import 'package:knowledge_hub/core/widgets/capsules.dart';
import 'package:knowledge_hub/features/content/package_family.dart';
import 'package:knowledge_hub/features/home/home_screen.dart';
import 'package:knowledge_hub/features/more/more_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/content_fixtures.dart';
import 'helpers/pump_app.dart';

String currentPath(WidgetTester tester) {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(TabPager)),
  );
  return container
      .read(routerProvider)
      .routerDelegate
      .currentConfiguration
      .uri
      .path;
}

Rect rectOf(WidgetTester tester, String key) =>
    tester.getRect(find.byKey(ValueKey(key)));

Finder get mainScroll => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .hitTestable()
    .first;

/// Brings a settings option clear of the floating nav bar and taps it.
Future<void> tapOption(WidgetTester tester, String key) async {
  final option = find.byKey(ValueKey(key));
  await tester.scrollUntilVisible(option, 200, scrollable: mainScroll);
  await Scrollable.ensureVisible(tester.element(option), alignment: 0.3);
  await tester.pumpAndSettle();
  await tester.tap(option);
  await tester.pumpAndSettle();
}

Future<void> openSearch(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('search-pill')).hitTestable());
  await tester.pumpAndSettle();
}

void main() {
  group('Capsule bottom navigation', () {
    testWidgets('the indicator sits on the selected tab and moves (RTL)', (
      tester,
    ) async {
      await pumpApp(tester);
      final ind0 = rectOf(tester, 'nav-indicator');
      expect(ind0.center.dx, closeTo(rectOf(tester, 'nav-0').center.dx, 1));
      // RTL: the indicator starts at the right edge.
      expect(ind0.center.dx, greaterThan(rectOf(tester, 'nav-3').center.dx));

      await tester.tap(find.byKey(const ValueKey('nav-3')));
      await tester.pumpAndSettle();
      final ind3 = rectOf(tester, 'nav-indicator');
      expect(ind3.center.dx, closeTo(rectOf(tester, 'nav-3').center.dx, 1));
      expect(ind3.center.dx, lessThan(ind0.center.dx));
    });

    for (final locale in [ar, en]) {
      for (final scale in [1.0, 1.3, 2.0]) {
        testWidgets('tabs fill the bar, each at least 48dp, labels whole '
            '(${locale.languageCode} x$scale)', (tester) async {
          await pumpApp(tester, locale: locale, textScale: scale);
          final bar = tester.getSize(
            find
                .ancestor(
                  of: find.byKey(const ValueKey('nav-indicator')),
                  matching: find.byType(Stack),
                )
                .first,
          );
          var sum = 0.0;
          for (var i = 0; i < 4; i++) {
            final size = tester.getSize(find.byKey(ValueKey('nav-$i')));
            expect(size.width, greaterThanOrEqualTo(48));
            expect(size.height, greaterThanOrEqualTo(AppBottomNav.itemHeight));
            sum += size.width;
          }
          expect(sum, closeTo(bar.width, 1));
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('a tap glides the lens across, it never jumps', (tester) async {
      await pumpApp(tester);
      final from = rectOf(tester, 'nav-0').center.dx;
      final to = rectOf(tester, 'nav-3').center.dx;
      await tester.tap(find.byKey(const ValueKey('nav-3')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));
      final mid = rectOf(tester, 'nav-indicator').center.dx;
      // Somewhere between the two tabs (RTL: from is on the right).
      expect(mid, lessThan(from - 4));
      expect(mid, greaterThan(to + 4));
      await tester.pumpAndSettle();
      expect(rectOf(tester, 'nav-indicator').center.dx, closeTo(to, 1));
    });

    testWidgets('indicator is mid-way while swiping (LTR)', (tester) async {
      await pumpApp(tester, locale: en);
      final start = rectOf(tester, 'nav-indicator');
      expect(start.center.dx, closeTo(rectOf(tester, 'nav-0').center.dx, 1));
      final gesture = await tester.startGesture(const Offset(300, 300));
      await gesture.moveBy(const Offset(-40, 0));
      await gesture.moveBy(const Offset(-180, 0));
      await tester.pump();
      final mid = rectOf(tester, 'nav-indicator');
      expect(mid.center.dx, greaterThan(start.center.dx + 5));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(currentPath(tester), '/packages');
      final end = rectOf(tester, 'nav-indicator');
      expect(end.center.dx, closeTo(rectOf(tester, 'nav-1').center.dx, 1));
    });
  });

  group('Capsule rows and filters', () {
    testWidgets('horizontal capsule row does not switch tabs', (tester) async {
      await pumpApp(tester);
      final row = find.byKey(const ValueKey('home-quick-tools'));
      expect(row, findsOneWidget);
      await tester.fling(row, const Offset(300, 0), 1500);
      await tester.pumpAndSettle();
      await tester.fling(row, const Offset(-300, 0), 1500);
      await tester.pumpAndSettle();
      expect(currentPath(tester), '/home');
    });

    testWidgets('package segments switch and reset the family', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byKey(const ValueKey('nav-1')));
      await tester.pumpAndSettle();
      final seg = find.byKey(const ValueKey('package-segments'));
      expect(
        tester.widget<SegmentedCapsule<PackageSegment>>(seg).selected,
        PackageSegment.mobile,
      );
      await tester.tap(find.byKey(const ValueKey('segment-home')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SegmentedCapsule<PackageSegment>>(seg).selected,
        PackageSegment.home,
      );
      expect(
        find.byKey(const ValueKey('item-row-pkg-test-alpha')),
        findsNothing,
      );
    });

    testWidgets('jump-to-category capsule scrolls to that header', (
      tester,
    ) async {
      await pumpApp(tester, size: const Size(360, 420));
      await tester.tap(find.byKey(const ValueKey('nav-2')));
      await tester.pumpAndSettle();
      const group = 'أكواد الرصيد';
      final capsule = find.byKey(const ValueKey('jump-$group'));
      await tester.ensureVisible(capsule);
      await tester.pumpAndSettle();
      await tester.tap(capsule);
      await tester.pumpAndSettle();
      final header = find.byKey(const ValueKey('group-$group'));
      expect(header, findsOneWidget);
      // The capsule row stays pinned above the group headers.
      final row = find.byKey(const ValueKey('category-capsules'));
      expect(
        tester.getTopLeft(header).dy,
        greaterThanOrEqualTo(tester.getBottomLeft(row).dy - 1),
      );
      expect(
        tester
            .widget<Capsule>(find.byKey(const ValueKey('jump-$group')))
            .selected,
        isTrue,
      );
    });

    testWidgets('search section capsules filter results', (tester) async {
      await pumpApp(tester);
      await openSearch(tester);
      await tester.enterText(
        find.byKey(const ValueKey('search-field')),
        'رصيد',
      );
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      Capsule cap(String k) =>
          tester.widget<Capsule>(find.byKey(ValueKey('search-filter-$k')));
      expect(cap('all').selected, isTrue);
      await tester.ensureVisible(
        find.byKey(const ValueKey('search-filter-numbers')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('search-filter-numbers')));
      await tester.pumpAndSettle();
      expect(cap('numbers').selected, isTrue);
      expect(cap('all').selected, isFalse);
      expect(
        find.byKey(const ValueKey('item-row-code-test-balance')),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 2)); // let timers finish
    });
  });

  group('History', () {
    testWidgets('recently opened items appear on Home', (tester) async {
      await pumpApp(tester);
      expect(find.byKey(const ValueKey('recent-strip')), findsNothing);
      final tile = find.byKey(const ValueKey('must-know-num-test-hotline'));
      await tester.tap(tile);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('recent-num-test-hotline')),
        200,
        scrollable: mainScroll,
      );
      expect(
        find.byKey(const ValueKey('recent-num-test-hotline')),
        findsOneWidget,
      );
    });

    testWidgets('recent searches become capsules', (tester) async {
      await pumpApp(tester);
      await openSearch(tester);
      final field = find.byKey(const ValueKey('search-field'));
      await tester.enterText(field, 'رصيد');
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();
      await tester.enterText(field, '');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('recent-search-رصيد')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('recent-search-رصيد')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('search-count')), findsOneWidget);
    });
  });

  group('Persistence', () {
    Future<SharedPreferences> pumpWithPrefs(
      WidgetTester tester,
      Map<String, Object> initial,
    ) async {
      SharedPreferences.setMockInitialValues(initial);
      final prefs = await SharedPreferences.getInstance();
      setSurface(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesProvider.overrideWithValue(prefs),
            contentSourceProvider.overrideWithValue(fixtureContentSource()),
          ],
          child: const KnowledgeHubApp(),
        ),
      );
      await tester.pumpAndSettle();
      return prefs;
    }

    testWidgets('saved theme and language are restored', (tester) async {
      await pumpWithPrefs(tester, {
        PrefKeys.themeMode: 'dark',
        PrefKeys.locale: 'en',
      });
      final home = find.byType(HomeScreen);
      expect(Theme.of(tester.element(home)).brightness, Brightness.dark);
      expect(Directionality.of(tester.element(home)), TextDirection.ltr);
    });

    testWidgets(
      'theme follows the system, language defaults to Arabic; choices are saved',
      (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        final prefs = await pumpWithPrefs(tester, {});
        final home = find.byType(HomeScreen);
        expect(Theme.of(tester.element(home)).brightness, Brightness.dark);

        await tester.tap(find.byKey(const ValueKey('nav-3')));
        await tester.pumpAndSettle();
        await tapOption(tester, 'theme-light');
        expect(prefs.getString(PrefKeys.themeMode), 'light');
        expect(
          Theme.of(tester.element(find.byType(MoreScreen))).brightness,
          Brightness.light,
        );

        await tapOption(tester, 'lang-ar');
        expect(prefs.getString(PrefKeys.locale), 'ar');
        await tapOption(tester, 'lang-system');
        expect(prefs.getString(PrefKeys.locale), 'system');
      },
    );
  });

  testWidgets('the family pill glides to the chosen family', (tester) async {
    await pumpApp(tester, size: const Size(400, 900));
    await tester.tap(find.byKey(const ValueKey('nav-1')));
    await tester.pumpAndSettle();
    final indicator = find.byKey(const ValueKey('capsule-indicator'));
    expect(indicator, findsOneWidget);
    final all = tester.getRect(find.byKey(const ValueKey('family-all')));
    expect(tester.getRect(indicator).center.dx, closeTo(all.center.dx, 1));
    final other = find.byWidgetPredicate((w) {
      final k = w.key;
      return w is Capsule &&
          k is ValueKey<String> &&
          k.value.startsWith('family-') &&
          k.value != 'family-all';
    }).first;
    await tester.ensureVisible(other);
    await tester.pumpAndSettle();
    await tester.tap(other);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final mid = tester.getRect(indicator).center.dx;
    await tester.pumpAndSettle();
    final target = tester.getRect(other).center.dx;
    expect(tester.getRect(indicator).center.dx, closeTo(target, 1));
    expect((mid - target).abs(), greaterThan(2)); // it moved, not jumped
  });
}
