import 'package:flutter/widgets.dart';

/// Single source of truth for the app's display name.
///
/// The name is NOT final (doc 00 / 04 §3.5: never use the operator's brand
/// name or logo). Change it here only — every screen, the window title and
/// tests read from this class.
abstract final class AppIdentity {
  static const String nameAr = 'إنكور';
  static const String nameEn = 'N-Core';

  static String nameFor(Locale locale) =>
      locale.languageCode == 'ar' ? nameAr : nameEn;

  static String of(BuildContext context) =>
      nameFor(Localizations.localeOf(context));
}
