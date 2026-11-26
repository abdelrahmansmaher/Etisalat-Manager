import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/capsules.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/sim_shape.dart';
import '../../l10n/app_localizations.dart';
import 'package_info.dart';
import 'recharge_rule.dart';
import 'tool_widgets.dart';

enum _CalcMode { card, price }

/// Recharge / tax calculator grounded in the guide's stated ratio.
class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  final _input = TextEditingController();
  _CalcMode _mode = _CalcMode.card;

  static const List<int> _presets = [10, 15, 25, 50, 100, 150, 200];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _pickPreset(int amount) {
    _input.text = '$amount';
    _input.selection = TextSelection.collapsed(offset: _input.text.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final rule = ref.watch(rechargeRuleProvider);

    if (rule == null) {
      return PageScaffold(
        title: l10n.toolsCalcTitle,
        children: [
          PlaceholderPanel(
            icon: AppIcons.toolCalculator,
            title: l10n.toolsCalcUnavailable,
            body: l10n.toolsCalcUnavailableBody,
          ),
        ],
      );
    }

    final val = parseTypedNumber(_input.text);
    final result = val == null
        ? null
        : (_mode == _CalcMode.card ? rule.balanceFor(val) : rule.cardFor(val));
    final taxDiff = val != null && result != null
        ? (_mode == _CalcMode.card ? val - result : result - val)
        : null;

    return PageScaffold(
      title: l10n.toolsCalcTitle,
      children: [
        SegmentedCapsule<_CalcMode>(
          selected: _mode,
          onChanged: (m) => setState(() => _mode = m),
          segments: [
            CapsuleSegment(
              value: _CalcMode.card,
              label: l10n.toolsCalcModeCard,
            ),
            CapsuleSegment(
              value: _CalcMode.price,
              label: l10n.toolsCalcModePrice,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          role: CardRole.flat,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NumberField(
                controller: _input,
                label: _mode == _CalcMode.card
                    ? l10n.toolsCalcCardLabel
                    : l10n.toolsCalcPriceLabel,
                onChanged: (_) => setState(() {}),
              ),
              if (_mode == _CalcMode.card) ...[
                const SizedBox(height: AppSpacing.sm),
                CapsuleRow(
                  children: [
                    for (final amount in _presets)
                      Capsule(
                        dense: true,
                        ltrLabel: true,
                        label: '$amount',
                        selected: val == amount.toDouble(),
                        onTap: () => _pickPreset(amount),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (result != null) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: ShapeDecoration(
              color: c.masthead,
              shape: SimShape(
                radius: AppRadius.m,
                cut: 30,
                side: c.isDark ? BorderSide(color: c.border) : BorderSide.none,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _mode == _CalcMode.card
                      ? l10n.toolsCalcBalanceResult
                      : l10n.toolsCalcCardResult,
                  style: AppTypography.labelL.copyWith(
                    color: c.onMastheadMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.toolsCalcEgp(formatNumber(result)),
                  style: AppTypography.priceHero.copyWith(
                    color: c.mastheadPrice,
                    fontSize: 36,
                  ),
                ),
                if (taxDiff != null && taxDiff > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.toolsCalcTaxPart(formatNumber(taxDiff)),
                    style: AppTypography.bodyM.copyWith(
                      color: c.onMastheadMuted,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.toolsCalcComputed,
                  style: AppTypography.labelS.copyWith(
                    color: c.onMastheadMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        AppCard(
          role: CardRole.flat,
          onTap: () => context.push(ContentRoutes.item(rule.item.id)),
          child: Row(
            children: [
              TintedIcon(AppIcons.info, tile: IconTile.sm),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.toolsCalcSource,
                      style: AppTypography.labelS.copyWith(
                        color: c.textTertiary,
                      ),
                    ),
                    Text(
                      l10n.toolsCalcRatio(
                        formatNumber(rule.card),
                        formatNumber(rule.balance),
                      ),
                      style: AppTypography.titleS.copyWith(
                        color: c.textPrimary,
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
      ],
    );
  }
}
