import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/settings/preferences.dart';

/// Locales the UI ships with. Arabic first = fallback.
const List<Locale> kSupportedLocales = [Locale('ar'), Locale('en')];

/// In-app language override, independent of the device language
/// (doc 04 §6.1). `null` = follow the device language (Arabic when the
/// device language is not supported). Persisted in [preferencesProvider].
final localeProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

/// Resolves the device locale list to a supported one (Arabic fallback).
Locale resolveAppLocale(List<Locale>? device) {
  for (final l in device ?? const <Locale>[]) {
    for (final s in kSupportedLocales) {
      if (s.languageCode == l.languageCode) return s;
    }
  }
  return kSupportedLocales.first;
}

class LocaleController extends Notifier<Locale?> {
  static const _systemValue = 'system';

  /// [initial] forces a starting value (tests); otherwise the saved choice,
  /// else Arabic.
  LocaleController([this._initial]);

  final Locale? _initial;

  @override
  Locale? build() {
    final forced = _initial;
    if (forced != null) return forced;
    final saved = ref.watch(preferencesProvider)?.getString(PrefKeys.locale);
    if (saved == _systemValue) return null;
    for (final l in kSupportedLocales) {
      if (l.languageCode == saved) return l;
    }
    // First launch: Arabic, the app's primary language. The user can still
    // choose "device language" in Me.
    return kSupportedLocales.first;
  }

  /// `null` returns to the device language.
  void setLocale(Locale? locale) {
    assert(
      locale == null ||
          kSupportedLocales.any((l) => l.languageCode == locale.languageCode),
      'Unsupported locale $locale',
    );
    state = locale;
    final prefs = ref.read(preferencesProvider);
    if (locale == null) {
      prefs?.setString(PrefKeys.locale, _systemValue);
    } else {
      prefs?.setString(PrefKeys.locale, locale.languageCode);
    }
  }
}
