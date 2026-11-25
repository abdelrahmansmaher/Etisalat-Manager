import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/codes/codes_screen.dart';
import '../../features/content/item_detail_screen.dart';
import '../../features/content/package_family.dart';
import '../../features/content/section_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/packages/packages_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/tools/tool_routes.dart';
import 'app_routes.dart';
import 'app_page_transitions.dart';
import 'app_shell.dart';
import 'tab_pager.dart';

/// Router as a provider so every ProviderScope (incl. each widget test) gets
/// a fresh instance with its own navigation state.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        // Swipeable, kept-alive tabs instead of a hard-cut IndexedStack.
        navigatorContainerBuilder: (context, shell, children) =>
            TabPager(navigationShell: shell, children: children),
        branches: [
          StatefulShellBranch(
            preload: true,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            preload: true,
            routes: [
              GoRoute(
                path: AppRoutes.packages,
                builder: (context, state) => PackagesScreen(
                  segment: PackageSegment.fromKey(
                    state.uri.queryParameters['s'],
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            preload: true,
            routes: [
              GoRoute(
                path: AppRoutes.codes,
                builder: (context, state) => const CodesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            preload: true,
            routes: [
              GoRoute(
                path: AppRoutes.more,
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
      // Pushed above the shell (root navigator) with swipe-back.
      GoRoute(
        path: ContentRoutes.sectionPattern,
        pageBuilder: (context, state) => AppPage<void>(
          key: state.pageKey,
          child: SectionScreen(sectionKey: state.pathParameters['key']!),
        ),
      ),
      GoRoute(
        path: ContentRoutes.itemPattern,
        pageBuilder: (context, state) => AppPage<void>(
          key: state.pageKey,
          child: ItemDetailScreen(itemId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.search,
        pageBuilder: (context, state) =>
            AppPage<void>(key: state.pageKey, child: const SearchScreen()),
      ),
      ...toolRoutes,
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
