import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/user/json_store.dart';
import 'training_deck.dart';

/// Leitner state of one card.
@immutable
class CardState {
  const CardState({
    required this.box,
    required this.dueDay,
    required this.answerHash,
    this.seen = 0,
    this.wrong = 0,
  });

  /// 1 to 5.
  final int box;

  /// [epochDay] on which it comes back.
  final int dueDay;
  final String answerHash;
  final int seen;
  final int wrong;

  List<Object> toJson() => [box, dueDay, answerHash, seen, wrong];

  static CardState? tryParse(Object? j) {
    if (j is! List || j.length != 5) return null;
    final [box, due, hash, seen, wrong] = j;
    if (box is! int || due is! int || hash is! String) return null;
    if (seen is! int || wrong is! int) return null;
    return CardState(
      box: box.clamp(1, Leitner.boxes),
      dueDay: due,
      answerHash: hash,
      seen: seen,
      wrong: wrong,
    );
  }
}

abstract final class Leitner {
  static const int boxes = 5;

  /// Days until a card of box 1…5 comes back.
  static const List<int> waitDays = [1, 2, 4, 8, 16];

  /// Right answer: next box. Wrong answer: back to box 1.
  static CardState answer(
    CardState? old, {
    required bool correct,
    required int day,
    required String answerHash,
  }) {
    final known = old != null && old.answerHash == answerHash ? old : null;
    final box = correct ? ((known?.box ?? 0) + 1).clamp(1, boxes) : 1;
    return CardState(
      box: box,
      dueDay: day + waitDays[box - 1],
      answerHash: answerHash,
      seen: (known?.seen ?? 0) + 1,
      wrong: (known?.wrong ?? 0) + (correct ? 0 : 1),
    );
  }
}

enum CardLevel { fresh, learning, mastered }

@immutable
class TrainingProgress {
  const TrainingProgress({
    this.cards = const {},
    this.dailyDay,
    this.dailyCardId,
    this.dailyChoice,
  });

  final Map<String, CardState> cards;

  /// The day the daily question was answered, its card and the choice.
  final int? dailyDay;
  final String? dailyCardId;
  final String? dailyChoice;

  /// State of [c], or `null` when new (or when its answer has changed).
  CardState? stateOf(TrainingCard c) {
    final s = cards[c.id];
    return s != null && s.answerHash == c.answerHash ? s : null;
  }

  CardLevel levelOf(TrainingCard c) {
    final s = stateOf(c);
    if (s == null) return CardLevel.fresh;
    return s.box >= Leitner.boxes ? CardLevel.mastered : CardLevel.learning;
  }

  int count(TrainingDeck deck, CardLevel level) =>
      deck.cards.where((c) => levelOf(c) == level).length;

  List<TrainingCard> due(TrainingDeck deck, int day) => [
    for (final c in deck.cards)
      if (stateOf(c) case final s? when s.dueDay <= day) c,
  ]..sort((a, b) => stateOf(a)!.box.compareTo(stateOf(b)!.box));

  /// Cards for one sitting: what is due, then some new ones.
  List<TrainingCard> session(
    TrainingDeck deck,
    int day, {
    int limit = 20,
    int newCards = 10,
  }) {
    final d = due(deck, day).take(limit).toList();
    final fresh = deck.cards.where((c) => levelOf(c) == CardLevel.fresh);
    return [...d, ...fresh.take(newCards.clamp(0, limit - d.length))];
  }

  /// Topics with the largest share of wrong answers (at least 3 answers and
  /// one mistake), worst first.
  List<({String topic, int seen, int wrong})> weakest(
    TrainingDeck deck, {
    int limit = 3,
  }) {
    final seen = <String, int>{}, wrong = <String, int>{};
    for (final c in deck.cards) {
      final s = stateOf(c);
      if (s == null) continue;
      seen[c.topic] = (seen[c.topic] ?? 0) + s.seen;
      wrong[c.topic] = (wrong[c.topic] ?? 0) + s.wrong;
    }
    final list = [
      for (final e in seen.entries)
        if (e.value >= 3 && wrong[e.key]! > 0)
          (topic: e.key, seen: e.value, wrong: wrong[e.key]!),
    ];
    list.sort((a, b) {
      final r = (b.wrong / b.seen).compareTo(a.wrong / a.seen);
      return r != 0 ? r : a.topic.compareTo(b.topic);
    });
    return list.take(limit).toList();
  }
}

/// Training progress, only on this device.
final trainingProgressProvider =
    NotifierProvider<TrainingProgressNotifier, TrainingProgress>(
      TrainingProgressNotifier.new,
    );

class TrainingProgressNotifier extends Notifier<TrainingProgress> {
  @override
  TrainingProgress build() {
    final doc = readJsonDoc(ref, UserKeys.training);
    if (doc is! Map) return const TrainingProgress();
    final cards = <String, CardState>{};
    if (doc['cards'] case final Map<dynamic, dynamic> m) {
      for (final e in m.entries) {
        final s = CardState.tryParse(e.value);
        if (s != null) cards['${e.key}'] = s;
      }
    }
    final d = doc['daily'];
    return TrainingProgress(
      cards: cards,
      dailyDay: d is List && d.length == 3 && d[0] is int ? d[0] as int : null,
      dailyCardId: d is List && d.length == 3 ? '${d[1]}' : null,
      dailyChoice: d is List && d.length == 3 ? '${d[2]}' : null,
    );
  }

  int get _day => epochDay(ref.read(clockProvider)());

  void answer(TrainingCard c, {required bool correct}) {
    _set(
      TrainingProgress(
        cards: _answered(c, correct),
        dailyDay: state.dailyDay,
        dailyCardId: state.dailyCardId,
        dailyChoice: state.dailyChoice,
      ),
    );
  }

  /// Once a day; later calls on the same day are ignored.
  void answerDaily(QuizQuestion q, String choice) {
    if (state.dailyDay == _day) return;
    _set(
      TrainingProgress(
        cards: _answered(q.card, choice == q.card.answer),
        dailyDay: _day,
        dailyCardId: q.card.id,
        dailyChoice: choice,
      ),
    );
  }

  void reset() => _set(const TrainingProgress());

  Map<String, CardState> _answered(TrainingCard c, bool correct) => {
    ...state.cards,
    c.id: Leitner.answer(
      state.cards[c.id],
      correct: correct,
      day: _day,
      answerHash: c.answerHash,
    ),
  };

  void _set(TrainingProgress next) {
    state = next;
    writeJsonDoc(ref, UserKeys.training, {
      'cards': {for (final e in next.cards.entries) e.key: e.value.toJson()},
      if (next.dailyDay != null)
        'daily': [next.dailyDay, next.dailyCardId, next.dailyChoice],
    });
  }
}
