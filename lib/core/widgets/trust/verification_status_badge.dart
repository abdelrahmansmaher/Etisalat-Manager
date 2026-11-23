import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/trust_colors.dart';
import 'trust_models.dart';
import 'trust_pill.dart';

/// Verification status chip — icon + text, never colour alone (doc 04 §3.3).
class VerificationStatusBadge extends StatelessWidget {
  const VerificationStatusBadge(this.status, {super.key, this.onTap});

  /// Convenience: show the highest-priority of several statuses.
  factory VerificationStatusBadge.highest(
    Iterable<VerificationStatus> statuses, {
    Key? key,
    VoidCallback? onTap,
  }) => VerificationStatusBadge(
    VerificationStatus.highest(statuses),
    key: key,
    onTap: onTap,
  );

  final VerificationStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = status.colors(context.trustColors);
    return TrustPill(
      icon: status.icon,
      label: status.label(l10n),
      foreground: colors.foreground,
      background: colors.container,
      onTap: onTap,
    );
  }
}
