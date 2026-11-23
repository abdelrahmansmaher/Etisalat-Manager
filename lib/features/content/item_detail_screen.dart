import 'package:flutter/material.dart';

import '../../core/widgets/prose_text.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/content.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/trust/trust.dart';
import '../../l10n/app_localizations.dart';
import 'content_widgets.dart';
import 'section_ui.dart';

/// Full item: Answer Card, status banner, facts, body, steps, sources,
/// guide pages, related items, disclaimer.
class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = context.colors;
    final async = ref.watch(contentProvider);
    final library = async.value;
    final item = library?.byId(itemId);
    final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: library == null
            ? const ContentLoading()
            : Padding(
                padding: EdgeInsets.all(pad),
                child: PlaceholderPanel(
                  icon: Icons.search_off_rounded,
                  title: l10n.detailNotFound,
                  body: l10n.detailNotFoundBody,
                ),
              ),
      );
    }

    final related = [for (final id in item.related) ?library!.byId(id)];

    return Scaffold(
      appBar: AppBar(title: Text(item.section.title(l10n))),
      body: ListView(
        key: const ValueKey('item-detail-scroll'),
        padding: EdgeInsetsDirectional.fromSTEB(
          pad,
          AppSpacing.sm,
          pad,
          AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          ProseText(item.title, style: theme.textTheme.headlineMedium),
          if (item.titleEn != null)
            LtrText(
              item.titleEn!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: c.textTertiary,
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ContentStatusPill(item.status),
              if (item.category.isNotEmpty)
                Text(
                  item.category,
                  style: AppTypography.labelS.copyWith(color: c.textTertiary),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (item.status == ItemStatus.conflict) ...[
            ConflictBanner(
              key: const ValueKey('conflict-banner'),
              entries: [
                for (final f in item.facts.where((f) => f.kind.isLtr).take(4))
                  ConflictEntry(value: f.display, sourceName: f.label),
              ],
            ),
            if (item.statusNote != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.statusNote!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
          ] else if (item.status == ItemStatus.unconfirmed) ...[
            UnconfirmedBanner(note: item.statusNote),
            const SizedBox(height: AppSpacing.md),
          ],
          _AnswerCard(item: item),
          if (item.facts.length > 4) ...[
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(l10n.detailFactsTitle),
            const SizedBox(height: AppSpacing.sm),
            _FactsTable(facts: item.facts),
          ],
          if (item.body != null) ...[
            const SizedBox(height: AppSpacing.xl),
            _Body(text: item.body!),
          ],
          if (item.steps.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(l10n.detailStepsTitle),
            const SizedBox(height: AppSpacing.sm),
            _StepsChecklist(steps: item.steps),
          ],
          if (item.sources.isNotEmpty || item.pdfPages.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(l10n.detailSourcesTitle),
            const SizedBox(height: AppSpacing.sm),
            for (final s in item.sources) ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: SourceBadge(sourceName: s.name, type: s.type.trustType),
              ),
              if (s.url != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: AppSpacing.xs,
                    top: AppSpacing.xxs,
                  ),
                  child: LtrText(
                    s.url!,
                    style: AppTypography.labelS.copyWith(color: c.textTertiary),
                  ),
                ),
              const SizedBox(height: AppSpacing.xs),
            ],
            if (item.pdfPages.isNotEmpty)
              Text(
                l10n.detailPdfPages(item.pdfPages.join('، ')),
                key: const ValueKey('pdf-pages'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: c.textSecondary,
                ),
              ),
          ],
          if (related.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(l10n.detailRelatedTitle),
            const SizedBox(height: AppSpacing.sm),
            for (final r in related) ...[
              ContentItemRow(item: r, showSection: r.section != item.section),
              const SizedBox(height: AppSpacing.cardGap),
            ],
          ],
          const SizedBox(height: AppSpacing.xl),
          const UnofficialDisclaimer.compact(),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = context.colors;
    final facts = item.facts.take(4).toList();

    return AppCard(
      key: const ValueKey('answer-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TintedIcon(item.section.icon, size: 32),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  l10n.answerCardTitle,
                  style: AppTypography.labelL.copyWith(color: c.primary),
                ),
              ),
            ],
          ),
          if (item.summary.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ProseText(item.summary, style: theme.textTheme.bodyLarge),
          ],
          for (final f in facts) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              f.label,
              style: AppTypography.labelS.copyWith(color: c.textTertiary),
            ),
            const SizedBox(height: AppSpacing.xxs),
            _FactValue(fact: f, large: true),
          ],
          if (facts.isEmpty)
            for (final v in [...item.codes, ...item.phones]) ...[
              const SizedBox(height: AppSpacing.sm),
              CodeText(
                v,
                onCall: item.phones.contains(v)
                    ? (_) => showCallPlaceholder(context)
                    : null,
              ),
            ],
        ],
      ),
    );
  }
}

class _FactValue extends StatelessWidget {
  const _FactValue({required this.fact, this.large = false});

  final Fact fact;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = (large ? AppTypography.price : AppTypography.titleM).copyWith(
      color: c.textPrimary,
    );
    switch (fact.kind) {
      case FactKind.code:
        return CodeText(fact.value);
      case FactKind.phone:
        return CodeText(
          fact.value,
          onCall: (_) => showCallPlaceholder(context),
        );
      case FactKind.text:
        return Text(fact.display, style: large ? AppTypography.titleM : null);
      default:
        return Wrap(
          spacing: AppSpacing.xxs,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            LtrText(fact.value, style: style),
            if (fact.unit != null)
              Text(
                fact.unit!,
                style: AppTypography.bodyM.copyWith(color: c.textSecondary),
              ),
          ],
        );
    }
  }
}

class _FactsTable extends StatelessWidget {
  const _FactsTable({required this.facts});

  final List<Fact> facts;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      key: const ValueKey('facts-table'),
      padding: EdgeInsetsDirectional.zero,
      child: Column(
        children: [
          for (var i = 0; i < facts.length; i++)
            Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                border: i == 0
                    ? null
                    : Border(top: BorderSide(color: c.hairline)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      facts[i].label,
                      style: AppTypography.bodyM.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _FactValue(fact: facts[i])),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// `body_ar`: paragraphs split by blank lines; lines starting "- " are
/// bullets.
class _Body extends StatelessWidget {
  const _Body({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    final children = <Widget>[];
    for (final para in text.split(RegExp(r'\n\s*\n'))) {
      for (final line in para.split('\n')) {
        final t = line.trim();
        if (t.isEmpty) continue;
        if (t.startsWith('- ')) {
          children.add(
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: AppSpacing.xs,
                bottom: AppSpacing.xxs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 9),
                    child: Icon(Icons.circle, size: 6, color: c.primary),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: ProseText(
                      t.substring(2),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          children.add(
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
              child: ProseText(t, style: theme.textTheme.bodyLarge),
            ),
          );
        }
      }
      children.add(const SizedBox(height: AppSpacing.xs));
    }
    return Column(
      key: const ValueKey('item-body'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _StepsChecklist extends StatefulWidget {
  const _StepsChecklist({required this.steps});

  final List<String> steps;

  @override
  State<_StepsChecklist> createState() => _StepsChecklistState();
}

class _StepsChecklistState extends State<_StepsChecklist> {
  final Set<int> _done = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    return AppCard(
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (var i = 0; i < widget.steps.length; i++)
            CheckboxListTile(
              key: ValueKey('step-$i'),
              value: _done.contains(i),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (v) =>
                  setState(() => v == true ? _done.add(i) : _done.remove(i)),
              title: ProseText(
                '${i + 1}. ${widget.steps[i]}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: _done.contains(i) ? c.textTertiary : null,
                  decoration: _done.contains(i)
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
