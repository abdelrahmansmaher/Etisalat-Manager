import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/settings/preferences.dart';
import 'package:knowledge_hub/core/theme/theme_mode_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simulates closing and reopening the app: a fresh ProviderContainer
/// reading the same persisted store must restore the chosen theme.
void main() {
  Future<ProviderContainer> launch() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(prefs)],
    );
  }

  for (final mode in [ThemeMode.dark, ThemeMode.light, ThemeMode.system]) {
    test('chosen ${mode.name} theme survives an app restart', () async {
      SharedPreferences.setMockInitialValues({});

      final first = await launch();
      first.read(themeModeProvider.notifier).setMode(mode);
      first.dispose(); // app closed

      final second = await launch(); // app reopened
      expect(second.read(themeModeProvider), mode);
      second.dispose();
    });
  }

  test('first launch follows the system theme', () async {
    SharedPreferences.setMockInitialValues({});
    final c = await launch();
    expect(c.read(themeModeProvider), ThemeMode.system);
    c.dispose();
  });
}
