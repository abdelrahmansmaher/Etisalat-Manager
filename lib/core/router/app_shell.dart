import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import 'app_routes.dart';
import 'tab_pager.dart';
import 'search_focus.dart';
import '../theme/app_icons.dart';

/// App chrome: floating bottom nav on phones (< 600dp), NavigationRail on the
/// start side for tablet/web (doc 04 §4.5).
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static List<AppNavDestination> destinations(AppLocalizations l10n) => [
    AppNavDestination(
      icon: AppIcons.navHome,
      selectedIcon: AppIcons.navHomeActive,
      label: l10n.navHome,
    ),
    AppNavDestination(
      icon: AppIcons.navBrowse,
      selectedIcon: AppIcons.navBrowseActive,
      label: l10n.navBrowse,
    ),
    AppNavDestination(
      icon: AppIcons.search,
      selectedIcon: AppIcons.search,
      label: l10n.navSearch,
    ),
    AppNavDestination(
      icon: AppIcons.navTraining,
      selectedIcon: AppIcons.comingSoon,
      label: l10n.navTraining,
    ),
    AppNavDestination(
      icon: AppIcons.navMe,
      selectedIcon: AppIcons.navMeActive,
      label: l10n.navMe,
    ),
  ];

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late final PageController _pages = PageController(
    initialPage: widget.navigationShell.currentIndex,
  );

  StatefulNavigationShell get navigationShell => widget.navigationShell;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _onSelected(int index) {
    final reselect = index == navigationShell.currentIndex;
    if (index == AppRoutes.searchTabIndex) {
      ref.read(searchFocusRequestProvider.notifier).request(clear: reselect);
    }
    navigationShell.goBranch(index, initialLocation: reselect);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dests = AppShell.destinations(l10n);
    final width = MediaQuery.sizeOf(context).width;

    if (width >= 600) {
      final c = context.colors;
      return TabPagerScope(
        controller: _pages,
        child: Scaffold(
          body: Row(
            children: [
              NavigationRail(
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
              Expanded(child: navigationShell),
            ],
          ),
        ),
      );
    }

    return TabPagerScope(
      controller: _pages,
      child: Scaffold(
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: AppBottomNav(
          destinations: dests,
          currentIndex: navigationShell.currentIndex,
          centerIndex: AppRoutes.searchTabIndex,
          onSelected: _onSelected,
          pageController: _pages,
        ),
      ),
    );
  }
}
