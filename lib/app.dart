import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'l10n/app_identity.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_provider.dart';

/// Root widget: Material 3 theme from tokens, Arabic-first l10n, go_router.
class KnowledgeHubApp extends ConsumerWidget {
  const KnowledgeHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppIdentity.of(context),
      routerConfig: router,
      locale: locale,
      supportedLocales: kSupportedLocales,
      // No override chosen: follow the device language, Arabic fallback.
      localeListResolutionCallback: (device, _) => resolveAppLocale(device),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      // Smooth 300ms cross-fade of every token; instant when the OS asks to
      // remove animations.
      themeAnimationDuration:
          WidgetsBinding
              .instance
              .platformDispatcher
              .accessibilityFeatures
              .disableAnimations
          ? Duration.zero
          : AppMotion.max,
      themeAnimationCurve: AppMotion.enter,
    );
  }
}
