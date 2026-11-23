import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/content.dart';
import '../../core/settings/history.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/prose_text.dart';
import '../../core/widgets/trust/trust.dart';
import '../../l10n/app_localizations.dart';
import 'content_widgets.dart';
import 'package_facts.dart';
import 'section_ui.dart';

/// Full item page.
///
/// * `type == package` → dedicated package layout: price hero, metric tiles,
///   subscription-code row, details table, conditions, status, sources.
/// * everything else → Answer Card, facts, body, steps checklist, sources.
class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  bool _recorded = false;

  void _record() {
    if (_recorded) return;
    _recorded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(recentItemsProvider.notifier).add(widget.itemId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final async = ref.watch(contentProvider);
    final library = async.value;
    final item = library?.byId(widget.itemId);

    if (item == null) {
      return PageScaffold(
        title: library == null ? '' : l10n.detailNotFound,
        children: [
          if (library == null)
            const ContentLoading()
          else
            PlaceholderPanel(
              icon: AppIcons.emptySearch,
              title: l10n.detailNotFound,
              body: l10n.detailNotFoundBody,
            ),
        ],
      );
    }
    _record();

    final related = [for (final id in item.related) ?library!.byId(id)];
    final isPackage = item.type == ItemType.package;

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.titleEn != null) ...[
          LtrText(
            item.titleEn!,
            style: AppTypography.bodyM.copyWith(color: c.textTertiary),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ContentStatusPill(item.status, official: item.officiallyVerified),
            _SectionTag(section: item.section, category: item.category),
          ],
        ),
      ],
    );

    final tail = <Widget>[
      if (item.sources.isNotEmpty || item.pdfPages.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(l10n.detailSourcesTitle),
        const SizedBox(height: AppSpacing.sm),
        _Sources(item: item),
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
    ];

    return PageScaffold(
      scrollKey: const ValueKey('item-detail-scroll'),
      title: item.title,
      titleIsProse: true,
      titleStyle: Theme.of(context).textTheme.headlineLarge,
      header: header,
      children: [
        ...(isPackage
            ? _packageBody(context, item)
            : _genericBody(context, item)),
        ...tail,
      ],
    );
  }

  List<Widget> _conflict(BuildContext context, ContentItem item) {
    final c = context.colors;
    return [
      ConflictBanner(
        key: const ValueKey('conflict-banner'),
        entries: [
          for (final f in item.facts.where((f) => f.kind.isLtr).take(4))
            ConflictEntry(value: f.display, sourceName: f.label),
        ],
      ),
      if (item.statusNote != null) ...[
        const SizedBox(height: AppSpacing.xs),
        ProseText(
          item.statusNote!,
          style: AppTypography.bodyM.copyWith(color: c.textSecondary),
        ),
      ],
      const SizedBox(height: AppSpacing.md),
    ];
  }

  List<Widget> _packageBody(BuildContext context, ContentItem item) {
    final l10n = AppLocalizations.of(context);
    final pf = PackageFacts.of(item);
    final metrics = pf.metrics;
    final code =
        pf.code?.value ?? (item.codes.isNotEmpty ? item.codes.first : null);
    return [
      if (item.status == ItemStatus.conflict) ..._conflict(context, item),
      // Price + subscription code together: the two things quoted first.
      PackagePriceHero(
        item: item,
        facts: pf,
        code: code,
        codeLabel: pf.code?.label ?? l10n.packageCodeTitle,
      ),
      if (metrics.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.sm),
        PackageMetrics(metrics: metrics),
      ],
      if (item.facts.length > 1) ...[
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(l10n.packageDetailsTitle),
        const SizedBox(height: AppSpacing.sm),
        _FactsTable(facts: item.facts),
      ],
      if (item.body != null) ...[
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(l10n.packageNotesTitle),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          role: CardRole.flat,
          child: _Body(text: item.body!),
        ),
      ],
      if (item.steps.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(l10n.detailStepsTitle),
        const SizedBox(height: AppSpacing.sm),
        _StepsChecklist(steps: item.steps),
      ],
      if (item.status == ItemStatus.unconfirmed) ...[
        const SizedBox(height: AppSpacing.xl),
        UnconfirmedBanner(note: item.statusNote),
      ],
    ];
  }

  List<Widget> _genericBody(BuildContext context, ContentItem item) {
    final l10n = AppLocalizations.of(context);
    return [
      if (item.status == ItemStatus.conflict)
        ..._conflict(context, item)
      else if (item.status == ItemStatus.unconfirmed) ...[
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
        SectionHeader(l10n.detailOverviewTitle),
        const SizedBox(height: AppSpacing.sm),
        _Body(text: item.body!),
      ],
      if (item.steps.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(l10n.detailStepsTitle),
        const SizedBox(height: AppSpacing.sm),
        _StepsChecklist(steps: item.steps),
      ],
    ];
  }
}

/// Section icon + "section · category" tag under a detail title.
class _SectionTag extends StatelessWidget {
  const _SectionTag({required this.section, required this.category});

  final ContentSection section;
  final String category;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tone = section.tone(context);
    final text = category.isEmpty
        ? section.title(l10n)
        : '${section.title(l10n)} · $category';
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xs,
        AppSpacing.xxs + 1,
        AppSpacing.sm,
        AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: tone.container,
        borderRadius: AppRadius.fullAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CategoryIcons.of(section, category),
            size: AppIconSize.inline,
            color: tone.foreground,
          ),
          const SizedBox(width: AppSpacing.xxs + 2),
          Flexible(
            child: Text(
              text,
              style: AppTypography.labelS.copyWith(color: tone.foreground),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Package layout
// ---------------------------------------------------------------------------

/// Price hero: the bundle price very large (tabular, LTR digits) with its
/// unit, the label it came with, and the tax-basis / recharge line under it.
/// For a conflicting price no single value is shown (doc 04 §5.4).
class PackagePriceHero extends StatelessWidget {
  const PackagePriceHero({
    super.key,
    required this.item,
    required this.facts,
    this.code,
    this.codeLabel,
  });

  final ContentItem item;
  final PackageFacts facts;

  /// Subscription code shown inside the hero (with copy), if any.
  final String? code;
  final String? codeLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final price = facts.price;
    final recharge = facts.rechargePrice;
    final conflict = item.status == ItemStatus.conflict;

    final Widget priceBlock;
    if (conflict) {
      priceBlock = Text(
        l10n.packageConflictPrice,
        key: const ValueKey('package-price-conflict'),
        style: AppTypography.titleL.copyWith(
          color: context.trustColors.conflict.foreground,
        ),
      );
    } else if (price != null && !price.rendersLtr) {
      priceBlock = ProseText(
        price.display,
        key: const ValueKey('package-price'),
        style: AppTypography.headlineL.copyWith(color: c.textPrimary),
      );
    } else if (price == null) {
      priceBlock = Text(
        l10n.packageNoPrice,
        style: AppTypography.titleM.copyWith(color: c.textSecondary),
      );
    } else {
      priceBlock = Semantics(
        label: '${price.label}: ${price.display}',
        excludeSemantics: true,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            key: const ValueKey('package-price'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              LtrText(
                price.value,
                style: AppTypography.priceHero.copyWith(color: c.textPrimary),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                price.unit ?? l10n.currencyEgp,
                style: AppTypography.titleL.copyWith(color: c.accentText),
              ),
            ],
          ),
        ),
      );
    }

    return AppCard(
      key: const ValueKey('package-hero'),
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      role: CardRole.hero,
      borderColor: c.primary.withValues(alpha: 0.18),
      gradient: LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: [c.heroGradientStart, c.surfaceElevated],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.price, size: AppIconSize.chip, color: c.primary),
              const SizedBox(width: AppSpacing.xs - 2),
              Expanded(
                child: Text(
                  price?.label ?? l10n.packagePriceLabel,
                  style: AppTypography.labelL.copyWith(color: c.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          priceBlock,
          if (recharge != null && !conflict) ...[
            const SizedBox(height: AppSpacing.sm),
            _TaxLine(fact: recharge),
          ],
          if (code != null) ...[
            const SizedBox(height: AppSpacing.sm),
            SubscriptionCodeRow(
              code: code!,
              label: codeLabel ?? l10n.packageCodeTitle,
            ),
          ],
          if (item.summary.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Divider(color: c.hairline, height: 1),
            const SizedBox(height: AppSpacing.md),
            ProseText(
              item.summary,
              style: AppTypography.bodyM.copyWith(color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _TaxLine extends StatelessWidget {
  const _TaxLine({required this.fact});

  final Fact fact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      key: const ValueKey('package-tax-line'),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: c.isDark ? 0.5 : 0.75),
        borderRadius: AppRadius.smAll,
        border: Border.all(color: c.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 2),
            child: Icon(
              AppIcons.recharge,
              size: AppIconSize.inline,
              color: c.textTertiary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Wrap(
              spacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  fact.label,
                  style: AppTypography.bodyM.copyWith(color: c.textSecondary),
                ),
                _InlineValue(
                  fact: fact,
                  style: AppTypography.titleM.copyWith(
                    color: c.textPrimary,
                    fontFeatures: AppTypography.tabular,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Value (LTR) + unit as separate runs, so units read naturally in RTL.
class _InlineValue extends StatelessWidget {
  const _InlineValue({required this.fact, required this.style});

  final Fact fact;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (!fact.rendersLtr) return Text(fact.display, style: style);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(child: LtrText(fact.value, style: style)),
        if (fact.unit != null) ...[
          const SizedBox(width: 3),
          Text(
            fact.unit!,
            style: AppTypography.labelL.copyWith(color: c.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// Key metrics (quota, validity, renewal, after-bundle) as a 2-column grid of
/// tiles that grow with text scale.
class PackageMetrics extends StatelessWidget {
  const PackageMetrics({super.key, required this.metrics});

  final List<(PackageFactRole, Fact)> metrics;

  static IconData iconFor(PackageFactRole role, Fact f) =>
      FactIcons.of(f, role);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      key: const ValueKey('package-metrics'),
      builder: (context, constraints) {
        const gap = AppSpacing.sm;
        final columns = constraints.maxWidth >= 560 ? 3 : 2;
        final w = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            // Numbers get compact 2-up tiles first; worded values follow,
            // each spanning the full row (no half-empty rows).
            for (final (role, f) in [
              ...metrics.where((m) => m.$2.rendersLtr),
              ...metrics.where((m) => !m.$2.rendersLtr),
            ])
              SizedBox(
                width: f.rendersLtr ? w : constraints.maxWidth,
                child: _MetricTile(role: role, fact: f),
              ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.role, required this.fact});

  final PackageFactRole role;
  final Fact fact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final icon = PackageMetrics.iconFor(role, fact);
    return AppCard(
      role: CardRole.sunken,
      key: ValueKey('metric-${role.name}'),
      padding: const EdgeInsetsDirectional.all(AppSpacing.md - 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TintedIcon(icon, tile: IconTile.sm),
          const SizedBox(height: AppSpacing.sm),
          if (fact.rendersLtr)
            Wrap(
              spacing: 3,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                LtrText(
                  fact.value,
                  style: AppTypography.metric.copyWith(color: c.textPrimary),
                ),
                if (fact.unit != null)
                  Text(
                    fact.unit!,
                    style: AppTypography.labelL.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
              ],
            )
          else
            ProseText(
              fact.display,
              style: AppTypography.titleM.copyWith(color: c.textPrimary),
            ),
          const SizedBox(height: 2),
          Text(
            fact.label,
            style: AppTypography.labelS.copyWith(color: c.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// Subscription-code row inside the price hero: big monospace LTR code +
/// filled copy button (one tap, ≤ 1.5 s confirmation — doc 04 P6).
class SubscriptionCodeRow extends StatelessWidget {
  const SubscriptionCodeRow({
    super.key,
    required this.code,
    required this.label,
  });

  final String code;
  final String label;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Container(
      key: const ValueKey('package-code'),
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: c.isDark ? 0.5 : 0.75),
        borderRadius: AppRadius.smAll,
        border: Border.all(color: c.hairline),
      ),
      child: Row(
        children: [
          Icon(AppIcons.code, size: AppIconSize.action, color: c.primaryUi),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelS.copyWith(color: c.textSecondary),
                ),
                // Whole code, always: scales down rather than clipping.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: LtrText(
                    code,
                    style: AppTypography.codeL.copyWith(color: c.textPrimary),
                    semanticsLabel: CodeText.spell(code, l10n),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton.filled(
            key: const ValueKey('package-code-copy'),
            tooltip: l10n.copyValueSemantics(code),
            style: IconButton.styleFrom(
              backgroundColor: c.capsuleSelected,
              foregroundColor: c.onCapsuleSelected,
              minimumSize: const Size(48, 48),
            ),
            icon: const Icon(AppIcons.copy, size: AppIconSize.action),
            onPressed: () => CodeText.copyToClipboard(context, code),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generic layout
// ---------------------------------------------------------------------------

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    final facts = item.facts.take(4).toList();

    return AppCard(
      key: const ValueKey('answer-card'),
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      role: CardRole.hero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.summary.isNotEmpty)
            ProseText(item.summary, style: theme.textTheme.bodyLarge),
          for (final (i, f) in facts.indexed) ...[
            // Hairlines separate answers; none above the first one.
            if (i > 0 || item.summary.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Divider(color: c.hairline, height: 1),
              const SizedBox(height: AppSpacing.sm),
            ],
            Row(
              children: [
                Icon(
                  FactIcons.of(f),
                  size: AppIconSize.inline,
                  color: c.primaryUi,
                ),
                const SizedBox(width: AppSpacing.xs - 2),
                Expanded(
                  child: Text(
                    f.label,
                    style: AppTypography.labelS.copyWith(color: c.textTertiary),
                  ),
                ),
              ],
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
    switch (fact.kind) {
      case FactKind.code:
        return CodeText(fact.value);
      case FactKind.phone:
        return CodeText(
          fact.value,
          onCall: (_) => showCallPlaceholder(context),
        );
      case _ when !fact.rendersLtr:
        return ProseText(
          fact.display,
          style: (large ? AppTypography.titleM : AppTypography.bodyM).copyWith(
            color: c.textPrimary,
          ),
        );
      default:
        final style = (large ? AppTypography.price : AppTypography.titleM)
            .copyWith(
              color: c.textPrimary,
              fontFeatures: AppTypography.tabular,
            );
        return Wrap(
          spacing: AppSpacing.xxs,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            LtrText(fact.value, style: style),
            if (fact.unit != null)
              Text(
                fact.unit!,
                style: AppTypography.bodyM.copyWith(
                  color: fact.kind == FactKind.price
                      ? c.accentText
                      : c.textSecondary,
                ),
              ),
          ],
        );
    }
  }
}

/// Label / value table with hairline separators.
class _FactsTable extends StatelessWidget {
  const _FactsTable({required this.facts});

  final List<Fact> facts;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      role: CardRole.flat,
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
                  // Leading icon by fact kind / meaning.
                  Icon(
                    FactIcons.of(facts[i]),
                    size: AppIconSize.action,
                    color: c.primaryUi,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 5,
                    child: Text(
                      facts[i].label,
                      style: AppTypography.bodyM.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(flex: 6, child: _FactValue(fact: facts[i])),
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
                start: AppSpacing.xxs,
                bottom: AppSpacing.xs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 10),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: c.primaryUi,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
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
      children.add(const SizedBox(height: AppSpacing.xxs));
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
      role: CardRole.flat,
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

class _Sources extends StatelessWidget {
  const _Sources({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return AppCard(
      role: CardRole.flat,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            const SizedBox(height: AppSpacing.sm),
          ],
          if (item.pdfPages.isNotEmpty)
            Row(
              children: [
                Icon(
                  AppIcons.pdf,
                  size: AppIconSize.inline,
                  color: c.textTertiary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    l10n.detailPdfPages(item.pdfPages.join('، ')),
                    key: const ValueKey('pdf-pages'),
                    style: AppTypography.bodyM.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
