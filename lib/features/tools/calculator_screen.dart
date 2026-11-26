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
import 'postpaid_tax.dart';
import 'recharge_rule.dart';
import 'tool_widgets.dart';

enum _CalcMode { card, price, postpaid }

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
    final postpaid = _mode == _CalcMode.postpaid && val != null
        ? PostpaidTax(val)
        : null;
    final result = val == null
        ? null
        : switch (_mode) {
            _CalcMode.card => rule.balanceFor(val),
            _CalcMode.price => rule.cardFor(val),
            _CalcMode.postpaid => postpaid!.total,
          };
    final taxDiff = val != null && result != null && postpaid == null
        ? (_mode == _CalcMode.card ? val - result : result - val)
        : null;

    return PageScaffold(
      title: l10n.toolsCalcTitle,
      children: [
        ToolHero(
          icon: AppIcons.toolCalculator,
          hue: ToolHue.calculator,
          text: l10n.toolsCalcIntro,
        ),
        const SizedBox(height: AppSpacing.md),
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
            CapsuleSegment(
              key: const ValueKey('calc-mode-postpaid'),
              value: _CalcMode.postpaid,
              label: l10n.toolsCalcModePostpaid,
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
                label: switch (_mode) {
                  _CalcMode.card => l10n.toolsCalcCardLabel,
                  _CalcMode.price => l10n.toolsCalcPriceLabel,
                  _CalcMode.postpaid => l10n.toolsCalcPostpaidLabel,
                },
                onChanged: (_) => setState(() {}),
              ),
              if (_mode == _CalcMode.card) ...[
                const SizedBox(height: AppSpacing.sm),
                CapsuleRow(
                  selected: () {
                    final i = _presets.indexWhere((a) => val == a.toDouble());
                    return i;
                  }(),
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
            decoration: simGlassDecoration(c, cut: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  switch (_mode) {
                    _CalcMode.card => l10n.toolsCalcBalanceResult,
                    _CalcMode.price => l10n.toolsCalcCardResult,
                    _CalcMode.postpaid => l10n.toolsCalcPostpaidResult,
                  },
                  style: AppTypography.labelL.copyWith(
                    color: c.onMastheadMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.toolsCalcEgp(formatNumber(result)),
                  key: const ValueKey('calc-result'),
                  style: AppTypography.priceHero.copyWith(
                    color: c.mastheadPrice,
                    fontSize: 36,
                  ),
                ),
                if (postpaid != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.toolsCalcPostpaidParts(
                      formatNumber(postpaid.tableTax),
                      formatNumber(postpaid.vat),
                      formatNumber(postpaid.fees),
                    ),
                    style: AppTypography.bodyM.copyWith(
                      color: c.onMastheadMuted,
                    ),
                  ),
                ],
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
          onTap: () => context.push(
            ContentRoutes.item(
              _mode == _CalcMode.postpaid ? PostpaidTax.itemId : rule.item.id,
            ),
          ),
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
                      _mode == _CalcMode.postpaid
                          ? l10n.toolsCalcPostpaidRule
                          : l10n.toolsCalcRatio(
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
