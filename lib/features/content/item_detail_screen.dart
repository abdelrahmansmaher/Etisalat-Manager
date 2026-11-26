import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../export/export_sheet.dart';
import 'item_summary.dart';
import '../../core/content/content.dart';
import '../../core/settings/history.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/capsules.dart';
import '../../core/widgets/list_surface.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/prose_text.dart';
import '../../core/widgets/sim_shape.dart';
import '../../l10n/app_localizations.dart';
import '../tools/dial.dart';
import '../tools/item_actions.dart';
import 'content_widgets.dart';
import 'package_family.dart';
import 'package_facts.dart';
import 'steps_progress.dart';

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

  /// Screen turned to the customer: price, code and terms only.
  bool _customer = false;

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

    final customer = _customer && item.type == ItemType.package;
    final related = [for (final id in item.related) ?library!.byId(id)];
    final isPackage = item.type == ItemType.package;

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The English name only when the app itself is in English.
        if (item.titleEn != null &&
            Localizations.localeOf(context).languageCode != 'ar')
          LtrText(
            item.titleEn!,
            style: AppTypography.bodyM.copyWith(color: c.textTertiary),
          ),
        if (!customer) ...[
          const SizedBox(height: AppSpacing.xxs),
          TrustLine(item),
        ],
      ],
    );

    final tail = <Widget>[
      if (customer) ...[
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Capsule(
            key: const ValueKey('customer-view-exit'),
            icon: AppIcons.customerViewOff,
            label: l10n.customerViewOff,
            onTap: () => setState(() => _customer = false),
          ),
        ),
      ] else ...[
        if (item.sources.isNotEmpty || item.pdfPages.isNotEmpty) ...[
          GroupHeader(l10n.detailSourcesTitle, icon: AppIcons.link),
          _Sources(item: item),
        ],
        if (related.isNotEmpty) ...[
          GroupHeader(l10n.detailRelatedTitle, icon: AppIcons.layers),
          ListSurface(
            children: [
              for (final r in related)
                ContentItemRow(item: r, showSection: r.section != item.section),
            ],
          ),
        ],
      ],
    ];

    return PageScaffold(
      scrollKey: const ValueKey('item-detail-scroll'),
      title: item.title,
      titleIsProse: true,
      header: header,
      actions: [
        if (isPackage)
          IconButton(
            key: const ValueKey('customer-view'),
            isSelected: customer,
            tooltip: customer ? l10n.customerViewOff : l10n.customerView,
            icon: Icon(
              customer ? AppIcons.customerViewOff : AppIcons.customerView,
            ),
            color: c.primary,
            onPressed: () => setState(() => _customer = !_customer),
          ),
        ExportButton(
          title: item.title,
          text: customerSummary(item),
          pdf: (pdf) => pdf.item(item),
        ),
        FavoriteButton(item.id),
      ],
      children: [
        if (item.status != ItemStatus.confirmed && !item.userEdited)
          _ReviewNote(item: item),
        ...(isPackage
            ? _packageBody(context, item, customer: customer)
            : _genericBody(context, item)),
        ...tail,
      ],
    );
  }

  List<Widget> _packageBody(
    BuildContext context,
    ContentItem item, {
    bool customer = false,
  }) {
    final l10n = AppLocalizations.of(context);
    final pf = PackageFacts.of(item);
    final metrics = pf.metrics;
    // Values already in the price panel and the tiles are not repeated.
    final details = pf.detailsOf(item);
    final code =
        pf.code?.value ?? (item.codes.isNotEmpty ? item.codes.first : null);
    return [
      // Price + subscription code together: the two things quoted first.
      PackagePriceHero(
        item: item,
        facts: pf,
        code: code,
        codeLabel: pf.code?.label ?? l10n.packageCodeTitle,
      ),
      if (!customer) ...[
        const SizedBox(height: AppSpacing.sm),
        ItemActions(item),
      ],
      if (metrics.isNotEmpty) ...[
        GroupHeader(l10n.packageIncludesTitle, icon: AppIcons.layers),
        PackageMetrics(metrics: metrics),
      ],
      if (details.isNotEmpty) ...[
        GroupHeader(l10n.packageDetailsTitle, icon: AppIcons.info),
        _FactsTable(facts: details),
      ],
      ..._bodyAndSteps(context, item, l10n.packageNotesTitle),
    ];
  }

  List<Widget> _genericBody(BuildContext context, ContentItem item) {
    final l10n = AppLocalizations.of(context);
    return [
      _AnswerCard(item: item),
      const SizedBox(height: AppSpacing.sm),
      ItemActions(item),
      if (item.facts.length > 4) ...[
        GroupHeader(l10n.detailFactsTitle, icon: AppIcons.info),
        _FactsTable(facts: item.facts),
      ],
      ..._bodyAndSteps(context, item, l10n.detailOverviewTitle),
    ];
  }

  List<Widget> _bodyAndSteps(
    BuildContext context,
    ContentItem item,
    String bodyTitle,
  ) {
    return [
      if (item.steps.isNotEmpty) ...[
        _StepsHeader(item: item),
        _StepsChecklist(item: item),
      ],
      if (item.body != null) ...[
        GroupHeader(bodyTitle, icon: AppIcons.note),
        AppCard(
          role: CardRole.flat,
          child: _Body(text: item.body!),
        ),
      ],
    ];
  }
}

/// Safety note of an item that is not confirmed: nothing is picked for the
/// customer.
class _ReviewNote extends StatelessWidget {
  const _ReviewNote({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.trustColors;
    final colors = item.status == ItemStatus.conflict
        ? t.conflict
        : t.needsReview;
    return Container(
      key: const ValueKey('review-note'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: AppRadius.smAll,
      ),
      child: ProseText(
        [?item.statusNote, l10n.unconfirmedBannerBody].join('\n'),
        style: AppTypography.bodyM.copyWith(color: colors.foreground),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Package layout
// ---------------------------------------------------------------------------

/// The SIM-shaped price panel: navy body, price in gold (tabular, whole),
/// the tax line and the subscription code. For a conflicting price no single
/// value is shown.
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

  /// Subscription code shown inside the panel (with copy and dial), if any.
  final String? code;
  final String? codeLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final price = facts.price;
    final recharge = facts.rechargePrice;
    final conflict = item.status == ItemStatus.conflict;
    final family = familyOf(item);

    final Widget priceBlock;
    if (conflict) {
      priceBlock = Text(
        l10n.packageConflictPrice,
        key: const ValueKey('package-price-conflict'),
        style: AppTypography.titleL.copyWith(color: c.onMasthead),
      );
    } else if (price != null && !price.rendersLtr) {
      priceBlock = ProseText(
        price.display,
        key: const ValueKey('package-price'),
        style: AppTypography.headlineL.copyWith(color: c.mastheadPrice),
      );
    } else if (price == null) {
      priceBlock = Text(
        l10n.packageNoPrice,
        style: AppTypography.titleM.copyWith(color: c.onMasthead),
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
                style: AppTypography.priceHero.copyWith(color: c.mastheadPrice),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                price.unit ?? l10n.currencyEgp,
                style: AppTypography.titleL.copyWith(color: c.mastheadPrice),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      key: const ValueKey('package-hero'),
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: simGlassDecoration(c, cut: 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Family and trust, like the brand line printed on a SIM.
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.xl),
            child: Row(
              children: [
                FamilyTile(family),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    family,
                    style: AppTypography.titleS.copyWith(
                      color: c.onMasthead,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            price?.label ?? l10n.packagePriceLabel,
            style: AppTypography.labelL.copyWith(color: c.onMastheadMuted),
          ),
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
          if (facts.metrics.isEmpty && item.summary.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ProseText(
              item.summary,
              style: AppTypography.bodyM.copyWith(color: c.onMastheadMuted),
            ),
          ],
        ],
      ),
    );
  }
}

/// The second price (what the customer recharges / pays with taxes), in
/// its own glass cell under the main price.
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
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: AppRadius.smAll,
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.recharge,
            size: AppIconSize.chip,
            color: c.mastheadPrice,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              fact.label,
              style: AppTypography.bodyM.copyWith(color: c.onMastheadMuted),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          _InlineValue(
            fact: fact,
            style: AppTypography.titleL.copyWith(
              color: c.mastheadPrice,
              fontFeatures: AppTypography.tabular,
              fontWeight: FontWeight.w800,
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
            style: AppTypography.labelL.copyWith(color: c.mastheadPrice),
          ),
        ],
      ],
    );
  }
}

/// What the package gives (quota, validity, renewal, after-bundle) as a
/// 2-column grid of tiles that grow with text scale.
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
        const gap = AppSpacing.xs;
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

/// One feature: a tinted icon, a short label and the value with its unit in
/// Arabic.
class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.role, required this.fact});

  final PackageFactRole role;
  final Fact fact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final icon = PackageMetrics.iconFor(role, fact);
    final unit = impliedUnit(fact);
    return AppCard(
      role: CardRole.flat,
      key: ValueKey('metric-${role.name}'),
      padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
      child: Row(
        crossAxisAlignment: fact.rendersLtr
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          TintedIcon(icon, tile: IconTile.sm),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shortFactLabel(fact.label),
                  style: AppTypography.labelS.copyWith(color: c.textTertiary),
                ),
                const SizedBox(height: 2),
                if (fact.rendersLtr)
                  Wrap(
                    spacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      LtrText(
                        fact.value,
                        style: AppTypography.metric.copyWith(
                          color: c.textPrimary,
                        ),
                      ),
                      if (unit != null)
                        Text(
                          unit,
                          style: AppTypography.labelL.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                    ],
                  )
                else
                  ProseText(
                    fact.display,
                    style: AppTypography.titleS.copyWith(color: c.textPrimary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Subscription-code row inside the price panel: the whole code, large and
/// left-to-right, with dial and copy.
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
    final fg = c.isDark ? c.onMasthead : c.textPrimary;
    final muted = c.isDark ? c.onMastheadMuted : c.textSecondary;
    return Container(
      key: const ValueKey('package-code'),
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: c.mastheadField,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: c.glassEdge),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelS.copyWith(color: muted)),
                CodeValue(code, style: AppTypography.codeL.copyWith(color: fg)),
              ],
            ),
          ),
          if (CodeActions.isDialable(code))
            IconButton(
              key: const ValueKey('package-code-dial'),
              tooltip: l10n.callValueSemantics(code),
              color: fg,
              icon: const Icon(AppIcons.call, size: AppIconSize.action),
              onPressed: () => launchDial(context, code),
            ),
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
      role: CardRole.flat,
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
              CodeText(v, onCall: (v) => launchDial(context, v)),
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
      case FactKind.code || FactKind.phone:
        return CodeText(fact.value, onCall: (v) => launchDial(context, v));
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
              color: fact.kind == FactKind.price ? c.accentText : c.textPrimary,
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

/// Details as a list: each fact on its own row, a tinted icon, the label
/// above and the value under it (long Arabic values read naturally).
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
          for (var i = 0; i < facts.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: AppSpacing.md + IconTile.xs.box + AppSpacing.sm,
                endIndent: AppSpacing.md,
                color: c.hairline,
              ),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TintedIcon(FactIcons.of(facts[i]), tile: IconTile.xs),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facts[i].label,
                          style: AppTypography.labelL.copyWith(
                            color: c.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _FactValue(fact: facts[i]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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

/// "Steps", how many are done and, once started, a reset.
class _StepsHeader extends ConsumerWidget {
  const _StepsHeader({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final done = ref.watch(
      stepsProgressProvider.select((s) => s[item.id]?.length ?? 0),
    );
    return GroupHeader(
      l10n.detailStepsTitle,
      trailing: done == 0
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.detailStepsProgress(done, item.steps.length),
                  key: const ValueKey('steps-progress'),
                  style: AppTypography.labelL.copyWith(
                    color: done == item.steps.length
                        ? c.verified
                        : c.textSecondary,
                    fontFeatures: AppTypography.tabular,
                  ),
                ),
                TextButton(
                  key: const ValueKey('steps-reset'),
                  onPressed: () =>
                      ref.read(stepsProgressProvider.notifier).reset(item.id),
                  child: Text(l10n.detailStepsReset),
                ),
              ],
            ),
    );
  }
}

class _StepsChecklist extends ConsumerWidget {
  const _StepsChecklist({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final c = context.colors;
    final steps = item.steps;
    final done =
        ref.watch(stepsProgressProvider.select((s) => s[item.id])) ??
        const <int>{};
    return AppCard(
      role: CardRole.flat,
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++)
            CheckboxListTile(
              key: ValueKey('step-$i'),
              value: done.contains(i),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (_) =>
                  ref.read(stepsProgressProvider.notifier).toggle(item.id, i),
              title: ProseText(
                '${i + 1}. ${steps[i]}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: done.contains(i) ? c.textTertiary : null,
                  decoration: done.contains(i)
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
            Text(
              s.name,
              key: ValueKey('source-${s.name}'),
              style: AppTypography.bodyM.copyWith(color: c.textSecondary),
            ),
            if (s.url != null)
              InkWell(
                onTap: () {
                  final uri = Uri.tryParse(s.url!);
                  if (uri != null) {
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                borderRadius: AppRadius.xsAll,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.link,
                        size: AppIconSize.inline,
                        color: c.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: LtrText(
                          s.url!,
                          style: AppTypography.labelS.copyWith(
                            color: c.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xs),
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
