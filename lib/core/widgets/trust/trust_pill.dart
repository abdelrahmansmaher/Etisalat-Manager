import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_icons.dart';

/// Refined pill chip: icon + text on a soft tinted background, hairline
/// border in the same hue. Base for every trust badge — colour is never the
/// only signal (icon + text always present).
class TrustPill extends StatelessWidget {
  const TrustPill({
    super.key,
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
    this.trailing,
    this.onTap,
    this.semanticsLabel,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;
  final IconData? trailing;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.sm - 2,
        AppSpacing.xxs + 1,
        AppSpacing.sm,
        AppSpacing.xxs + 1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSize.inline, color: foreground),
          const SizedBox(width: AppSpacing.xxs + 2),
          Flexible(
            child: Text(
              label,
              style: AppTypography.labelS.copyWith(color: foreground),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.xxs),
            Icon(trailing, size: AppIconSize.inline, color: foreground),
          ],
        ],
      ),
    );

    return Semantics(
      label: semanticsLabel ?? label,
      button: onTap != null,
      excludeSemantics: true,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.fullAll,
          side: BorderSide(color: foreground.withValues(alpha: 0.18)),
        ),
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? content
            : InkWell(
                onTap: onTap,
                child: ConstrainedBox(
                  // Compact visual pill (>= 32dp); callers keep >= 8dp
                  // spacing to neighbouring targets.
                  constraints: const BoxConstraints(minHeight: 32),
                  child: Center(widthFactor: 1, child: content),
                ),
              ),
      ),
    );
  }
}
