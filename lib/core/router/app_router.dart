import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/browse/browse_screen.dart';
import '../../features/content/item_detail_screen.dart';
import '../../features/content/review_screen.dart';
import '../../features/content/section_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/me/me_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/training/training_screen.dart';
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
                path: AppRoutes.browse,
                builder: (context, state) => const BrowseScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            preload: true,
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            preload: true,
            routes: [
              GoRoute(
                path: AppRoutes.training,
                builder: (context, state) => const TrainingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            preload: true,
            routes: [
              GoRoute(
                path: AppRoutes.me,
                builder: (context, state) => const MeScreen(),
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
        path: ContentRoutes.review,
        pageBuilder: (context, state) =>
            AppPage<void>(key: state.pageKey, child: const ReviewScreen()),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
