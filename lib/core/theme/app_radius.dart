import 'package:flutter/widgets.dart';

/// Corner radius tokens.
///
/// Owner direction (premium pass) supersedes doc 04 §2.4 (8/12/16): more
/// generous radii — chips & inputs ~14, cards ~20.
abstract final class AppRadius {
  /// Small badges, tooltips, snackbars.
  static const double xs = 8;

  /// Chips, inputs, small tiles, icon containers.
  static const double s = 14;

  /// List rows, tables (flat cards).
  static const double row = 16;

  /// Raised cards.
  static const double m = 20;

  /// Bottom sheets, dialogs, floating nav bar.
  static const double l = 28;

  /// Pills (search field, trust chips, filters), FAB.
  static const double full = 999;

  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(s));
  static const BorderRadius rowAll = BorderRadius.all(Radius.circular(row));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(m));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(l));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
}
