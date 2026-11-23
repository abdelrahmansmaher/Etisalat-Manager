import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme mode chosen in "Me" — defaults to following the system
/// (doc 04 §1, critical note 2).
///
/// TODO(persistence): persist locally once the settings store exists.
/// In-memory for now.
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  ThemeModeController([this._initial = ThemeMode.system]);

  final ThemeMode _initial;

  @override
  ThemeMode build() => _initial;

  void setMode(ThemeMode mode) => state = mode;
}
