import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/trust_colors.dart';
import '../ltr_text.dart';
import 'trust_format.dart';
import 'trust_models.dart';
import 'trust_pill.dart';
import '../../theme/app_icons.dart';

/// Traceable price (doc 04 §3.6): LTR-isolated amount + currency (follows UI
/// language, never inside the isolated number) + tax-basis label + validity.
///
/// * active → large `price` style;
/// * ending ≤ 3 days → warning note;
/// * expired → struck through at `bodyM` size + Expired pill — never looks
///   current;
/// * upcoming → "Starts on …", not shown as current;
/// * no end date → stated explicitly.
///
/// The copy button copies the bare amount only.
class PriceView extends StatelessWidget {
  const PriceView({
    super.key,
    required this.amount,
    required this.taxBasis,
    this.validFrom,
    this.validUntil,
    this.now,
    this.onCopied,
  });

  final num amount;
  final TaxBasis taxBasis;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final DateTime? now;
  final ValueChanged<String>? onCopied;

  Future<void> _copy(BuildContext context, String value) async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: value));
    onCopied?.call(value);
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.copiedMessage),
          duration: AppMotion.copyConfirmation,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final trust = context.trustColors;
    final locale = Localizations.localeOf(context);
    final validity = priceValidityFor(
      validFrom: validFrom,
      validUntil: validUntil,
      now: now ?? DateTime.now(),
    );
    final value = TrustFormat.amount(amount);
    final isCurrent =
        validity == PriceValidity.active ||
        validity == PriceValidity.endingSoon ||
        validity == PriceValidity.noEndDate;

    final amountStyle = isCurrent
        ? AppTypography.price.copyWith(color: c.textPrimary)
        : AppTypography.bodyM.copyWith(
            color: c.textTertiary,
            decoration: validity == PriceValidity.expired
                ? TextDecoration.lineThrough
                : null,
          );

    String fmt(DateTime d) => TrustFormat.date(d, locale);
    final String validityText;
    Color validityColor = c.textTertiary;
    switch (validity) {
      case PriceValidity.upcoming:
        validityText = l10n.priceStartsOn(fmt(validFrom!));
      case PriceValidity.expired:
        validityText = l10n.priceExpiredNote(fmt(validUntil!));
        validityColor = trust.expired.foreground;
      case PriceValidity.noEndDate:
        validityText = validFrom == null
            ? l10n.priceNoEndDate
            : '${l10n.priceValidFrom(fmt(validFrom!))} · ${l10n.priceNoEndDate}';
      case PriceValidity.endingSoon:
        validityText = l10n.priceEndsIn(
          daysBetween(now ?? DateTime.now(), validUntil!),
        );
        validityColor = c.warning;
      case PriceValidity.active:
        validityText = validFrom == null
            ? l10n.priceValidRange('—', fmt(validUntil!))
            : l10n.priceValidRange(fmt(validFrom!), fmt(validUntil!));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xxs,
          children: [
            LtrText(value, style: amountStyle),
            Text(
              l10n.currencyEgp,
              style: (isCurrent ? AppTypography.titleM : AppTypography.bodyM)
                  .copyWith(color: c.textSecondary),
            ),
            if (validity == PriceValidity.expired)
              TrustPill(
                icon: VerificationStatus.expired.icon,
                label: VerificationStatus.expired.label(l10n),
                foreground: trust.expired.foreground,
                background: trust.expired.container,
              ),
            if (isCurrent)
              IconButton(
                icon: const Icon(AppIcons.copy, size: AppIconSize.action),
                tooltip: l10n.copyValueSemantics(value),
                onPressed: () => _copy(context, value),
              ),
          ],
        ),
        Text(
          taxBasis.label(l10n),
          style: AppTypography.labelS.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          validityText,
          style: AppTypography.labelS.copyWith(color: validityColor),
        ),
      ],
    );
  }
}
