import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'motion.dart';

/// What a badge says, which fixes its colour (green only for confirmed).
enum BadgeTone {
  /// Checked on the official site.
  verified,

  /// Added in the latest content update.
  fresh,

  /// A count.
  count,
}

/// Small rounded label: "رسمي", "جديد", a count. It springs in when it
/// first appears or its text changes.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.tone = BadgeTone.count,
    this.icon,
    this.semanticLabel,
  });

  final String label;
  final BadgeTone tone;
  final IconData? icon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color bg, Color fg) = switch (tone) {
      BadgeTone.verified => (c.verifiedContainer, c.verified),
      BadgeTone.fresh => (c.capsuleSelected, c.onCapsuleSelected),
      BadgeTone.count => (c.primaryContainer, c.onPrimaryContainer),
    };
    return Semantics(
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: SpringPop(
        trigger: label,
        child: Container(
          padding: EdgeInsetsDirectional.fromSTEB(
            icon == null ? 7 : 5,
            1,
            7,
            1,
          ),
          constraints: const BoxConstraints(minWidth: 20, minHeight: 18),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.fullAll,
            border: Border.all(
              color: Colors.white.withValues(alpha: c.isDark ? 0.08 : 0.6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 11, color: fg),
                const SizedBox(width: 3),
              ],
              Text(
                label,
                maxLines: 1,
                style: AppTypography.labelS.copyWith(
                  color: fg,
                  fontSize: 11,
                  height: 16 / 11,
                  fontWeight: FontWeight.w700,
                  fontFeatures: AppTypography.tabular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round green seal of an item checked on the official site.
class VerifiedSeal extends StatelessWidget {
  const VerifiedSeal({super.key, this.size = 18, this.semanticLabel});

  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.verifiedContainer,
        shape: BoxShape.circle,
        border: Border.all(
          color: c.verified.withValues(alpha: c.isDark ? 0.35 : 0.25),
        ),
      ),
      child: Icon(
        AppIcons.confirmed,
        size: size * 0.66,
        color: c.verified,
        semanticLabel: semanticLabel,
      ),
    );
  }
}

/// Small dot over a navigation icon: something new waits there.
class BadgeDot extends StatelessWidget {
  const BadgeDot({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SpringPop(
      trigger: true,
      child: Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: c.error,
          shape: BoxShape.circle,
          border: Border.all(color: c.surface, width: 1.5),
        ),
      ),
    );
  }
}
