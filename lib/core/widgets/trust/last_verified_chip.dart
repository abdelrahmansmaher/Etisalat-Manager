import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/trust_colors.dart';
import 'trust_format.dart';
import 'trust_models.dart';
import 'trust_pill.dart';

/// "Is it still right?" (doc 04 §3.2).
///
/// * fresh  → calm tertiary text ("Last verified: 5 days ago");
/// * aging  → same text in warning colour (text only);
/// * stale  → becomes a **Needs review** pill (icon + text).
///
/// Tapping/long-pressing shows the absolute date in a tooltip.
class LastVerifiedChip extends StatelessWidget {
  const LastVerifiedChip({
    super.key,
    required this.verifiedAt,
    required this.contentType,
    this.now,
  });

  final DateTime verifiedAt;
  final TrustContentType contentType;

  /// Injectable clock for tests; defaults to [DateTime.now].
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trust = context.trustColors;
    final locale = Localizations.localeOf(context);
    final days = daysBetween(verifiedAt, now ?? DateTime.now());
    final freshness = contentType.freshnessForAge(days);
    final relative = l10n.lastVerified(l10n.daysAgo(days));
    final absolute = l10n.verifiedOn(TrustFormat.date(verifiedAt, locale));

    final Widget child;
    if (freshness == Freshness.stale) {
      const status = VerificationStatus.needsReview;
      final sc = status.colors(trust);
      child = TrustPill(
        icon: status.icon,
        label: '${status.label(l10n)} · $relative',
        foreground: sc.foreground,
        background: sc.container,
      );
    } else {
      final color = freshness == Freshness.aging
          ? trust.agingText
          : trust.freshText;
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 16, color: color),
          const SizedBox(width: AppSpacing.xxs),
          Flexible(
            child: Text(
              relative,
              style: AppTypography.labelS.copyWith(color: color),
            ),
          ),
        ],
      );
    }

    return Tooltip(
      message: absolute,
      triggerMode: TooltipTriggerMode.tap,
      child: child,
    );
  }
}
