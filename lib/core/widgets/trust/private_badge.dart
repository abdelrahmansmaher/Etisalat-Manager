import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/trust_colors.dart';
import 'trust_models.dart';
import 'trust_pill.dart';

/// Marks owner-only private notes (doc 00 v0.2): "ملاحظة خاصة — للمالك فقط".
class PrivateBadge extends StatelessWidget {
  const PrivateBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = VerificationStatus.private.colors(context.trustColors);
    return TrustPill(
      icon: VerificationStatus.private.icon,
      label: l10n.privateBadge,
      foreground: colors.foreground,
      background: colors.container,
    );
  }
}
