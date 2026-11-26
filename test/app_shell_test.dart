import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/features/codes/codes_screen.dart';
import 'package:knowledge_hub/features/home/home_screen.dart';
import 'package:knowledge_hub/features/more/more_screen.dart';
import 'package:knowledge_hub/features/packages/packages_screen.dart';
import 'package:knowledge_hub/features/search/search_screen.dart';

import 'helpers/pump_app.dart';

TextDirection directionOf(WidgetTester tester, Finder finder) =>
    Directionality.of(tester.element(finder));

Brightness brightnessOf(WidgetTester tester, Finder finder) =>
    Theme.of(tester.element(finder)).brightness;

bool searchFieldFocused(WidgetTester tester) => tester
    .widget<TextField>(find.byKey(const ValueKey('search-field')))
    .focusNode!
    .hasFocus;

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
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  testWidgets('bottom nav has 4 tabs and opens each of them', (tester) async {
    await pumpApp(tester);

    expect(find.byKey(const ValueKey('nav-4')), findsNothing);
    const labels = ['الرئيسية', 'الباقات', 'الأكواد والأرقام', 'المزيد'];
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
    final moreX = tester.getCenter(find.byKey(const ValueKey('nav-3'))).dx;
    expect(homeX, greaterThan(moreX), reason: 'RTL: Home is rightmost');

    final screens = <int, Type>{
      1: PackagesScreen,
      2: CodesScreen,
      3: MoreScreen,
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
      // Search is one tap away on every tab.
      expect(
        find.byKey(const ValueKey('search-pill')).hitTestable(),
        findsOneWidget,
        reason: 'tab ${entry.key}',
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('English nav order is LTR (Home leftmost)', (tester) async {
    await pumpApp(tester, locale: en);
    final homeX = tester.getCenter(find.byKey(const ValueKey('nav-0'))).dx;
    final moreX = tester.getCenter(find.byKey(const ValueKey('nav-3'))).dx;
    expect(homeX, lessThan(moreX));
  });

  testWidgets('the search pill opens search with the keyboard up', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('search-pill')).hitTestable());
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(searchFieldFocused(tester), isTrue);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Ctrl+K opens search', (tester) async {
    await pumpApp(tester, size: const Size(1280, 800));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
  });

  testWidgets('More: theme and language switches apply immediately', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('nav-3')));
    await tester.pumpAndSettle();

    final more = find.byType(MoreScreen);
    final scrollable = find
        .descendant(of: more, matching: find.byType(Scrollable))
        .first;
    Future<void> tapOption(String key) async {
      final option = find.byKey(ValueKey(key));
      await tester.scrollUntilVisible(option, 200, scrollable: scrollable);
      // Clear of the floating nav bar.
      await Scrollable.ensureVisible(tester.element(option), alignment: 0.3);
      await tester.pumpAndSettle();
      await tester.tap(option);
      await tester.pumpAndSettle();
    }

    await tapOption('theme-dark');
    expect(brightnessOf(tester, more), Brightness.dark);
    await tapOption('lang-en');
    expect(directionOf(tester, more), TextDirection.ltr);
    expect(find.text('More'), findsWidgets);
  });

  testWidgets('wide layout: rail, and a readable centred column', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(1600, 900));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-0')), findsNothing);
    final strip = find.byKey(const ValueKey('must-know-strip'));
    expect(tester.getSize(strip).width, lessThanOrEqualTo(840));
    expect(tester.takeException(), isNull);
  });
}
