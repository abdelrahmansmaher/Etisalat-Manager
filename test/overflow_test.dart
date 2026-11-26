import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/features/codes/codes_screen.dart';
import 'package:knowledge_hub/features/home/home_screen.dart';
import 'package:knowledge_hub/features/more/more_screen.dart';
import 'package:knowledge_hub/features/packages/packages_screen.dart';

import 'helpers/pump_app.dart';

/// Doc 04 §6.1: font scale up to 200 % without clipping or overlap,
/// mandatory at 100 % / 130 % / 200 %, on a 360x640 phone surface.
void main() {
  const scales = [1.0, 1.3, 2.0];

  Future<void> scrollToEnd(WidgetTester tester, Type screen) async {
    final scope = find.byType(screen);
    final scrollable = find
        .descendant(
          of: scope,
          matching: find.byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          ),
        )
        .first;
    final state = tester.state<ScrollableState>(scrollable);
    state.position.jumpTo(state.position.maxScrollExtent);
    await tester.pumpAndSettle();
  }

  for (final locale in [ar, en]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in scales) {
        final tag = '${locale.languageCode}/${mode.name}/x$scale';

        testWidgets('Home has no overflow ($tag)', (tester) async {
          await pumpApp(
            tester,
            locale: locale,
            themeMode: mode,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
          await scrollToEnd(tester, HomeScreen);
          expect(tester.takeException(), isNull);
        });

        testWidgets('tabs and search have no overflow ($tag)', (tester) async {
          await pumpApp(
            tester,
            locale: locale,
            themeMode: mode,
            textScale: scale,
          );
          final screens = {1: PackagesScreen, 2: CodesScreen, 3: MoreScreen};
          for (final e in screens.entries) {
            await tester.tap(find.byKey(ValueKey('nav-${e.key}')));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: '${e.value}');
            await scrollToEnd(tester, e.value);
            expect(tester.takeException(), isNull, reason: '${e.value} end');
          }
          await tester.tap(
            find.byKey(const ValueKey('search-pill')).hitTestable(),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'search');
        });
      }
    }
  }
}
