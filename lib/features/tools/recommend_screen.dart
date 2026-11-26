import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/capsules.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/prose_text.dart';
import '../../l10n/app_localizations.dart';
import '../content/package_family.dart';
import 'package_info.dart';
import 'recommend_logic.dart';
import 'tool_widgets.dart';

/// Package recommender driven by customer budget, GB, and minutes.
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

  @override
  void dispose() {
    _budget.dispose();
    _gb.dispose();
    _minutes.dispose();
    super.dispose();
  }

  void _refresh(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final packages = ref.watch(packageInfosProvider);
    final needs = RecommendNeeds(
      budget: parseTypedNumber(_budget.text),
      gb: parseTypedNumber(_gb.text),
      minutes: parseTypedNumber(_minutes.text),
      use: _use,
    );
    final result = recommend(packages, needs);

    return PageScaffold(
      title: l10n.toolsRecommendTitle,
      subtitle: l10n.toolsRecommendSubtitle,
      children: [
        SegmentedCapsule<PackageUse>(
          selected: _use,
          onChanged: (u) => setState(() => _use = u),
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
            children: [
              NumberField(
                controller: _budget,
                label: l10n.toolsRecommendBudget,
                onChanged: _refresh,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: NumberField(
                      controller: _gb,
                      label: l10n.toolsRecommendGb,
                      onChanged: _refresh,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: NumberField(
                      controller: _minutes,
                      label: l10n.toolsRecommendMinutes,
                      onChanged: _refresh,
                    ),
                  ),
                ],
              ),
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
        else ...[
          if (result.nothingFits &&
              result.maybe.isEmpty &&
              result.closest.isEmpty)
            PlaceholderPanel(
              icon: AppIcons.emptySearch,
              title: l10n.toolsNoMatches,
              body: l10n.toolsRecommendNone,
            )
          else ...[
            if (result.nothingFits) ...[
              Text(
                l10n.toolsRecommendNone,
                style: AppTypography.bodyM.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (result.fits.isNotEmpty) ...[
              SectionHeader(l10n.toolsRecommendFits),
              const SizedBox(height: AppSpacing.xs),
              for (final r in result.fits) ...[
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
            if (result.closest.isNotEmpty) ...[
              SectionHeader(l10n.toolsRecommendClosest),
              const SizedBox(height: AppSpacing.xs),
              for (final r in result.closest) ...[
                _RecommendationCard(rec: r),
                const SizedBox(height: AppSpacing.xs),
              ],
            ],
          ],
        ],
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.rec});

  final Recommendation rec;

  static String _needText(AppLocalizations l10n, NeedResult r, PackageInfo p) {
    final val = r.value == null ? '' : formatNumber(r.value!);
    final gb = p.gbText ?? val;
    return switch (r.need) {
      NeedKind.budget => switch (r.verdict) {
        Verdict.met => l10n.toolsBudgetMet(val),
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
      NeedKind.minutes => switch (r.verdict) {
        Verdict.met => l10n.toolsMinutesMet(val),
        Verdict.missed => l10n.toolsMinutesMissed(val),
        Verdict.unknown =>
          r.reason == VerdictReason.mixOnly
              ? l10n.toolsMinutesMix(val)
              : l10n.toolsMinutesNotStated,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final p = rec.package;
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
                    const SizedBox(height: 2),
                    ItemStatusTag(p.item),
                  ],
                ),
              ),
              if (p.priceText != null) GoldAmount(p.priceText!, large: true),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Divider(color: c.hairline, height: 1),
          const SizedBox(height: AppSpacing.xs),
          for (final n in rec.needs) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: IconLine(
                icon: switch (n.verdict) {
                  Verdict.met => AppIcons.toolMeets,
                  Verdict.missed => AppIcons.toolMisses,
                  Verdict.unknown => AppIcons.toolUnknown,
                },
                text: _needText(l10n, n, p),
                color: switch (n.verdict) {
                  Verdict.met => c.verified,
                  Verdict.missed => c.error,
                  Verdict.unknown => c.onWarningContainer,
                },
                textColor: c.textPrimary,
              ),
            ),
          ],
          if (p.mixNote != null &&
              rec.needs.any((n) => n.reason == VerdictReason.mixOnly))
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
