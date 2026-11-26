import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/content/content_providers.dart';
import 'core/content/content_updates.dart';
import 'core/router/app_router.dart';
import 'core/widgets/glass_popups.dart';
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
      // iOS-style elastic scrolling everywhere, no Android glow.
      scrollBehavior: const _AppScrollBehavior(),
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppIdentity.of(context),
      routerConfig: router,
      builder: (context, child) => _ContentUpdates(child: child!),
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

/// Elastic, iOS-like scrolling on every platform; mouse drags scroll too.
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(
        decelerationRate: ScrollDecelerationRate.normal,
        parent: AlwaysScrollableScrollPhysics(),
      );

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

/// Looks for newer published content (prices kept in step with the official
/// site) shortly after start and whenever the app comes back, at most every
/// few hours. A verified update reloads the content in place; the "what's
/// new" page then lists what changed.
class _ContentUpdates extends ConsumerStatefulWidget {
  const _ContentUpdates({required this.child});

  final Widget child;

  @override
  ConsumerState<_ContentUpdates> createState() => _ContentUpdatesState();
}

class _ContentUpdatesState extends ConsumerState<_ContentUpdates>
    with WidgetsBindingObserver {
  Timer? _start;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Let the first screens settle before touching the network.
    _start = Timer(const Duration(seconds: 3), _check);
  }

  @override
  void dispose() {
    _start?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final updater = ref.read(contentUpdaterProvider);
    if (updater == null || _busy) return;
    _busy = true;
    try {
      final result = await updater.checkIfDue();
      if (!mounted || result != UpdateResult.updated) return;
      ref.invalidate(contentSourceProvider);
      final l10n = AppLocalizations.of(context);
      showGlassToast(context, l10n.contentUpdated, icon: AppIcons.renewal);
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
