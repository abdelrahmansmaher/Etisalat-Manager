import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/preferences.dart';

/// Current time; overridden in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// JSON documents kept in SharedPreferences. They are in memory before the
/// first frame (`main()` awaits the store), so every read is synchronous.
/// Without a store (tests, platform failure) nothing is kept.
abstract final class UserKeys {
  static const String favorites = 'user.favorites';
  static const String overrides = 'user.overrides';
  static const String notes = 'user.notes';
  static const String snapshot = 'user.contentSnapshot';
  static const String changes = 'user.contentChanges';
  static const String training = 'user.training';
}

/// Reads a JSON document. An unreadable document is moved to
/// `<key>.unreadable` (never silently overwritten) and `null` is returned.
Object? readJsonDoc(Ref ref, String key) {
  final prefs = ref.watch(preferencesProvider);
  final raw = prefs?.getString(key);
  if (raw == null || raw.isEmpty) return null;
  try {
    return jsonDecode(raw);
  } catch (e) {
    debugPrint('user data: $key is not valid JSON ($e)');
    prefs!.setString('$key.unreadable', raw);
    return null;
  }
}

void writeJsonDoc(Ref ref, String key, Object? value) {
  final prefs = ref.read(preferencesProvider);
  if (prefs == null) return;
  if (value == null) {
    prefs.remove(key);
  } else {
    prefs.setString(key, jsonEncode(value));
  }
}

/// 2026-11-25 (local date).
String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
