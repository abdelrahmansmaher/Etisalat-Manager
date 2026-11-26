import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ticked steps per item, kept while the app is open: leaving a procedure to
/// look something up must not lose the place.
final stepsProgressProvider =
    NotifierProvider<StepsProgress, Map<String, Set<int>>>(StepsProgress.new);

class StepsProgress extends Notifier<Map<String, Set<int>>> {
  @override
  Map<String, Set<int>> build() => const {};

  void toggle(String itemId, int step) {
    final next = {...?state[itemId]};
    if (!next.remove(step)) next.add(step);
    state = {...state, itemId: next};
  }

  /// Ready for the next customer.
  void reset(String itemId) => state = {...state}..remove(itemId);
}
