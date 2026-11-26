import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_hub/features/packages/packages_screen.dart';
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

    testWidgets('a sideways swipe never changes the dock tab', (tester) async {
      await pumpApp(tester, locale: en);
      final start = rectOf(tester, 'nav-indicator');
      await tester.flingFrom(
        const Offset(300, 400),
        const Offset(-250, 0),
        1500,
      );
      await tester.pumpAndSettle();
      expect(currentPath(tester), '/home');
      expect(
        rectOf(tester, 'nav-indicator').center.dx,
        closeTo(start.center.dx, 1),
      );
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

    testWidgets('the groups button jumps to a group', (tester) async {
      await pumpApp(tester, size: const Size(360, 420));
      await tester.tap(find.byKey(const ValueKey('nav-2')));
      await tester.pumpAndSettle();
      const group = 'أكواد الرصيد';
      await tester.tap(find.byKey(const ValueKey('category-capsules')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('jump-$group')));
      await tester.pumpAndSettle();
      final header = find.byKey(const ValueKey('group-$group'));
      expect(header, findsOneWidget);
      // The button stays pinned above the group that was jumped to.
      final pill = find.byKey(const ValueKey('category-capsules'));
      expect(
        tester.getTopLeft(header).dy,
        greaterThanOrEqualTo(tester.getBottomLeft(pill).dy - 1),
      );
      expect(
        find.descendant(of: pill, matching: find.text(group)),
        findsOneWidget,
      );
    });

    testWidgets('the search section filter narrows the results', (
      tester,
    ) async {
      await pumpApp(tester);
      await openSearch(tester);
      await tester.enterText(
        find.byKey(const ValueKey('search-field')),
        'رصيد',
      );
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('search-filters')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('search-filter-all')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('search-filter-numbers')));
      await tester.pumpAndSettle();
      final pill = find.byKey(const ValueKey('search-filters'));
      expect(
        find.descendant(of: pill, matching: find.text('الأكواد والأرقام')),
        findsWidgets,
      );
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

  testWidgets('the kinds button filters the packages', (tester) async {
    await pumpApp(tester, size: const Size(400, 900));
    await tester.tap(find.byKey(const ValueKey('nav-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('family-filter')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('family-all')), findsOneWidget);
    final other = find.byWidgetPredicate((w) {
      final k = w.key;
      return k is ValueKey<String> &&
          k.value.startsWith('family-') &&
          !{'family-all', 'family-filter', 'family-capsules'}.contains(k.value);
    }).first;
    final name = (tester.widget(other).key! as ValueKey<String>).value
        .substring('family-'.length);
    await tester.tap(other);
    await tester.pumpAndSettle();
    final pill = find.byKey(const ValueKey('family-filter'));
    expect(
      find.descendant(of: pill, matching: find.text(name)),
      findsOneWidget,
    );
  });

  testWidgets('a sideways swipe on Packages moves to the next segment', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(400, 900));
    await tester.tap(find.byKey(const ValueKey('nav-1')));
    await tester.pumpAndSettle();
    // Arabic: the next segment is on the left; the finger moves right.
    await tester.flingFrom(const Offset(100, 600), const Offset(250, 0), 1500);
    await tester.pumpAndSettle();
    expect(currentPath(tester), startsWith('/packages'));
    expect(
      GoRouterState.of(tester.element(find.byType(PackagesScreen)))
          .uri
          .queryParameters['s'],
      'mobileInternet',
    );
  });
}
