import 'package:go_router/go_router.dart';

import '../../core/router/app_page_transitions.dart';
import '../training/training_screen.dart';
import 'calculator_screen.dart';
import 'compare_screen.dart';
import 'editor_screen.dart';
import 'favorites_screen.dart';
import 'notes_screen.dart';
import 'recommend_screen.dart';
import 'whats_new_screen.dart';

/// Paths of the tool screens. All are pushed above the shell
/// (`context.push(ToolRoutes.compare)`).
abstract final class ToolRoutes {
  static const String compare = '/tools/compare';
  static const String recommend = '/tools/recommend';

  /// Hide the entry when `rechargeCalculatorAvailableProvider` is false.
  static const String calculator = '/tools/calculator';

  /// "My edits" list.
  static const String editor = '/tools/editor';
  static const String notes = '/tools/notes';
  static const String whatsNew = '/tools/whats-new';
  static const String training = '/tools/training';
  static const String favorites = '/tools/favorites';

  static String compareWith(String id) =>
      '$compare?id=${Uri.encodeQueryComponent(id)}';
  static String editItem(String id) =>
      '$editor/item?id=${Uri.encodeQueryComponent(id)}';
  static const String newItem = '$editor/new';
  static String notesFor(String itemId) =>
      '$notes?item=${Uri.encodeQueryComponent(itemId)}';
}

/// Add to the root routes of the app router (next to the item route).
final List<RouteBase> toolRoutes = [
  GoRoute(
    path: ToolRoutes.compare,
    pageBuilder: (context, state) => AppPage<void>(
      key: state.pageKey,
      child: CompareScreen(initialId: state.uri.queryParameters['id']),
    ),
  ),
  GoRoute(
    path: ToolRoutes.recommend,
    pageBuilder: (context, state) => AppPage<void>(
      key: state.pageKey,
      child: const RecommendScreen(),
    ),
  ),
  GoRoute(
    path: ToolRoutes.calculator,
    pageBuilder: (context, state) => AppPage<void>(
      key: state.pageKey,
      child: const CalculatorScreen(),
    ),
  ),
  GoRoute(
    path: ToolRoutes.editor,
    pageBuilder: (context, state) => AppPage<void>(
      key: state.pageKey,
      child: const EditorScreen(),
    ),
  ),
  GoRoute(
    path: ToolRoutes.newItem,
    pageBuilder: (context, state) => AppPage<void>(
      key: state.pageKey,
      child: const ItemEditorScreen(),
    ),
  ),
  GoRoute(
    path: '${ToolRoutes.editor}/item',
    pageBuilder: (context, state) => AppPage<void>(
      key: state.pageKey,
      child: ItemEditorScreen(itemId: state.uri.queryParameters['id']),
    ),
  ),
  GoRoute(
    path: ToolRoutes.notes,
    pageBuilder: (context, state) => AppPage<void>(
      key: state.pageKey,
      child: NotesScreen(itemId: state.uri.queryParameters['item']),
    ),
  ),
  GoRoute(
    path: ToolRoutes.whatsNew,
    pageBuilder: (context, state) => AppPage<void>(
      key: state.pageKey,
      child: const WhatsNewScreen(),
    ),
  ),
  GoRoute(
    path: ToolRoutes.training,
    pageBuilder: (context, state) => AppPage<void>(
      key: state.pageKey,
      child: const TrainingScreen(),
    ),
  ),
  GoRoute(
    path: ToolRoutes.favorites,
    pageBuilder: (context, state) => AppPage<void>(
      key: state.pageKey,
      child: const FavoritesScreen(),
    ),
  ),
];
