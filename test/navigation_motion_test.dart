import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/router/app_page_transitions.dart';
import 'package:knowledge_hub/core/router/app_router.dart';
import 'package:knowledge_hub/core/router/tab_pager.dart';
import 'package:knowledge_hub/features/home/home_screen.dart';

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

bool navSelected(WidgetTester tester, int i) => tester
    .getSemantics(find.byKey(ValueKey('nav-$i')))
    .flagsCollection
    .isSelected
    .toBoolOrNull()!;

Future<void> swipe(WidgetTester tester, double dx) async {
  await tester.fling(find.byType(PageView), Offset(dx, 0), 1500);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tapping a tab animates the pager (no hard cut) and keeps '
      'state alive', (tester) async {
    await pumpApp(tester);
    final pager = tester.widget<PageView>(find.byType(PageView));

    await tester.tap(find.byKey(const ValueKey('nav-3')));
    await tester.pump(); // goBranch
    await tester.pump(); // post-frame animateToPage starts
    await tester.pump(const Duration(milliseconds: 120));
    final mid = pager.controller!.page!;
    expect(mid, greaterThan(0));
    expect(mid, lessThan(3), reason: 'still animating mid-way');

    await tester.pumpAndSettle();
    expect(pager.controller!.page, 3);
    expect(currentPath(tester), '/more');
    // Home stayed alive while off-screen.
    expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
  });

  testWidgets('TabSwipeOptOut keeps horizontal drags from switching tabs', (
    tester,
  ) async {
    setSurface(tester);
    Future<double> flingFirstPage(bool optOut) async {
      final controller = PageController();
      addTearDown(controller.dispose);
      const page = ColoredBox(
        key: ValueKey('page'),
        color: Colors.white,
        child: SizedBox.expand(),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: PageView(
            key: UniqueKey(),
            controller: controller,
            children: [
              optOut ? const TabSwipeOptOut(child: page) : page,
              const SizedBox.expand(),
            ],
          ),
        ),
      );
      await tester.fling(
        find.byKey(const ValueKey('page')),
        const Offset(-300, 0),
        1500,
      );
      await tester.pumpAndSettle();
      return controller.page!;
    }

    expect(await flingFirstPage(false), 1, reason: 'control: pager swipes');
    expect(await flingFirstPage(true), 0, reason: 'opt-out blocks it');
  });

  group('AppPageRoute', () {
    Future<NavigatorState> pumpNav(WidgetTester tester, Locale locale) async {
      setSurface(tester);
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          builder: (context, child) => Directionality(
            textDirection: locale == ar ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
          home: const Scaffold(body: Text('root')),
        ),
      );
      key.currentState!.push(
        AppPageRoute<void>(
          builder: (_) => const Scaffold(body: Center(child: Text('detail'))),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('detail'), findsOneWidget);
      return key.currentState!;
    }

    testWidgets('pop follows the iOS timing (done within 500ms)', (
      tester,
    ) async {
      final nav = await pumpNav(tester, en);
      nav.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('detail'), findsOneWidget); // still sliding out
      await tester.pump(const Duration(milliseconds: 260));
      expect(find.text('detail'), findsNothing);
    });

    testWidgets('edge swipe from the left pops (LTR)', (tester) async {
      await pumpNav(tester, en);
      final g = await tester.startGesture(const Offset(5, 300));
      await g.moveBy(const Offset(20, 0));
      await g.moveBy(const Offset(250, 0));
      await g.up();
      await tester.pumpAndSettle();
      expect(find.text('detail'), findsNothing);
      expect(find.text('root'), findsOneWidget);
    });

    testWidgets('edge swipe from the right pops (RTL)', (tester) async {
      await pumpNav(tester, ar);
      final g = await tester.startGesture(const Offset(355, 300));
      await g.moveBy(const Offset(-20, 0));
      await g.moveBy(const Offset(-250, 0));
      await g.up();
      await tester.pumpAndSettle();
      expect(find.text('detail'), findsNothing);
    });

    testWidgets('a short edge drag springs back', (tester) async {
      await pumpNav(tester, en);
      final g = await tester.startGesture(const Offset(5, 300));
      await g.moveBy(const Offset(20, 0));
      await g.moveBy(const Offset(30, 0));
      await tester.pump(const Duration(seconds: 1)); // kill velocity
      await g.up();
      await tester.pumpAndSettle();
      expect(find.text('detail'), findsOneWidget);
    });
  });
}
