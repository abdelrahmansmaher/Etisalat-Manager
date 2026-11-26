import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/liquid_glass.dart';
import '../../features/tools/whats_new.dart' show whatsNewUnseenProvider;
import 'app_routes.dart';
import 'tab_pager.dart';
import '../theme/app_icons.dart';

/// App chrome: floating bottom nav on phones (< 600dp), NavigationRail on the
/// start side for tablet/web (doc 04 §4.5).
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static List<AppNavDestination> destinations(AppLocalizations l10n) => [
    AppNavDestination(
      icon: AppIcons.navHome,
      selectedIcon: AppIcons.navHomeActive,
      label: l10n.navHome,
    ),
    AppNavDestination(
      icon: AppIcons.navPackages,
      selectedIcon: AppIcons.navPackagesActive,
      label: l10n.navPackages,
    ),
    AppNavDestination(
      icon: AppIcons.navCodes,
      selectedIcon: AppIcons.navCodesActive,
      label: l10n.navCodes,
    ),
    AppNavDestination(
      icon: AppIcons.navMore,
      selectedIcon: AppIcons.navMoreActive,
      label: l10n.navMore,
    ),
  ];

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final PageController _pages = PageController(
    initialPage: widget.navigationShell.currentIndex,
  );
  final ValueNotifier<bool> _swiping = ValueNotifier(false);

  StatefulNavigationShell get navigationShell => widget.navigationShell;

  @override
  void dispose() {
    _pages.dispose();
    _swiping.dispose();
    super.dispose();
  }

  void _onSelected(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  /// Ctrl+K (Cmd+K) opens search on a keyboard.
  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      for (final meta in [false, true])
        SingleActivator(
          LogicalKeyboardKey.keyK,
          control: !meta,
          meta: meta,
        ): () =>
            context.push(AppRoutes.search),
    },
    child: Focus(autofocus: true, skipTraversal: true, child: _layout(context)),
  );

  Widget _layout(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dests = AppShell.destinations(l10n);
    final width = MediaQuery.sizeOf(context).width;

    if (width >= 600) {
      final c = context.colors;
      return TabPagerScope(
        controller: _pages,
        child: Scaffold(
          body: AppBackdrop(
            child: Row(
              children: [
                NavigationRail(
                  backgroundColor: c.glassChrome,
                  extended: width >= 1200,
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _onSelected,
                  labelType: width >= 1200
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  destinations: [
                    for (final d in dests)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ),
                  ],
                ),
                VerticalDivider(width: 1, color: c.hairline),
                // Screens size themselves by the room beside the rail.
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) => MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(size: Size(box.maxWidth, box.maxHeight)),
                      child: navigationShell,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return TabPagerScope(
      controller: _pages,
      swiping: _swiping,
      child: Scaffold(
        extendBody: true,
        body: AppBackdrop(child: navigationShell),
        bottomNavigationBar: Consumer(
          builder: (context, ref, _) {
            final unseen = ref.watch(whatsNewUnseenProvider);
            return AppBottomNav(
              destinations: [
                for (final (i, d) in dests.indexed)
                  i == 0 ? d.withBadge(unseen) : d,
              ],
              currentIndex: navigationShell.currentIndex,
              onSelected: _onSelected,
              pageController: _pages,
              swiping: _swiping,
              onSearch: () => context.push(AppRoutes.search),
              searchLabel: l10n.homeSearchHint,
            );
          },
        ),
      ),
    );
  }
}
