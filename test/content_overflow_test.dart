import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_hub/features/home/home_screen.dart';
import 'package:knowledge_hub/features/tools/tool_routes.dart';

import 'helpers/pump_app.dart';

/// Doc 04 §6.1 for the content screens: no overflow at 100 / 130 / 200 %
/// text scale, Arabic and English, light and dark, on a 360x640 phone.
void main() {
  const scales = [1.0, 1.3, 2.0];
  const routes = [
    '/section/packages',
    '/section/numbers',
    '/section/company',
    '/item/pkg-test-alpha',
    '/item/pkg-test-beta',
    '/item/pkg-test-gamma',
    '/item/proc-test-replace-sim',
    '/item/num-test-hotline',
    '/item/missing',
    ToolRoutes.compare,
    '/tools/compare?id=pkg-test-alpha',
    ToolRoutes.recommend,
    ToolRoutes.calculator,
    ToolRoutes.favorites,
    ToolRoutes.notes,
    ToolRoutes.editor,
    ToolRoutes.newItem,
    '/tools/editor/item?id=pkg-test-alpha',
    ToolRoutes.whatsNew,
    ToolRoutes.training,
  ];

  // Pushed routes cover the shell (offstage), so the last vertical list
  // is the page's.
  Finder vertical() => find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );

  Future<void> scrollThrough(WidgetTester tester, String reason) async {
    if (vertical().evaluate().isEmpty) return; // e.g. not-found page
    for (var i = 0; i < 8; i++) {
      await tester.drag(vertical().last, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$reason step $i');
    }
  }

  for (final locale in [ar, en]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in scales) {
        final tag = '${locale.languageCode}/${mode.name}/x$scale';

        testWidgets('content screens have no overflow ($tag)', (tester) async {
          await pumpApp(
            tester,
            locale: locale,
            themeMode: mode,
            textScale: scale,
          );
          final router = GoRouter.of(tester.element(find.byType(HomeScreen)));
          for (final r in routes) {
            router.push(r);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: r);
            await scrollThrough(tester, r);
            router.pop();
            await tester.pumpAndSettle();
          }
        });

        testWidgets('search results have no overflow ($tag)', (tester) async {
          await pumpApp(
            tester,
            locale: locale,
            themeMode: mode,
            textScale: scale,
          );
          await tester.tap(
            find.byKey(const ValueKey('search-pill')).hitTestable(),
          );
          await tester.pumpAndSettle();
          for (final q in ['باقة', '*999#', 'زززز']) {
            await tester.enterText(
              find.byKey(const ValueKey('search-field')),
              q,
            );
            await tester.pump(const Duration(milliseconds: 150));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: q);
            await scrollThrough(tester, q);
            await tester.drag(vertical().last, const Offset(0, 6000));
            await tester.pumpAndSettle();
          }
        });
      }
    }
  }
}
