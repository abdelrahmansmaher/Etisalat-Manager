import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Locales the UI ships with. Arabic first = default.
const List<Locale> kSupportedLocales = [Locale('ar'), Locale('en')];

/// In-app language, independent of the device language (doc 04 §6.1).
///
/// TODO(persistence): persist the choice locally (e.g. drift/shared settings
/// table once the local DB lands). In-memory for now.
final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale> {
  LocaleController([this._initial = const Locale('ar')]);

  final Locale _initial;

  @override
  Locale build() => _initial;

  void setLocale(Locale locale) {
    assert(
      kSupportedLocales.any((l) => l.languageCode == locale.languageCode),
      'Unsupported locale $locale',
    );
    state = locale;
  }
}
