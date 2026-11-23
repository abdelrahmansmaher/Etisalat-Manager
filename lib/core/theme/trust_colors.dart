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

/// Semantic status colours for trust & freshness components (doc 04 §3).
/// Colour is never the only signal: every component pairs it with an icon and
/// a text label.
@immutable
class TrustColors extends ThemeExtension<TrustColors> {
  const TrustColors({
    required this.verified,
    required this.needsReview,
    required this.expired,
    required this.unverified,
    required this.conflict,
    required this.private,
    required this.freshText,
    required this.agingText,
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
    expired: StatusColors(
      foreground: c.onErrorContainer,
      container: c.errorContainer,
    ),
    unverified: StatusColors(
      foreground: c.unverified,
      container: c.unverifiedContainer,
    ),
    conflict: StatusColors(
      foreground: c.onErrorContainer,
      container: c.errorContainer,
    ),
    private: StatusColors(
      foreground: c.restricted,
      container: c.restrictedContainer,
    ),
    freshText: c.textTertiary,
    agingText: c.warning,
  );

  static final TrustColors light = TrustColors.fromTokens(AppColors.light);
  static final TrustColors dark = TrustColors.fromTokens(AppColors.dark);

  final StatusColors verified;
  final StatusColors needsReview;
  final StatusColors expired;
  final StatusColors unverified;
  final StatusColors conflict;
  final StatusColors private;

  /// "Last verified" text while fresh — calm, the normal state does not shout.
  final Color freshText;

  /// "Last verified" text while aging — warning text only.
  final Color agingText;

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
      expired: s(expired, other.expired),
      unverified: s(unverified, other.unverified),
      conflict: s(conflict, other.conflict),
      private: s(private, other.private),
      freshText: Color.lerp(freshText, other.freshText, t)!,
      agingText: Color.lerp(agingText, other.agingText, t)!,
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
