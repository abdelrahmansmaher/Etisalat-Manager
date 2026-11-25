import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Foreground / container pair for one trust state.
@immutable
class StatusColors {
  const StatusColors({required this.foreground, required this.container});

  /// Text and icon colour (AA on [container]).
  final Color foreground;
  final Color container;
}

/// Semantic status colours. Colour is never the only signal: every component
/// pairs it with an icon and a text label.
@immutable
class TrustColors extends ThemeExtension<TrustColors> {
  const TrustColors({
    required this.verified,
    required this.needsReview,
    required this.conflict,
  });

  factory TrustColors.fromTokens(AppColors c) => TrustColors(
    verified: StatusColors(
      foreground: c.verified,
      container: c.verifiedContainer,
    ),
    needsReview: StatusColors(
      foreground: c.onWarningContainer,
      container: c.warningContainer,
    ),
    conflict: StatusColors(
      foreground: c.onErrorContainer,
      container: c.errorContainer,
    ),
  );

  static final TrustColors light = TrustColors.fromTokens(AppColors.light);
  static final TrustColors dark = TrustColors.fromTokens(AppColors.dark);

  final StatusColors verified;
  final StatusColors needsReview;
  final StatusColors conflict;

  @override
  TrustColors copyWith() => this;

  @override
  TrustColors lerp(covariant TrustColors? other, double t) {
    if (other == null) return this;
    StatusColors s(StatusColors a, StatusColors b) => StatusColors(
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      container: Color.lerp(a.container, b.container, t)!,
    );
    return TrustColors(
      verified: s(verified, other.verified),
      needsReview: s(needsReview, other.needsReview),
      conflict: s(conflict, other.conflict),
    );
  }
}

extension TrustColorsContext on BuildContext {
  TrustColors get trustColors =>
      Theme.of(this).extension<TrustColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? TrustColors.dark
          : TrustColors.light);
}
