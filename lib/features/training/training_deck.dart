import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/content.dart';
import '../../core/user/content_overrides.dart';
import '../content/package_facts.dart';
import '../content/package_family.dart';
import '../tools/dial_template.dart';

enum CardKind {
  price,
  total,
  code,
  phone,
  validity,
  term,
  documents,
  firstStep,

  /// "A customer comes with…": answered in your own words, never in a quiz.
  scenario,
}

/// One question made from one value of one item.
@immutable
class TrainingCard {
  const TrainingCard({
    required this.id,
    required this.item,
    required this.kind,
    required this.label,
    required this.answer,
    required this.family,
  });

  /// Stable across content updates (item + question, not the answer).
  final String id;
  final ContentItem item;
  final CardKind kind;

  /// Label of the fact the answer comes from.
  final String label;

  /// Exactly as the content states it.
  final String answer;
  final String family;

  /// What the weak-topics list groups by.
  String get topic =>
      item.category.isNotEmpty ? item.category : item.section.key;

  /// Changes when the content changes the answer: the card starts over.
  String get answerHash => hashText(answer);
}

/// A card with choices, all real values.
@immutable
class QuizQuestion {
  const QuizQuestion(this.card, this.choices);

  final TrainingCard card;
  final List<String> choices;

  int get correctIndex => choices.indexOf(card.answer);
}

class TrainingDeck {
  TrainingDeck._(this.cards);

  /// Builds the deck from confirmed content only.
  factory TrainingDeck.build(Iterable<ContentItem> items) {
    final out = <TrainingCard>[];
    for (final item in items) {
      if (eligible(item)) _addCards(out, item, familyOf(item));
    }
    // The same question with two different answers cannot be asked.
    final byQuestion = <String, Set<String>>{};
    String q(TrainingCard c) =>
        '${c.kind.name}|${c.label}|${c.item.title.trim()}';
    for (final c in out) {
      (byQuestion[q(c)] ??= {}).add(c.answer);
    }
    final ids = <String>{};
    return TrainingDeck._([
      for (final c in out)
        if (byQuestion[q(c)]!.length == 1 && ids.add(c.id)) c,
    ]);
  }

  final List<TrainingCard> cards;

  late final Map<String, TrainingCard> byId = {for (final c in cards) c.id: c};

  List<TrainingCard> get scenarios => [
    for (final c in cards)
      if (c.kind == CardKind.scenario) c,
  ];

  /// Confirmed and not edited by the owner (an edited item comes back once
  /// it is restored).
  static bool eligible(ContentItem item) =>
      item.status == ItemStatus.confirmed &&
      item.type != ItemType.unverified &&
      !item.userEdited &&
      _clean(item.title);

  static const _doubt = [
    'غير موكد',
    'غير مؤكد',
    'تعارض',
    'متعارض',
    'قديم',
    'غلط',
    'غير منشور',
    'غير مذكور',
    'راجع',
    'مثال',
    '؟',
  ];

  /// Nothing in [text] says the value is doubtful or outdated.
  static bool _clean(String text) {
    final n = PackageFacts.normalizeLabel(text);
    return n.trim().isNotEmpty &&
        !_doubt.any((w) => n.contains(PackageFacts.normalizeLabel(w)));
  }

  static bool _cleanFact(Fact f) =>
      !f.isBlank && _clean(f.label) && _clean(f.value);

  static void _addCards(
    List<TrainingCard> out,
    ContentItem item,
    String family,
  ) {
    void add(CardKind kind, String label, String answer) {
      if (answer.trim().isEmpty) return;
      out.add(
        TrainingCard(
          id: '${item.id}|${kind.name}',
          item: item,
          kind: kind,
          label: label,
          answer: answer.trim(),
          family: family,
        ),
      );
    }

    void addFact(CardKind kind, Fact? f) {
      if (f == null || !_cleanFact(f)) return;
      final digits = toAsciiDigits(f.value).replaceAll(',', '').trim();
      // The title already gives the answer away.
      if (RegExp(r'^[\d.]+$').hasMatch(digits) &&
          RegExp(
            '(^|[^\\d.])${RegExp.escape(digits)}(\$|[^\\d.])',
          ).hasMatch(toAsciiDigits(item.title).replaceAll(',', ''))) {
        return;
      }
      add(kind, f.label, f.display);
    }

    switch (item.type) {
      case ItemType.package:
        final f = PackageFacts.of(item);
        addFact(CardKind.price, f.price);
        addFact(CardKind.total, f.rechargePrice);
        addFact(CardKind.validity, f.validity);
        final code = f.code;
        if (code != null && _isOneCode(code.value)) {
          addFact(CardKind.code, code);
        }
      case ItemType.code:
        if (item.codes.length == 1 && _isOneCode(item.codes.first)) {
          add(CardKind.code, '', item.codes.first);
        }
      case ItemType.contact:
        final numbers = {
          for (final p in item.phones)
            toAsciiDigits(p).replaceAll(RegExp('[^0-9]'), ''),
        };
        if (numbers.length == 1 && numbers.first.length >= 3) {
          add(CardKind.phone, '', item.phones.first);
        }
      case ItemType.glossary:
        if (_clean(item.summary)) add(CardKind.term, '', item.summary);
      default:
        break;
    }

    for (final f in item.facts) {
      final l = PackageFacts.normalizeLabel(f.label);
      if ((l.contains('مستند') || l.contains('الاوراق')) &&
          f.kind == FactKind.text &&
          _cleanFact(f)) {
        add(CardKind.documents, f.label, f.value);
        break;
      }
    }
    if (item.steps.length >= 2 && _clean(item.steps.first)) {
      add(CardKind.firstStep, '', item.steps.first);
    }
    if (_isCase(item)) {
      final answer = item.steps.isNotEmpty
          ? [
              for (final (i, s) in item.steps.indexed) '${i + 1}. $s',
            ].join('\n')
          : item.summary;
      if (_clean(answer)) add(CardKind.scenario, '', answer);
    }
  }

  static bool _isOneCode(String v) {
    final t = DialTemplate.parseAll(v);
    return t.length == 1 && t.first.display == toAsciiDigits(v).trim();
  }

  static bool _isCase(ContentItem item) =>
      item.type == ItemType.procedure &&
      (item.section == ContentSection.wallet &&
              PackageFacts.normalizeLabel(item.category).contains('حالات') ||
          item.section == ContentSection.procedures);

  /// The card with three wrong choices taken from other real items: the same
  /// family first, then the same section. `null` when there are not enough.
  QuizQuestion? questionFor(TrainingCard card, Random random) {
    if (card.kind == CardKind.scenario) return null;
    final banned = {
      _key(card.answer),
      for (final c in card.item.codes) _key(c),
      for (final p in card.item.phones) _key(p),
    };
    final same = <String, String>{}, section = <String, String>{};
    for (final c in cards) {
      if (c.kind != card.kind || c.item.id == card.item.id) continue;
      final k = _key(c.answer);
      if (banned.contains(k)) continue;
      if (c.family == card.family) {
        same[k] = c.answer;
      } else if (c.item.section == card.item.section) {
        section[k] = c.answer;
      }
    }
    section.removeWhere((k, _) => same.containsKey(k));
    final pool = [
      ...same.values.toList()..shuffle(random),
      ...section.values.toList()..shuffle(random),
    ];
    if (pool.length < 3) return null;
    return QuizQuestion(
      card,
      [card.answer, ...pool.take(3)]..shuffle(random),
    );
  }

  /// Up to [count] questions on different cards.
  List<QuizQuestion> quiz(Random random, {int count = 10}) {
    final out = <QuizQuestion>[];
    for (final c in [...cards]..shuffle(random)) {
      if (out.length == count) break;
      final q = questionFor(c, random);
      if (q != null) out.add(q);
    }
    return out;
  }

  /// The same question all day, another one tomorrow.
  QuizQuestion? daily(DateTime day) {
    if (cards.isEmpty) return null;
    final sorted = [...cards]..sort((a, b) => a.id.compareTo(b.id));
    final n = epochDay(day);
    final random = Random(n);
    final start = random.nextInt(sorted.length);
    for (var i = 0; i < sorted.length; i++) {
      final q = questionFor(sorted[(start + i) % sorted.length], random);
      if (q != null) return q;
    }
    return null;
  }

  static String _key(String v) => toAsciiDigits(v)
      .replaceAll(RegExp(r'[\s,\u200E\u200F]'), '')
      .replaceAll('جنيه', 'ج');
}

int epochDay(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 86400000;

/// Rebuilt whenever the content (or an edit) changes.
final trainingDeckProvider = Provider<TrainingDeck>((ref) {
  return TrainingDeck.build(ref.watch(contentLibraryProvider).all);
});

/// Source of randomness; fixed in tests.
final trainingRandomProvider = Provider<Random>((ref) => Random());

