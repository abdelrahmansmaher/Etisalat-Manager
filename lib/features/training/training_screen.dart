import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/user/user.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/list_surface.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/prose_text.dart';
import '../../l10n/app_localizations.dart';
import '../tools/tool_widgets.dart';
import 'training_deck.dart';
import 'training_progress.dart';

String trainingPrompt(AppLocalizations l10n, TrainingCard card) =>
    switch (card.kind) {
      CardKind.price || CardKind.total || CardKind.validity =>
        l10n.trainingAskFact(card.item.title, card.label),
      CardKind.code => l10n.trainingAskCode(card.item.title),
      CardKind.phone => l10n.trainingAskPhone(card.item.title),
      CardKind.term => l10n.trainingAskTerm(card.item.title),
      CardKind.documents => l10n.trainingAskDocuments(card.item.title),
      CardKind.firstStep => l10n.trainingAskFirstStep(card.item.title),
      CardKind.scenario => l10n.trainingAskScenario(card.item.title),
    };

/// Interactive counter training hub: daily question, spaced-repetition
/// flashcards, multiple-choice quiz, and branch scenarios.
class TrainingScreen extends ConsumerWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final deck = ref.watch(trainingDeckProvider);
    final progress = ref.watch(trainingProgressProvider);
    final today = ref.watch(clockProvider)();
    final day = epochDay(today);

    if (deck.cards.isEmpty) {
      return PageScaffold(
        title: l10n.trainingTitle,
        children: [
          PlaceholderPanel(
            icon: AppIcons.training,
            title: l10n.trainingNothing,
            body: l10n.trainingNothingBody,
          ),
        ],
      );
    }

    final daily = deck.daily(today);
    final due = progress.due(deck, day);
    final fresh = progress.count(deck, CardLevel.fresh);
    final learning = progress.count(deck, CardLevel.learning);
    final mastered = progress.count(deck, CardLevel.mastered);
    final weakest = progress.weakest(deck);
    final quiz = deck.quiz(ref.read(trainingRandomProvider));
    final scenarios = deck.scenarios;

    return PageScaffold(
      title: l10n.trainingTitle,
      subtitle: l10n.trainingIntro,
      children: [
        if (daily != null) ...[
          _DailyCard(question: daily, day: day),
          const SizedBox(height: AppSpacing.md),
        ],
        SectionHeader(l10n.trainingLevel),
        const SizedBox(height: AppSpacing.xs),
        AppCard(
          role: CardRole.flat,
          child: Column(
            children: [
              Row(
                children: [
                  _LevelStat(
                    label: l10n.trainingMastered,
                    count: mastered,
                    color: c.verified,
                  ),
                  _LevelStat(
                    label: l10n.trainingLearning,
                    count: learning,
                    color: c.primary,
                  ),
                  _LevelStat(
                    label: l10n.trainingNew,
                    count: fresh,
                    color: c.textSecondary,
                  ),
                ],
              ),
              if (mastered > 0 || learning > 0) ...[
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () async {
                      final ok = await askToConfirm(
                        context,
                        title: l10n.trainingReset,
                        body: l10n.trainingResetAsk,
                        confirm: l10n.toolsDelete,
                      );
                      if (ok) {
                        ref.read(trainingProgressProvider.notifier).reset();
                      }
                    },
                    child: Text(l10n.trainingReset),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ListSurface(
          children: [
            _ModeRow(
              icon: AppIcons.trainCards,
              title: l10n.trainingCards,
              subtitle: l10n.trainingCardsDue(due.length, fresh),
              onTap: () {
                final session = progress.session(deck, day);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _FlashcardsSession(cards: session),
                  ),
                );
              },
            ),
            if (quiz.isNotEmpty)
              _ModeRow(
                icon: AppIcons.trainQuiz,
                title: l10n.trainingQuiz,
                subtitle: l10n.trainingQuizCount(quiz.length),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _QuizSession(questions: quiz),
                  ),
                ),
              ),
            if (scenarios.isNotEmpty)
              _ModeRow(
                icon: AppIcons.trainScenario,
                title: l10n.trainingScenarios,
                subtitle: l10n.trainingScenariosCount(scenarios.length),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _ScenariosView(scenarios: scenarios),
                  ),
                ),
              ),
          ],
        ),
        if (weakest.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          SectionHeader(l10n.trainingWeakest),
          const SizedBox(height: AppSpacing.xs),
          ListSurface(
            children: [
              for (final w in weakest)
                ListTile(
                  title: Text(w.topic, style: AppTypography.titleS),
                  trailing: Text(
                    l10n.trainingWeakRow(w.wrong, w.seen),
                    style: AppTypography.labelL.copyWith(color: c.error),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LevelStat extends StatelessWidget {
  const _LevelStat({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: AppTypography.headlineM.copyWith(
              color: color,
              fontFeatures: AppTypography.tabular,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelS.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeRow extends StatelessWidget {
  const _ModeRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            TintedIcon(icon, tile: IconTile.md),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleM.copyWith(color: c.textPrimary),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodyS.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              AppIcons.chevron,
              size: AppIconSize.action,
              color: c.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyCard extends ConsumerWidget {
  const _DailyCard({required this.question, required this.day});

  final QuizQuestion question;
  final int day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final progress = ref.watch(trainingProgressProvider);
    final answeredToday = progress.dailyDay == day;
    final picked = answeredToday ? progress.dailyChoice : null;

    return AppCard(
      role: CardRole.raised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              TintedIcon(AppIcons.trainDaily, tile: IconTile.sm),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  answeredToday ? l10n.trainingDailyDone : l10n.trainingDaily,
                  style: AppTypography.titleM.copyWith(color: c.primary),
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.push(ContentRoutes.item(question.card.item.id)),
                child: Text(l10n.trainingOpenItem),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ProseText(
            trainingPrompt(l10n, question.card),
            style: AppTypography.titleM.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final choice in question.choices) ...[
            _ChoiceButton(
              label: choice,
              state: !answeredToday
                  ? _ChoiceVisual.idle
                  : choice == question.card.answer
                  ? _ChoiceVisual.correct
                  : choice == picked
                  ? _ChoiceVisual.wrong
                  : _ChoiceVisual.dimmed,
              onTap: answeredToday
                  ? null
                  : () => ref
                        .read(trainingProgressProvider.notifier)
                        .answerDaily(question, choice),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

enum _ChoiceVisual { idle, correct, wrong, dimmed }

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.state,
    this.onTap,
  });

  final String label;
  final _ChoiceVisual state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg, border) = switch (state) {
      _ChoiceVisual.idle => (c.surfaceVariant, c.textPrimary, c.hairline),
      _ChoiceVisual.correct => (c.verifiedContainer, c.verified, c.verified),
      _ChoiceVisual.wrong => (c.errorContainer, c.onErrorContainer, c.error),
      _ChoiceVisual.dimmed => (c.surfaceVariant, c.textTertiary, c.hairline),
    };
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.smAll,
        side: BorderSide(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: ProseText(
            label,
            style: AppTypography.bodyM.copyWith(
              color: fg,
              fontWeight: state == _ChoiceVisual.correct
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _FlashcardsSession extends ConsumerStatefulWidget {
  const _FlashcardsSession({required this.cards});

  final List<TrainingCard> cards;

  @override
  ConsumerState<_FlashcardsSession> createState() => _FlashcardsSessionState();
}

class _FlashcardsSessionState extends ConsumerState<_FlashcardsSession> {
  int _index = 0;
  bool _revealed = false;

  void _answer(bool correct) {
    ref
        .read(trainingProgressProvider.notifier)
        .answer(widget.cards[_index], correct: correct);
    setState(() {
      _index++;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    if (widget.cards.isEmpty || _index >= widget.cards.length) {
      return PageScaffold(
        title: l10n.trainingCards,
        children: [
          PlaceholderPanel(
            icon: AppIcons.allReviewed,
            title: l10n.trainingDone,
            body: l10n.trainingDoneBody,
            action: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.trainingFinish),
            ),
          ),
        ],
      );
    }
    final card = widget.cards[_index];
    return PageScaffold(
      title: l10n.trainingCards,
      subtitle: l10n.trainingStep(_index + 1, widget.cards.length),
      actions: [
        TextButton(
          onPressed: () => context.push(ContentRoutes.item(card.item.id)),
          child: Text(l10n.trainingOpenItem),
        ),
      ],
      children: [
        AppCard(
          role: CardRole.raised,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                card.topic,
                style: AppTypography.labelS.copyWith(color: c.textTertiary),
              ),
              const SizedBox(height: AppSpacing.sm),
              ProseText(
                trainingPrompt(l10n, card),
                style: AppTypography.headlineM.copyWith(color: c.textPrimary),
              ),
              if (_revealed) ...[
                const SizedBox(height: AppSpacing.md),
                Divider(color: c.hairline, height: 1),
                const SizedBox(height: AppSpacing.md),
                ProseText(
                  card.answer,
                  style: AppTypography.titleL.copyWith(color: c.primary),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (!_revealed)
          FilledButton(
            onPressed: () => setState(() => _revealed = true),
            child: Text(l10n.trainingShowAnswer),
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _answer(false),
                  icon: Icon(AppIcons.toolMisses, color: c.error),
                  label: Text(l10n.trainingDidNot),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _answer(true),
                  icon: const Icon(AppIcons.toolMeets),
                  label: Text(l10n.trainingKnew),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _QuizSession extends ConsumerStatefulWidget {
  const _QuizSession({required this.questions});

  final List<QuizQuestion> questions;

  @override
  ConsumerState<_QuizSession> createState() => _QuizSessionState();
}

class _QuizSessionState extends ConsumerState<_QuizSession> {
  int _index = 0;
  String? _picked;
  int _right = 0;
  final List<TrainingCard> _wrong = [];

  void _pick(String choice) {
    if (_picked != null) return;
    final q = widget.questions[_index];
    final ok = choice == q.card.answer;
    ref
        .read(trainingProgressProvider.notifier)
        .answer(q.card, correct: ok);
    setState(() {
      _picked = choice;
      if (ok) {
        _right++;
      } else {
        _wrong.add(q.card);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    if (_index >= widget.questions.length) {
      return PageScaffold(
        title: l10n.trainingQuiz,
        children: [
          PlaceholderPanel(
            icon: AppIcons.allReviewed,
            title: l10n.trainingQuizResult(_right, widget.questions.length),
            body: _wrong.isEmpty
                ? l10n.trainingDoneBody
                : l10n.trainingReviewWrong,
            action: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.trainingFinish),
            ),
          ),
          if (_wrong.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ListSurface(
              children: [
                for (final card in _wrong)
                  ListTile(
                    title: ProseText(card.item.title),
                    subtitle: ProseText(card.answer),
                    trailing: Icon(AppIcons.chevron, color: c.textTertiary),
                    onTap: () =>
                        context.push(ContentRoutes.item(card.item.id)),
                  ),
              ],
            ),
          ],
        ],
      );
    }

    final q = widget.questions[_index];
    return PageScaffold(
      title: l10n.trainingQuiz,
      subtitle: l10n.trainingStep(_index + 1, widget.questions.length),
      children: [
        AppCard(
          role: CardRole.raised,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProseText(
                trainingPrompt(l10n, q.card),
                style: AppTypography.titleL.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final choice in q.choices) ...[
                _ChoiceButton(
                  label: choice,
                  state: _picked == null
                      ? _ChoiceVisual.idle
                      : choice == q.card.answer
                      ? _ChoiceVisual.correct
                      : choice == _picked
                      ? _ChoiceVisual.wrong
                      : _ChoiceVisual.dimmed,
                  onTap: _picked == null ? () => _pick(choice) : null,
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
            ],
          ),
        ),
        if (_picked != null) ...[
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () => setState(() {
              _index++;
              _picked = null;
            }),
            child: Text(
              _index + 1 < widget.questions.length
                  ? l10n.trainingNext
                  : l10n.trainingFinish,
            ),
          ),
        ],
      ],
    );
  }
}

class _ScenariosView extends StatelessWidget {
  const _ScenariosView({required this.scenarios});

  final List<TrainingCard> scenarios;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PageScaffold(
      title: l10n.trainingScenarios,
      children: [
        for (final s in scenarios) ...[
          _ScenarioTile(card: s),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _ScenarioTile extends StatefulWidget {
  const _ScenarioTile({required this.card});

  final TrainingCard card;

  @override
  State<_ScenarioTile> createState() => _ScenarioTileState();
}

class _ScenarioTileState extends State<_ScenarioTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return AppCard(
      role: CardRole.flat,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProseText(
            trainingPrompt(l10n, widget.card),
            style: AppTypography.titleM.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (_open) ...[
            Divider(color: c.hairline, height: 1),
            const SizedBox(height: AppSpacing.xs),
            ProseText(
              widget.card.answer,
              style: AppTypography.bodyM.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () =>
                    context.push(ContentRoutes.item(widget.card.item.id)),
                child: Text(l10n.trainingOpenItem),
              ),
            ),
          ] else
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => setState(() => _open = true),
                child: Text(l10n.trainingShowAnswer),
              ),
            ),
        ],
      ),
    );
  }
}
