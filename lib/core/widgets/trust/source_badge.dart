import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import 'trust_models.dart';
import 'trust_pill.dart';

/// "Where did this come from?" (doc 04 §3.1): source-type icon + short
/// source name; a chevron appears when [onTap] opens the details sheet.
class SourceBadge extends StatelessWidget {
  const SourceBadge({
    super.key,
    required this.sourceName,
    required this.type,
    this.onTap,
  });

  /// Short display name, e.g. "[Public website]".
  final String sourceName;
  final SourceType type;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return TrustPill(
      icon: type.icon,
      label: sourceName,
      foreground: c.textSecondary,
      background: c.surfaceVariant,
      // chevron_right mirrors automatically in RTL (matchTextDirection).
      trailing: onTap != null ? Icons.chevron_right : null,
      onTap: onTap,
      semanticsLabel: l10n.sourceSemantics(sourceName, type.label(l10n)),
    );
  }
}
