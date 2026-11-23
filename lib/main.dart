import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/settings/preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (_) {
    prefs = null; // the app still works, choices just are not remembered
  }
  runApp(
    ProviderScope(
      overrides: [
        if (prefs != null) preferencesProvider.overrideWithValue(prefs),
      ],
      child: const KnowledgeHubApp(),
    ),
  );
}
