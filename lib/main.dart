import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/content/content_loader.dart';
import 'core/content/content_updates.dart';
import 'core/settings/preferences.dart';
import 'core/widgets/glass_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final glass = GlassEngine.warmUp();
  ContentLoader.parseInBackground = true;
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (_) {
    prefs = null; // the app still works, choices just are not remembered
  }
  await glass;
  runApp(
    ProviderScope(
      overrides: [
        if (prefs != null) preferencesProvider.overrideWithValue(prefs),
        contentUpdatesEnabledProvider.overrideWithValue(true),
      ],
      child: const KnowledgeHubApp(),
    ),
  );
}
