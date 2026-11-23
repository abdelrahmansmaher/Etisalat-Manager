import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/features/browse/browse_screen.dart';
import 'package:knowledge_hub/features/home/home_screen.dart';
import 'package:knowledge_hub/features/me/me_screen.dart';
import 'package:knowledge_hub/features/search/search_screen.dart';
import 'package:knowledge_hub/features/training/training_screen.dart';
import 'package:knowledge_hub/l10n/app_identity.dart';

import 'helpers/pump_app.dart';

TextDirection directionOf(WidgetTester tester, Finder finder) =>
    Directionality.of(tester.element(finder));

Brightness brightnessOf(WidgetTester tester, Finder finder) =>
    Theme.of(tester.element(finder)).brightness;

bool searchFieldFocused(WidgetTester tester) {
  final field = tester.widget<TextField>(
    find.byKey(const ValueKey('search-field')),
  );
  return field.focusNode!.hasFocus;
}

void main() {
  group('locale x theme matrix', () {
    for (final locale in [ar, en]) {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        testWidgets('${locale.languageCode} / ${mode.name}', (tester) async {
          await pumpApp(tester, locale: locale, themeMode: mode);

          final home = find.byType(HomeScreen);
          expect(home, findsOneWidget);
          expect(
            directionOf(tester, home),
            locale == ar ? TextDirection.rtl : TextDirection.ltr,
          );
          expect(
            brightnessOf(tester, home),
            mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
          );
          expect(find.text(AppIdentity.nameFor(locale)), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  testWidgets('bottom nav has 5 items and navigates to each tab', (
    tester,
  ) async {
    await pumpApp(tester);

    for (var i = 0; i < 5; i++) {
      expect(find.byKey(ValueKey('nav-$i')), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('nav-5')), findsNothing);
    // Arabic labels, Home rightmost in RTL.
    const labels = ['الرئيسية', 'تصفح', 'بحث', 'التدريب', 'أنا'];
    for (var i = 0; i < labels.length; i++) {
      expect(
        find.descendant(
          of: find.byKey(ValueKey('nav-$i')),
          matching: find.text(labels[i]),
        ),
        findsOneWidget,
      );
    }
    final homeX = tester.getCenter(find.byKey(const ValueKey('nav-0'))).dx;
    final meX = tester.getCenter(find.byKey(const ValueKey('nav-4'))).dx;
    expect(homeX, greaterThan(meX), reason: 'RTL: Home is rightmost');

    final screens = <int, Type>{
      1: BrowseScreen,
      2: SearchScreen,
      3: TrainingScreen,
      4: MeScreen,
      0: HomeScreen,
    };
    for (final entry in screens.entries) {
      await tester.tap(find.byKey(ValueKey('nav-${entry.key}')));
      await tester.pumpAndSettle();
      expect(
        find.byType(entry.value),
        findsOneWidget,
        reason: 'tab ${entry.key}',
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('English nav order is LTR (Home leftmost)', (tester) async {
    await pumpApp(tester, locale: en);
    final homeX = tester.getCenter(find.byKey(const ValueKey('nav-0'))).dx;
    final meX = tester.getCenter(find.byKey(const ValueKey('nav-4'))).dx;
    expect(homeX, lessThan(meX));
    expect(find.text('Search'), findsOneWidget);
  });

  testWidgets('Search tab autofocuses the field; Home pill opens Search', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('nav-2')));
    await tester.pumpAndSettle();
    expect(searchFieldFocused(tester), isTrue);

    await tester.enterText(find.byKey(const ValueKey('search-field')), 'abc');
    // Re-tapping the active Search tab clears and refocuses.
    await tester.tap(find.byKey(const ValueKey('nav-2')));
    await tester.pumpAndSettle();
    expect(find.text('abc'), findsNothing);
    expect(searchFieldFocused(tester), isTrue);

    await tester.tap(find.byKey(const ValueKey('nav-0')));
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-search-pill')));
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(searchFieldFocused(tester), isTrue);
  });

  testWidgets('Me: theme and language switches apply immediately', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('nav-4')));
    await tester.pumpAndSettle();

    final meScrollable = find
        .descendant(
          of: find.byType(MeScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.tap(find.byKey(const ValueKey('theme-dark')));
    await tester.pumpAndSettle();
    expect(brightnessOf(tester, find.byType(MeScreen)), Brightness.dark);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('lang-en')),
      200,
      scrollable: meScrollable,
    );
    await tester.tap(find.byKey(const ValueKey('lang-en')));
    await tester.pumpAndSettle();
    expect(directionOf(tester, find.byType(MeScreen)), TextDirection.ltr);
    expect(find.text('Me'), findsWidgets);

    // Editor mode entry exists but is disabled.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('editor-mode')),
      200,
      scrollable: meScrollable,
    );
    final tile = tester.widget<ListTile>(
      find.byKey(const ValueKey('editor-mode')),
    );
    expect(tile.enabled, isFalse);
  });

  testWidgets('wide layout uses a NavigationRail', (tester) async {
    await pumpApp(tester, size: const Size(900, 700));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-0')), findsNothing);
  });
}
