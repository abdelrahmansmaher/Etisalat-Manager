import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/theme/theme.dart';
import 'package:knowledge_hub/core/content/content_models.dart';
import 'package:knowledge_hub/core/widgets/glass_surface.dart';
import 'package:knowledge_hub/features/content/section_ui.dart';

/// WCAG 2.x relative luminance.
double luminance(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double contrast(Color a, Color b) {
  final la = luminance(a);
  final lb = luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

/// Composite a translucent colour over an opaque backdrop.
Color over(Color top, Color bottom) => Color.alphaBlend(top, bottom);

typedef Pair = (String, Color, Color, double);

List<Pair> pairs(AppColors c) {
  const text = 4.5;
  const ui = 3.0;
  final worstBackdrop = c.brightness == Brightness.light
      ? Colors.black
      : Colors.white;
  final glass = over(
    GlassSurface.surfaceColor(c, opacity: 0.88),
    worstBackdrop,
  );
  final trust = TrustColors.fromTokens(c);
  return [
    ('textPrimary/surface', c.textPrimary, c.surface, text),
    ('textPrimary/background', c.textPrimary, c.background, text),
    ('textPrimary/surfaceElevated', c.textPrimary, c.surfaceElevated, text),
    ('textSecondary/surface', c.textSecondary, c.surface, text),
    ('textSecondary/background', c.textSecondary, c.background, text),
    ('textTertiary/surface', c.textTertiary, c.surface, text),
    ('textTertiary/surfaceVariant', c.textTertiary, c.surfaceVariant, text),
    ('textTertiary/background', c.textTertiary, c.background, text),
    ('textSecondary/heroStart', c.textSecondary, c.heroGradientStart, text),
    ('primary/surface', c.primary, c.surface, text),
    ('primary/background', c.primary, c.background, text),
    ('onPrimary/primary', c.onPrimary, c.primary, text),
    ('onPrimary/primaryPressed', c.onPrimary, c.primaryPressed, text),
    (
      'onPrimaryContainer/primaryContainer',
      c.onPrimaryContainer,
      c.primaryContainer,
      text,
    ),
    (
      'onErrorContainer/errorContainer',
      c.onErrorContainer,
      c.errorContainer,
      text,
    ),
    (
      'onWarningContainer/warningContainer',
      c.onWarningContainer,
      c.warningContainer,
      text,
    ),
    ('onError/error', c.onError, c.error, text),
    ('warning/surface', c.warning, c.surface, text),
    ('error/surface', c.error, c.surface, text),
    ('info/surface', c.info, c.surface, text),
    ('surface/textPrimary (snackbar)', c.surface, c.textPrimary, text),
    (
      'trust.verified',
      trust.verified.foreground,
      trust.verified.container,
      text,
    ),
    (
      'trust.needsReview',
      trust.needsReview.foreground,
      trust.needsReview.container,
      text,
    ),
    ('trust.expired', trust.expired.foreground, trust.expired.container, text),
    (
      'trust.unverified',
      trust.unverified.foreground,
      trust.unverified.container,
      text,
    ),
    (
      'trust.conflict',
      trust.conflict.foreground,
      trust.conflict.container,
      text,
    ),
    ('trust.private', trust.private.foreground, trust.private.container, text),
    ('trust.fresh/surface', trust.freshText, c.surface, text),
    ('trust.aging/surface', trust.agingText, c.surface, text),
    (
      'nav label (textSecondary) / glass on worst backdrop',
      c.textSecondary,
      glass,
      text,
    ),
    (
      'nav selected (onPrimaryContainer) / primaryContainer',
      c.onPrimaryContainer,
      c.primaryContainer,
      text,
    ),
    ('borderStrong/surface (UI)', c.borderStrong, c.surface, ui),
    ('primaryUi/surface (graphics)', c.primaryUi, c.surface, ui),
    // v3 tokens
    ('textPrimary/heroMid', c.textPrimary, c.heroGradientMid, text),
    ('textSecondary/heroMid', c.textSecondary, c.heroGradientMid, text),
    ('textPrimary/cardTop', c.textPrimary, c.cardTop, text),
    ('textSecondary/cardTop', c.textSecondary, c.cardTop, text),
    ('textTertiary/cardTop', c.textTertiary, c.cardTop, text),
    ('primary/cardTop', c.primary, c.cardTop, text),
    (
      'primaryUi/surfaceElevated (fact icons)',
      c.primaryUi,
      c.surfaceElevated,
      ui,
    ),
    ('primaryUi/cardTop (fact icons)', c.primaryUi, c.cardTop, ui),
    (
      'textTertiary/surfaceElevated (chevrons)',
      c.textTertiary,
      c.surfaceElevated,
      ui,
    ),
    // v2 tokens
    ('textPrimary/surfaceVariant', c.textPrimary, c.surfaceVariant, text),
    ('textSecondary/surfaceElevated', c.textSecondary, c.surfaceElevated, text),
    ('textSecondary/surfaceVariant', c.textSecondary, c.surfaceVariant, text),
    ('textTertiary/surfaceElevated', c.textTertiary, c.surfaceElevated, text),
    ('textTertiary/heroStart', c.textTertiary, c.heroGradientStart, text),
    ('textPrimary/heroStart', c.textPrimary, c.heroGradientStart, text),
    ('primary/heroStart', c.primary, c.heroGradientStart, text),
    ('primary/surfaceElevated', c.primary, c.surfaceElevated, text),
    ('primary/surfaceVariant (search icon)', c.primary, c.surfaceVariant, ui),
    ('accentText/surfaceElevated', c.accentText, c.surfaceElevated, text),
    ('accentText/heroStart', c.accentText, c.heroGradientStart, text),
    (
      'onAccentContainer/accentContainer (price pill)',
      c.onAccentContainer,
      c.accentContainer,
      text,
    ),
    ('accent/surface (graphics)', c.accent, c.surface, ui),
    (
      'onCapsuleSelected/capsuleSelected',
      c.onCapsuleSelected,
      c.capsuleSelected,
      text,
    ),
    ('capsuleSelected/background (UI)', c.capsuleSelected, c.background, ui),
    ('textPrimary/capsuleSurface', c.textPrimary, c.capsuleSurface, text),
    ('textSecondary/segment track', c.textSecondary, c.surfaceVariant, text),
    ('primary/capsuleSurface (icon)', c.primary, c.capsuleSurface, ui),
    (
      'onPrimaryContainer/primaryContainer (hotline icon)',
      c.onPrimaryContainer,
      c.primaryContainer,
      ui,
    ),
    (
      'nav icon (textSecondary) / glass on worst backdrop',
      c.textSecondary,
      over(GlassSurface.surfaceColor(c, opacity: 0.94), worstBackdrop),
      ui,
    ),
    (
      'status dot verified/surfaceElevated',
      trust.verified.foreground,
      c.surfaceElevated,
      text,
    ),
    (
      'status dot needsReview/surfaceElevated',
      trust.needsReview.foreground,
      c.surfaceElevated,
      text,
    ),
    (
      'status dot conflict/surfaceElevated',
      trust.conflict.foreground,
      c.surfaceElevated,
      text,
    ),
    for (final s in ContentSection.values) ...[
      () {
        final t = SectionTone.of(s, c.brightness);
        return (
          'section ${s.key} label/container',
          t.foreground,
          t.container,
          text,
        );
      }(),
      () {
        final t = SectionTone.of(s, c.brightness);
        return ('section ${s.key} icon/glow', t.foreground, t.glow, ui);
      }(),
      () {
        final t = SectionTone.of(s, c.brightness);
        return (
          'section ${s.key} label/surfaceElevated',
          t.foreground,
          c.surfaceElevated,
          text,
        );
      }(),
      () {
        final t = SectionTone.of(s, c.brightness);
        return (
          'textTertiary on section ${s.key} wash',
          c.textTertiary,
          over(
            t.container.withValues(alpha: c.isDark ? 0.55 : 0.6),
            c.surfaceElevated,
          ),
          text,
        );
      }(),
    ],
  ];
}

void main() {
  for (final (name, tokens) in [
    ('light', AppColors.light),
    ('dark', AppColors.dark),
  ]) {
    group('$name tokens meet WCAG AA', () {
      for (final (label, fg, bg, min) in pairs(tokens)) {
        test(label, () {
          final ratio = contrast(fg, bg);
          expect(
            ratio,
            greaterThanOrEqualTo(min),
            reason: '$label = ${ratio.toStringAsFixed(2)}:1 (< $min)',
          );
        });
      }
    });
  }

  test('both modes keep three distinct elevation steps', () {
    for (final c in [AppColors.light, AppColors.dark]) {
      if (c.isDark) {
        expect(luminance(c.surface), greaterThan(luminance(c.background)));
        expect(luminance(c.surfaceElevated), greaterThan(luminance(c.surface)));
      } else {
        expect(luminance(c.background), lessThan(luminance(c.surface)));
      }
    }
  });

  test('reference value: navy primary on white = 10.66:1', () {
    expect(
      contrast(AppColors.light.primary, Colors.white),
      closeTo(10.66, 0.02),
    );
  });

  test('ColorScheme is built from tokens, not a seed', () {
    final scheme = AppTheme.light().colorScheme;
    expect(scheme.primary, AppColors.light.primary);
    expect(scheme.onSurface, AppColors.light.textPrimary);
    expect(AppTheme.dark().colorScheme.primary, AppColors.dark.primary);
    expect(AppTheme.light().extension<TrustColors>(), isNotNull);
    expect(AppTheme.dark().extension<AppColors>(), AppColors.dark);
  });
}
