import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local key/value store for small user choices (theme, language, recents).
///
/// `null` = no persistence (widget tests, or the platform store failed to
/// open); every reader then falls back to in-memory defaults. `main()`
/// overrides this with the real instance before the first frame, so reads
/// stay synchronous and the first frame already has the saved theme.
final preferencesProvider = Provider<SharedPreferences?>((ref) => null);

/// Keys used in [SharedPreferences].
abstract final class PrefKeys {
  static const String themeMode = 'settings.themeMode';
  static const String locale = 'settings.locale';
  static const String recentItems = 'history.recentItems';
  static const String recentSearches = 'history.recentSearches';
}
