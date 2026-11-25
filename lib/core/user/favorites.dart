import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/content_models.dart';
import '../content/content_providers.dart';
import '../settings/preferences.dart';
import 'json_store.dart';

/// Ids of favourite items, in the owner's order, kept on the device.
///
/// May hold ids that are not in the content any more; show
/// [favoriteItemsProvider] instead of resolving these yourself.
final favoritesProvider = NotifierProvider<Favorites, Set<String>>(
  Favorites.new,
);

/// Favourites that exist in the current content, in order. Ids that point to
/// a removed item are skipped silently.
final favoriteItemsProvider = Provider<List<ContentItem>>((ref) {
  final library = ref.watch(contentLibraryProvider);
  return [
    for (final id in ref.watch(favoritesProvider)) ?library.byId(id),
  ];
});

class Favorites extends Notifier<Set<String>> {
  @override
  Set<String> build() => LinkedHashSet.of(
    ref.watch(preferencesProvider)?.getStringList(UserKeys.favorites) ??
        const <String>[],
  );

  /// Adds [id] at the end, or removes it.
  void toggle(String id) {
    if (id.isEmpty) return;
    final next = LinkedHashSet<String>.of(state);
    if (!next.remove(id)) next.add(id);
    _set(next);
  }

  /// Puts [orderedIds] first in this order; ids not listed (for example
  /// items missing from the current content) keep their order after them.
  void reorder(List<String> orderedIds) {
    final known = [
      for (final id in orderedIds)
        if (state.contains(id)) id,
    ];
    _set({...known, ...state});
  }

  void _set(Set<String> next) {
    state = next;
    ref
        .read(preferencesProvider)
        ?.setStringList(UserKeys.favorites, next.toList());
  }
}
