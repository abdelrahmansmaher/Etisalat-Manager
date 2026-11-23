import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferences.dart';

/// Most-recent-first list of strings, capped, persisted in
/// [preferencesProvider] when available (in-memory otherwise).
abstract class _RecentList extends Notifier<List<String>> {
  String get prefKey;
  int get cap;

  @override
  List<String> build() =>
      ref.watch(preferencesProvider)?.getStringList(prefKey) ?? const [];

  void add(String value) {
    final v = value.trim();
    if (v.isEmpty) return;
    final next = [v, ...state.where((e) => e != v)].take(cap).toList();
    if (next.length == state.length &&
        next.indexed.every((e) => state[e.$1] == e.$2)) {
      return;
    }
    state = next;
    ref.read(preferencesProvider)?.setStringList(prefKey, next);
  }

  void clear() {
    state = const [];
    ref.read(preferencesProvider)?.remove(prefKey);
  }
}

/// Ids of recently opened content items (Home "recently opened").
final recentItemsProvider = NotifierProvider<RecentItems, List<String>>(
  RecentItems.new,
);

class RecentItems extends _RecentList {
  @override
  String get prefKey => PrefKeys.recentItems;
  @override
  int get cap => 8;
}

/// Recent search queries (Search idle state).
final recentSearchesProvider = NotifierProvider<RecentSearches, List<String>>(
  RecentSearches.new,
);

class RecentSearches extends _RecentList {
  @override
  String get prefKey => PrefKeys.recentSearches;
  @override
  int get cap => 6;
}
