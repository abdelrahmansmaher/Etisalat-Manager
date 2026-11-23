import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/preferences.dart';

/// Theme mode chosen in "Me". Defaults to following the system (doc 04 §1,
/// critical note 2) and persists the choice in [preferencesProvider].
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  /// [initial] forces a starting value (tests); otherwise the saved value,
  /// else [ThemeMode.system].
  ThemeModeController([this._initial]);

  final ThemeMode? _initial;

  @override
  ThemeMode build() {
    final forced = _initial;
    if (forced != null) return forced;
    final saved = ref.watch(preferencesProvider)?.getString(PrefKeys.themeMode);
    return ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  void setMode(ThemeMode mode) {
    state = mode;
    ref.read(preferencesProvider)?.setString(PrefKeys.themeMode, mode.name);
  }
}
