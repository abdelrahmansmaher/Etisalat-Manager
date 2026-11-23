import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// "Unofficial app" disclaimer (doc 04 §3.5).
///
/// * [UnofficialDisclaimer.compact] — quiet footer line (labelS, tertiary).
/// * [UnofficialDisclaimer.full] — full text in a soft card (Me / About).
class UnofficialDisclaimer extends StatelessWidget {
  const UnofficialDisclaimer.compact({super.key}) : _full = false;
  const UnofficialDisclaimer.full({super.key}) : _full = true;

  final bool _full;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    if (!_full) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 1),
            child: Icon(Icons.info_outline, size: 14, color: c.textTertiary),
          ),
          const SizedBox(width: AppSpacing.xxs + 2),
          Flexible(
            child: Text(
              l10n.disclaimerShort,
              textAlign: TextAlign.center,
              style: AppTypography.labelS.copyWith(color: c.textTertiary),
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surfaceVariant,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: c.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: c.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              l10n.disclaimerFull,
              style: AppTypography.bodyM.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
