import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/capsules.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/prose_text.dart';
import '../../core/widgets/sim_shape.dart';
import '../../l10n/app_localizations.dart';
import '../content/package_facts.dart';
import '../content/package_family.dart';
import 'dial.dart';
import 'package_info.dart';
import 'recharge_rule.dart';
import 'recommend_logic.dart';
import 'tool_widgets.dart';

/// Package recommender: what the customer pays, how much internet, how many
/// minutes and for how long. The top pick is shown first with its price and
/// code; every claim says whether it is stated or computed.
class RecommendScreen extends ConsumerStatefulWidget {
  const RecommendScreen({super.key});

  @override
  ConsumerState<RecommendScreen> createState() => _RecommendScreenState();
}

class _RecommendScreenState extends ConsumerState<RecommendScreen> {
  final _budget = TextEditingController();
  final _gb = TextEditingController();
  final _minutes = TextEditingController();
  PackageUse _use = PackageUse.mobile;
  ValidityNeed _validity = ValidityNeed.any;

  @override
  void dispose() {
    _budget.dispose();
    _gb.dispose();
    _minutes.dispose();
    super.dispose();
  }

  void _refresh(String _) => setState(() {});

  void _set(TextEditingController c, num v) => setState(() {
    final text = formatNumber(v.toDouble());
    c.text = c.text == text ? '' : text;
    c.selection = TextSelection.collapsed(offset: c.text.length);
  });

  void _clear() => setState(() {
    _budget.clear();
    _gb.clear();
    _minutes.clear();
    _validity = ValidityNeed.any;
  });

  List<int> get _budgets => _use == PackageUse.home
      ? const [200, 300, 500, 1000]
      : const [25, 50, 100, 150, 200, 300];

  List<int> get _gbs => _use == PackageUse.home
      ? const [100, 150, 200, 300, 500]
      : const [1, 3, 5, 10, 20];

  static const List<int> _minuteChoices = [100, 300, 1000, 3000];

  Widget _chips(TextEditingController c, List<int> values, String prefix) {
    final current = parseTypedNumber(c.text);
    final i = values.indexWhere((v) => current == v.toDouble());
    return CapsuleRow(
      // -1: none chosen yet; the indicator appears on the first pick.
      selected: i,
      children: [
        for (final v in values)
          Capsule(
            key: ValueKey('$prefix-$v'),
            dense: true,
            ltrLabel: true,
            label: '$v',
            selected: current == v.toDouble(),
            onTap: () => _set(c, v),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final packages = ref.watch(packageInfosProvider);
    final rule = ref.watch(rechargeRuleProvider);
    final needs = RecommendNeeds(
      budget: parseTypedNumber(_budget.text),
      gb: parseTypedNumber(_gb.text),
      minutes: _use == PackageUse.home ? null : parseTypedNumber(_minutes.text),
      use: _use,
      validity: _use == PackageUse.home ? ValidityNeed.any : _validity,
    );
    final result = recommend(packages, needs, rule: rule);
    final best = result.best;
    final others = result.fits.skip(1).toList();

    return PageScaffold(
      title: l10n.toolsRecommendTitle,
      subtitle: l10n.toolsRecommendSubtitle,
      actions: [
        if (!needs.isEmpty)
          IconButton(
            key: const ValueKey('recommend-clear'),
            tooltip: l10n.toolsRecommendReset,
            icon: const Icon(AppIcons.toolRestore),
            onPressed: _clear,
          ),
      ],
      children: [
        SegmentedCapsule<PackageUse>(
          selected: _use,
          onChanged: (u) => setState(() {
            _use = u;
            _budget.clear();
            _gb.clear();
            _minutes.clear();
          }),
          segments: [
            CapsuleSegment(
              value: PackageUse.mobile,
              label: l10n.toolsUseMobile,
            ),
            CapsuleSegment(value: PackageUse.home, label: l10n.toolsUseHome),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          role: CardRole.flat,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NumberField(
                controller: _budget,
                label: l10n.toolsRecommendBudget,
                onChanged: _refresh,
              ),
              const SizedBox(height: AppSpacing.xs),
              _chips(_budget, _budgets, 'budget'),
              const SizedBox(height: AppSpacing.md),
              NumberField(
                controller: _gb,
                label: l10n.toolsRecommendGb,
                onChanged: _refresh,
              ),
              const SizedBox(height: AppSpacing.xs),
              _chips(_gb, _gbs, 'gb'),
              if (_use == PackageUse.mobile) ...[
                const SizedBox(height: AppSpacing.md),
                NumberField(
                  controller: _minutes,
                  label: l10n.toolsRecommendMinutes,
                  onChanged: _refresh,
                ),
                const SizedBox(height: AppSpacing.xs),
                _chips(_minutes, _minuteChoices, 'minutes'),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.toolsRecommendValidity,
                  style: AppTypography.labelL.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xs),
                SegmentedCapsule<ValidityNeed>(
                  key: const ValueKey('recommend-validity'),
                  selected: _validity,
                  onChanged: (v) => setState(() => _validity = v),
                  segments: [
                    CapsuleSegment(
                      value: ValidityNeed.any,
                      label: l10n.toolsValidityAny,
                    ),
                    CapsuleSegment(
                      key: const ValueKey('validity-monthly'),
                      value: ValidityNeed.monthly,
                      label: l10n.toolsValidityMonthly,
                    ),
                    CapsuleSegment(
                      key: const ValueKey('validity-short'),
                      value: ValidityNeed.short,
                      label: l10n.toolsValidityShort,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (needs.isEmpty)
          PlaceholderPanel(
            icon: AppIcons.toolRecommend,
            title: l10n.toolsRecommendTitle,
            body: l10n.toolsRecommendStart,
          )
        else if (result.nothingFits &&
            result.maybe.isEmpty &&
            result.closest.isEmpty)
          PlaceholderPanel(
            icon: AppIcons.emptySearch,
            title: l10n.toolsNoMatches,
            body: l10n.toolsRecommendNone,
          )
        else ...[
          if (best != null) ...[
            SectionHeader(
              l10n.toolsRecommendBest,
              subtitle: needs.budgetOnly
                  ? l10n.toolsRecommendBestBudget
                  : l10n.toolsRecommendBestCheapest,
            ),
            const SizedBox(height: AppSpacing.xs),
            _BestCard(rec: best),
            const SizedBox(height: AppSpacing.md),
          ] else ...[
            Text(
              l10n.toolsRecommendNone,
              style: AppTypography.bodyM.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (others.isNotEmpty) ...[
            SectionHeader(l10n.toolsRecommendFits),
            const SizedBox(height: AppSpacing.xs),
            for (final r in others) ...[
              _RecommendationCard(rec: r),
              const SizedBox(height: AppSpacing.xs),
            ],
            const SizedBox(height: AppSpacing.sm),
          ],
          if (result.maybe.isNotEmpty) ...[
            SectionHeader(l10n.toolsRecommendMaybe),
            const SizedBox(height: AppSpacing.xs),
            for (final r in result.maybe) ...[
              _RecommendationCard(rec: r),
              const SizedBox(height: AppSpacing.xs),
            ],
            const SizedBox(height: AppSpacing.sm),
          ],
          if (result.closest.isNotEmpty && best == null) ...[
            SectionHeader(l10n.toolsRecommendClosest),
            const SizedBox(height: AppSpacing.xs),
            for (final r in result.closest) ...[
              _RecommendationCard(rec: r),
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
        ],
      ],
    );
  }
}

/// One line per need: met / missed / not stated, in words.
String needText(AppLocalizations l10n, NeedResult r, PackageInfo p) {
  final val = r.value == null ? '' : formatNumber(r.value!);
  final gb = p.gbText ?? val;
  return switch (r.need) {
    NeedKind.budget => switch (r.verdict) {
      Verdict.met =>
        r.reason == VerdictReason.computed
            ? l10n.toolsBudgetComputed(val)
            : l10n.toolsBudgetMet(val),
      Verdict.missed => l10n.toolsBudgetMissed(val),
      Verdict.unknown =>
        r.reason == VerdictReason.totalNotStated
            ? l10n.toolsBudgetUnknown(val)
            : l10n.toolsBudgetNotStated,
    },
    NeedKind.gb => switch (r.verdict) {
      Verdict.met => l10n.toolsGbMet(gb),
      Verdict.missed => l10n.toolsGbMissed(gb),
      Verdict.unknown =>
        r.reason == VerdictReason.mixOnly
            ? l10n.toolsGbMix(val)
            : l10n.toolsGbNotStated,
    },
    NeedKind.minutes => switch (r.reason) {
      VerdictReason.mixAnyNetwork => l10n.toolsMinutesAnyNetwork(val),
      VerdictReason.mixEandOnly =>
        r.verdict == Verdict.missed
            ? l10n.toolsMinutesUnitsShort(val)
            : l10n.toolsMinutesEandOnly(val),
      VerdictReason.mixOnly => l10n.toolsMinutesMix(val),
      _ => switch (r.verdict) {
        Verdict.met => l10n.toolsMinutesMet(val),
        Verdict.missed => l10n.toolsMinutesMissed(val),
        Verdict.unknown => l10n.toolsMinutesNotStated,
      },
    },
    NeedKind.validity => switch (r.verdict) {
      Verdict.met => l10n.toolsValidityMet(val),
      Verdict.missed => l10n.toolsValidityMissed(val),
      Verdict.unknown => l10n.toolsValidityNotStated,
    },
  };
}

class _NeedLines extends StatelessWidget {
  const _NeedLines({required this.rec, this.onNavy = false});

  final Recommendation rec;
  final bool onNavy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final n in rec.needs)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: IconLine(
              icon: switch (n.verdict) {
                Verdict.met => AppIcons.toolMeets,
                Verdict.missed => AppIcons.toolMisses,
                Verdict.unknown => AppIcons.toolUnknown,
              },
              text: needText(l10n, n, rec.package),
              color: switch (n.verdict) {
                Verdict.met => onNavy ? const Color(0xFF7BE3B4) : c.verified,
                Verdict.missed => onNavy ? const Color(0xFFFFA4A4) : c.error,
                Verdict.unknown =>
                  onNavy ? c.onMastheadMuted : c.onWarningContainer,
              },
              textColor: onNavy ? c.onMasthead : c.textPrimary,
            ),
          ),
      ],
    );
  }
}

/// The amount the customer pays, in gold, with a "computed" mark.
class _Pays extends StatelessWidget {
  const _Pays({required this.rec, this.onNavy = false, this.size = 22});

  final Recommendation rec;
  final bool onNavy;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final amount = rec.pays ?? rec.package.price;
    if (amount == null) return const SizedBox.shrink();
    final gold = onNavy ? c.mastheadPrice : c.accentText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            LtrText(
              formatNumber(amount),
              style: AppTypography.price.copyWith(color: gold, fontSize: size),
            ),
            const SizedBox(width: 3),
            Text(
              l10n.currencyShort,
              style: AppTypography.labelS.copyWith(color: gold),
            ),
          ],
        ),
        if (rec.pays == null && rec.package.priceBeforeTax)
          Text(
            l10n.toolsRecommendBeforeTax,
            style: AppTypography.labelS.copyWith(
              color: onNavy ? c.onMastheadMuted : c.textTertiary,
            ),
          ),
        if (rec.computed ?? false)
          Text(
            l10n.toolsRecommendComputed,
            style: AppTypography.labelS.copyWith(
              color: onNavy ? c.onMastheadMuted : c.textTertiary,
            ),
          ),
      ],
    );
  }
}

/// The top pick on the navy SIM panel: what the customer pays, the quota,
/// why it fits, and its code ready to dial or copy.
class _BestCard extends StatelessWidget {
  const _BestCard({required this.rec});

  final Recommendation rec;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final p = rec.package;
    final line = PackageLine.of(p.item, l10n);
    final code = p.codeText;
    return Container(
      key: ValueKey('recommend-best-${p.item.id}'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: simGlassDecoration(c, cut: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FamilyTile(p.family),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProseText(
                        p.item.title,
                        style: AppTypography.titleL.copyWith(
                          color: c.onMasthead,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (line.details.isNotEmpty)
                        ProseText(
                          line.details,
                          style: AppTypography.bodyM.copyWith(
                            color: c.onMastheadMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                if (p.item.officiallyVerified) ...[
                  const SizedBox(width: AppSpacing.xs),
                  VerifiedSeal(semanticLabel: l10n.statusConfirmedOfficial),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  rec.pays == null
                      ? l10n.toolsRecommendPrice
                      : l10n.toolsRecommendPays,
                  style: AppTypography.labelL.copyWith(
                    color: c.onMastheadMuted,
                  ),
                ),
              ),
              _Pays(rec: rec, onNavy: true, size: 34),
            ],
          ),
          if (rec.computed ?? false)
            if (p.price case final price?)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  l10n.toolsRecommendDeducted(formatNumber(price)),
                  style: AppTypography.bodyS.copyWith(color: c.onMastheadMuted),
                ),
              ),
          const SizedBox(height: AppSpacing.sm),
          _NeedLines(rec: rec, onNavy: true),
          if (code != null) ...[
            const SizedBox(height: AppSpacing.xs),
            CodeText(code, onCall: (v) => launchDial(context, v)),
          ],
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            key: const ValueKey('recommend-open-best'),
            style: FilledButton.styleFrom(
              backgroundColor: c.mastheadPrice,
              foregroundColor: c.masthead,
            ),
            onPressed: () => context.push(ContentRoutes.item(p.item.id)),
            icon: const Icon(AppIcons.arrowForward),
            label: Text(l10n.toolsRecommendOpen),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.rec});

  final Recommendation rec;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final p = rec.package;
    final line = PackageLine.of(p.item, l10n);
    return AppCard(
      role: CardRole.flat,
      onTap: () => context.push(ContentRoutes.item(p.item.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FamilyTile(p.family),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProseText(
                      p.item.title,
                      style: AppTypography.titleM.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    if (line.details.isNotEmpty)
                      ProseText(
                        line.details,
                        style: AppTypography.bodyS.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              _Pays(rec: rec),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Divider(color: c.hairline, height: 1),
          const SizedBox(height: AppSpacing.xs),
          _NeedLines(rec: rec),
          if (p.mixNote != null &&
              rec.needs.any(
                (n) =>
                    n.reason == VerdictReason.mixOnly ||
                    n.reason == VerdictReason.mixEandOnly,
              ))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: ProseText(
                l10n.toolsMixNote(p.mixNote!),
                style: AppTypography.bodyS.copyWith(color: c.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
