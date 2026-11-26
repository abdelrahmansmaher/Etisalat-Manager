import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../settings/preferences.dart';
import 'content_loader.dart';
import 'content_models.dart';

/// Where the published content lives: the app's own repository, kept in
/// step with e& Egypt's official site by a daily job
/// (`.github/workflows/sync-prices.yml`).
const contentUpdateBase =
    'https://raw.githubusercontent.com/abdelrahmansmaher/Etisalat-Manager/main/assets/content';

/// The content files a manifest lists.
String fileOf(ContentSection s) => '${s.key}.json';

/// Version and checksums of a content set.
@immutable
class ContentManifest {
  const ContentManifest({
    required this.version,
    required this.files,
    this.checkedAt,
  });

  factory ContentManifest.fromJson(Map<String, dynamic> j) => ContentManifest(
    version: (j['version'] as num).toInt(),
    checkedAt: j['checked_at'] as String?,
    files: (j['files'] as Map).cast<String, String>(),
  );

  final int version;
  final String? checkedAt;
  final Map<String, String> files;

  Map<String, dynamic> toJson() => {
    'version': version,
    'checked_at': ?checkedAt,
    'files': files,
  };
}

/// SHA-256 of a content file, line endings normalised as the publisher does.
String contentHash(String raw) =>
    sha256.convert(utf8.encode(raw.replaceAll('\r\n', '\n'))).toString();

abstract final class _Keys {
  static const manifest = 'content.update.manifest';
  static String file(ContentSection s) => 'content.update.${s.key}';
  static const lastCheck = 'content.update.lastCheck';
  static const checkedAt = 'content.update.checkedAt';
}

/// Reads the newest content the device has: a verified download when it is
/// newer than the copy inside the app, else the copy inside the app.
class UpdatableContentSource extends ContentSource {
  const UpdatableContentSource(
    this.prefs, {
    this.bundled = const AssetContentSource(),
  });

  final SharedPreferences prefs;
  final ContentSource bundled;

  @override
  Future<String?> read(ContentSection section) async {
    final downloaded = await _downloadedIsNewer();
    if (downloaded) {
      final raw = prefs.getString(_Keys.file(section));
      if (raw != null) return raw;
    }
    return bundled.read(section);
  }

  Future<bool> _downloadedIsNewer() async {
    final cached = cachedManifest(prefs);
    if (cached == null) return false;
    final inApp = await bundledManifest();
    return inApp == null || cached.version > inApp.version;
  }
}

ContentManifest? cachedManifest(SharedPreferences prefs) {
  final raw = prefs.getString(_Keys.manifest);
  if (raw == null) return null;
  try {
    return ContentManifest.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}

ContentManifest? _bundledCache;

/// The manifest shipped inside the app.
Future<ContentManifest?> bundledManifest() async {
  if (_bundledCache != null) return _bundledCache;
  try {
    final raw = await rootBundle.loadString('assets/content/manifest.json');
    return _bundledCache = ContentManifest.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  } catch (_) {
    return null;
  }
}

/// Outcome of one check.
enum UpdateResult { upToDate, updated, offline, rejected }

/// Checks the published content and, when it is newer, downloads it,
/// verifies every file (checksum, and that it parses with at least as many
/// items as before) and keeps it. Anything wrong leaves the current content
/// untouched.
class ContentUpdater {
  ContentUpdater(
    this.prefs, {
    http.Client? client,
    this.base = contentUpdateBase,
  }) : _client = client ?? http.Client();

  final SharedPreferences prefs;
  final http.Client _client;
  final String base;

  static const _timeout = Duration(seconds: 12);

  /// Checks at most once every [every].
  Future<UpdateResult> checkIfDue({Duration every = const Duration(hours: 3)}) {
    final last = prefs.getInt(_Keys.lastCheck);
    final now = DateTime.now().millisecondsSinceEpoch;
    if (last != null && now - last < every.inMilliseconds) {
      return Future.value(UpdateResult.upToDate);
    }
    return check();
  }

  Future<UpdateResult> check() async {
    final ContentManifest remote;
    try {
      final res = await _client
          .get(
            Uri.parse(
              '$base/manifest.json?t=${DateTime.now().millisecondsSinceEpoch ~/ 60000}',
            ),
          )
          .timeout(_timeout);
      if (res.statusCode != 200) return UpdateResult.offline;
      remote = ContentManifest.fromJson(
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
      );
    } catch (_) {
      return UpdateResult.offline;
    }
    await prefs.setInt(_Keys.lastCheck, DateTime.now().millisecondsSinceEpoch);
    if (remote.checkedAt != null) {
      await prefs.setString(_Keys.checkedAt, remote.checkedAt!);
    }

    final current = await _currentManifest();
    if (current != null && remote.version <= current.version) {
      return UpdateResult.upToDate;
    }

    final fresh = <ContentSection, String>{};
    for (final s in ContentSection.values) {
      final want = remote.files[fileOf(s)];
      if (want == null) continue;
      // Unchanged files are kept from where they are now.
      if (current != null && current.files[fileOf(s)] == want) continue;
      final String raw;
      try {
        final res = await _client
            .get(Uri.parse('$base/${fileOf(s)}?v=${remote.version}'))
            .timeout(_timeout);
        if (res.statusCode != 200) return UpdateResult.offline;
        raw = utf8.decode(res.bodyBytes);
      } catch (_) {
        return UpdateResult.offline;
      }
      if (contentHash(raw) != want) return UpdateResult.rejected;
      final parsed = ContentLoader.parseSection(s, raw);
      if (parsed == null || parsed.items.isEmpty) return UpdateResult.rejected;
      fresh[s] = raw;
    }

    // Keep the files that did not change, from the current source, so the
    // stored set is always complete.
    final source = UpdatableContentSource(prefs);
    for (final s in ContentSection.values) {
      if (fresh.containsKey(s)) continue;
      final raw = await source.read(s);
      if (raw != null) fresh[s] = raw;
    }
    for (final e in fresh.entries) {
      await prefs.setString(_Keys.file(e.key), e.value);
    }
    await prefs.setString(_Keys.manifest, jsonEncode(remote.toJson()));
    return UpdateResult.updated;
  }

  Future<ContentManifest?> _currentManifest() async {
    final cached = cachedManifest(prefs);
    final inApp = await bundledManifest();
    if (cached == null) return inApp;
    if (inApp == null) return cached;
    return cached.version >= inApp.version ? cached : inApp;
  }
}

/// The updater, when the app keeps preferences (not in widget tests).
final contentUpdaterProvider = Provider<ContentUpdater?>((ref) {
  if (!ref.watch(contentUpdatesEnabledProvider)) return null;
  final prefs = ref.watch(preferencesProvider);
  return prefs == null ? null : ContentUpdater(prefs);
});

/// On in the real app (`main.dart`), off in tests and previews: no network.
final contentUpdatesEnabledProvider = Provider<bool>((ref) => false);

/// Date the published content was last checked against the official site.
final contentCheckedAtProvider = FutureProvider<String?>((ref) async {
  final prefs = ref.watch(preferencesProvider);
  final checked = prefs?.getString(_Keys.checkedAt);
  if (checked != null) return checked;
  final cached = prefs == null ? null : cachedManifest(prefs);
  final inApp = await bundledManifest();
  final pick = (cached?.version ?? 0) >= (inApp?.version ?? 0) ? cached : inApp;
  return pick?.checkedAt;
});
