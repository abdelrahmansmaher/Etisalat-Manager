import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/prose_text.dart';
import '../../l10n/app_localizations.dart';
import 'value_logic.dart';

/// Unit price of [s] in words: `الجيجا بـ 3.5 ج`.
String valueLine(AppLocalizations l10n, ValueRanking r, ValueScore s) {
  final cost = unitCostText(r, s);
  return switch (r.basis) {
    ValueBasis.gb => l10n.valuePerGb(cost),
    ValueBasis.minute => l10n.valuePerMinute(cost),
    ValueBasis.mix => l10n.valuePerMix(cost),
  };
}

String valueBasisText(AppLocalizations l10n, ValueRanking r) => [
  switch (r.basis) {
    ValueBasis.gb => l10n.valueBasisGb,
    ValueBasis.minute => l10n.valueBasisMinute,
    ValueBasis.mix => l10n.valueBasisMix,
  },
  r.paysTotal ? l10n.valuePriceTotal : l10n.valuePriceBefore,
].join(' · ');

/// The verdict: which package gives the most for each pound, by how much,
/// and a bar per package (longer = more for the money).
class ValueVerdictCard extends StatelessWidget {
  const ValueVerdictCard({
    super.key,
    required this.ranking,
    required this.title,
    this.subtitle,
    this.maxBars = 4,
  });

  final ValueRanking ranking;
  final String title;
  final String? subtitle;
  final int maxBars;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final r = ranking;
    final best = r.best;
    final hue = Hue.violet.of(c);
    final lead = r.leadOverNext;
    final leadLast = r.leadOverLast;
    String pct(double v) => '${(v * 100).round()}';

    return Container(
      key: const ValueKey('value-verdict'),
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgAll,
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            Color.alphaBlend(Colors.white.withValues(alpha: 0.12), hue),
            hue,
            Color.alphaBlend(Colors.black.withValues(alpha: 0.22), hue),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: hue.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  AppIcons.valueBest,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleS.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: AppTypography.labelS.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // The winner.
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              key: ValueKey('value-best-${best.package.item.id}'),
              borderRadius: AppRadius.mdAll,
              onTap: () =>
                  context.push(ContentRoutes.item(best.package.item.id)),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProseText(
                      best.package.item.title,
                      style: AppTypography.titleM.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      valueLine(l10n, r, best),
                      style: AppTypography.bodyM.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (r.tie)
                      Text(
                        l10n.valueTie,
                        style: AppTypography.bodyS.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      )
                    else if (lead != null && lead >= 0.005)
                      Text(
                        [
                          l10n.valueLead(pct(lead)),
                          if (leadLast != null &&
                              r.scores.length > 2 &&
                              leadLast - lead >= 0.01)
                            l10n.valueLeadLast(pct(leadLast)),
                        ].join('، '),
                        style: AppTypography.bodyS.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final s in r.scores.take(maxBars)) _Bar(ranking: r, score: s),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            valueBasisText(l10n, r),
            style: AppTypography.labelS.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// One package: name, unit price and a bar as long as what a pound buys.
class _Bar extends StatelessWidget {
  const _Bar({required this.ranking, required this.score});

  final ValueRanking ranking;
  final ValueScore score;

  @override
  Widget build(BuildContext context) {
    final best = identical(score, ranking.best);
    final share = (ranking.best.unitCost / score.unitCost).clamp(0.06, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  score.package.item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelL.copyWith(
                    color: Colors.white,
                    fontWeight: best ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ),
              Text(
                unitCostText(ranking, score),
                style: AppTypography.labelL.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontFeatures: AppTypography.tabular,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, box) => Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: AppRadius.fullAll,
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: share),
                  duration: AppMotion.resolve(context, AppMotion.page),
                  curve: AppMotion.enter,
                  builder: (context, v, _) => Container(
                    width: box.maxWidth * v,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: best ? 1 : 0.55),
                      borderRadius: AppRadius.fullAll,
                    ),
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

/// Shown instead of a verdict when the packages share no fair unit.
class ValueNotComparable extends StatelessWidget {
  const ValueNotComparable({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return AppCard(
      key: const ValueKey('value-not-comparable'),
      role: CardRole.flat,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          TintedIcon(AppIcons.valueBest, tile: IconTile.sm, hue: Hue.slate),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              l10n.valueNotComparable,
              style: AppTypography.bodyS.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
