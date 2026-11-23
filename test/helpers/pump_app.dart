import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/app.dart';
import 'package:knowledge_hub/core/theme/theme.dart';
import 'package:knowledge_hub/l10n/app_localizations.dart';
import 'package:knowledge_hub/l10n/locale_provider.dart';

const ar = Locale('ar');
const en = Locale('en');

/// Sizes the test view (logical px, DPR 1) and text scale, with teardown.
void setSurface(
  WidgetTester tester, {
  Size size = const Size(360, 640),
  double textScale = 1.0,
}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// Pumps the full app (router, shell, theme, l10n).
Future<void> pumpApp(
  WidgetTester tester, {
  Locale locale = ar,
  ThemeMode themeMode = ThemeMode.light,
  Size size = const Size(360, 640),
  double textScale = 1.0,
}) async {
  setSurface(tester, size: size, textScale: textScale);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localeProvider.overrideWith(() => LocaleController(locale)),
        themeModeProvider.overrideWith(() => ThemeModeController(themeMode)),
      ],
      child: const KnowledgeHubApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Like [pumpApp] but only pumps one frame (to observe entrance motion).
Future<void> pumpAppNoSettle(WidgetTester tester, {Locale locale = ar}) async {
  setSurface(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localeProvider.overrideWith(() => LocaleController(locale)),
        themeModeProvider.overrideWith(
          () => ThemeModeController(ThemeMode.light),
        ),
      ],
      child: const KnowledgeHubApp(),
    ),
  );
}

/// Pumps a single widget inside a themed, localized app scaffold.
Future<void> pumpLocalized(
  WidgetTester tester,
  Widget child, {
  Locale locale = ar,
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: kSupportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: brightness == Brightness.light
          ? AppTheme.light()
          : AppTheme.dark(),
      home: Scaffold(
        body: Center(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
