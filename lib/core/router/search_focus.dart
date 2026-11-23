import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A request to focus the search field (and optionally clear it).
///
/// Bumped when the Search tab is selected or the Home search pill is tapped.
/// [pending] stays true until the Search screen consumes it, so a request
/// made before the (lazily built) Search page exists is still honoured.
typedef SearchFocusRequest = ({int tick, bool clear, bool pending});

final searchFocusRequestProvider =
    NotifierProvider<SearchFocusController, SearchFocusRequest>(
      SearchFocusController.new,
    );

class SearchFocusController extends Notifier<SearchFocusRequest> {
  @override
  SearchFocusRequest build() => (tick: 0, clear: false, pending: false);

  /// [clear]: re-tapping the active Search tab clears the text (doc 04 §4.4).
  void request({bool clear = false}) =>
      state = (tick: state.tick + 1, clear: clear, pending: true);

  /// Called by the Search screen once it has focused the field.
  void consume() {
    if (state.pending) {
      state = (tick: state.tick, clear: false, pending: false);
    }
  }
}
