import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/widgets/trust/unofficial_disclaimer.dart';
import 'package:knowledge_hub/features/home/home_screen.dart';
import 'package:knowledge_hub/features/me/me_screen.dart';

import 'helpers/pump_app.dart';

/// Doc 04 §6.1: font scale up to 200 % without clipping or overlap,
/// mandatory at 100 % / 130 % / 200 %, on a 360x640 phone surface.
void main() {
  const scales = [1.0, 1.3, 2.0];

  Future<void> scrollToEnd(WidgetTester tester, Type screen) async {
    final scope = find.byType(screen);
    await tester.scrollUntilVisible(
      find.descendant(of: scope, matching: find.byType(UnofficialDisclaimer)),
      250,
      scrollable: find
          .descendant(of: scope, matching: find.byType(Scrollable))
          .first,
    );
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

        testWidgets('Me has no overflow ($tag)', (tester) async {
          await pumpApp(
            tester,
            locale: locale,
            themeMode: mode,
            textScale: scale,
          );
          await tester.tap(find.byKey(const ValueKey('nav-4')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await scrollToEnd(tester, MeScreen);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  for (final scale in scales) {
    testWidgets('Search, Browse, Training have no overflow (ar x$scale)', (
      tester,
    ) async {
      await pumpApp(tester, textScale: scale);
      for (final tab in [2, 1, 3]) {
        await tester.tap(find.byKey(ValueKey('nav-$tab')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'tab $tab');
        await tester.drag(find.byType(Scrollable).last, const Offset(0, -2000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'tab $tab scrolled');
      }
    });
  }
}
