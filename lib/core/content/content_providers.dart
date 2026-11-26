import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/preferences.dart';
import '../user/content_overlay.dart';
import 'content_updates.dart';
import 'content_loader.dart';
import 'content_models.dart';
import 'content_search.dart';

/// Override in tests with a [MemoryContentSource].
/// The app's copy, or a newer verified copy downloaded from the published
/// content (see `content_updates.dart`).
final contentSourceProvider = Provider<ContentSource>((ref) {
  final prefs = ref.watch(preferencesProvider);
  return prefs == null
      ? const AssetContentSource()
      : UpdatableContentSource(prefs);
});

/// All content (the bundle plus edits made on the device); reloads after an edit.
final contentProvider = FutureProvider<ContentLibrary>(
  (ref) => ContentLoader.load(ref.watch(effectiveContentSourceProvider)),
);

/// Synchronous view: empty library while loading or on error.
final contentLibraryProvider = Provider<ContentLibrary>(
  (ref) => ref.watch(contentProvider).value ?? ContentLibrary.empty,
);

final sectionItemsProvider = Provider.family<List<ContentItem>, ContentSection>(
  (ref, section) => ref.watch(contentLibraryProvider).itemsOf(section),
);

final contentItemProvider = Provider.family<ContentItem?, String>(
  (ref, id) => ref.watch(contentLibraryProvider).byId(id),
);

/// Search index, rebuilt only when the library changes.
final contentSearchProvider = Provider<ContentSearchIndex>(
  (ref) => ContentSearchIndex(ref.watch(contentLibraryProvider).all),
);
