import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:knowledge_hub/core/content/content.dart';
import 'package:knowledge_hub/core/content/content_updates.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app takes a newer published content set only when every file is
/// intact; anything wrong leaves what it has.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, dynamic> bundled;
  late String packages;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    bundled = jsonDecode(
      File('assets/content/manifest.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    packages = File('assets/content/packages.json').readAsStringSync();
  });

  /// A newer set where only packages.json changed (one price).
  (Map<String, dynamic>, String) newer() {
    final changed = packages.replaceFirst(
      '"price_total_egp": 74.29',
      '"price_total_egp": 78.58',
    );
    expect(changed, isNot(packages));
    return (
      {
        'version': (bundled['version'] as int) + 1,
        'checked_at': '2026-12-01',
        'files': {
          ...(bundled['files'] as Map).cast<String, String>(),
          'packages.json': contentHash(changed),
        },
      },
      changed,
    );
  }

  MockClient server(Map<String, dynamic> manifest, String packagesBody) =>
      MockClient((req) async {
        final path = req.url.path;
        if (path.endsWith('/manifest.json')) {
          return http.Response(jsonEncode(manifest), 200);
        }
        if (path.endsWith('/packages.json')) {
          return http.Response.bytes(utf8.encode(packagesBody), 200);
        }
        return http.Response('not found', 404);
      });

  Future<double?> priceOf52(SharedPreferences prefs) async {
    final lib = await ContentLoader.load(UpdatableContentSource(prefs));
    return lib.byId('pkg-hekaya-mixat-52')?.priceTotalEgp?.toDouble();
  }

  test('a newer, intact set is taken and read', () async {
    final prefs = await SharedPreferences.getInstance();
    final (manifest, body) = newer();
    final updater = ContentUpdater(prefs, client: server(manifest, body));
    expect(await priceOf52(prefs), 74.29);
    expect(await updater.check(), UpdateResult.updated);
    expect(await priceOf52(prefs), 78.58);
    // Other sections still read (kept from the app's copy).
    final lib = await ContentLoader.load(UpdatableContentSource(prefs));
    expect(lib.itemsOf(ContentSection.numbers), isNotEmpty);
    // Same version again: nothing to do.
    expect(await updater.check(), UpdateResult.upToDate);
  });

  test('a file that does not match its checksum is refused', () async {
    final prefs = await SharedPreferences.getInstance();
    final (manifest, body) = newer();
    final updater = ContentUpdater(
      prefs,
      client: server(manifest, body.replaceFirst('78.58', '99.99')),
    );
    expect(await updater.check(), UpdateResult.rejected);
    expect(await priceOf52(prefs), 74.29);
  });

  test('a broken file is refused even with a matching checksum', () async {
    final prefs = await SharedPreferences.getInstance();
    const broken = '{"section": "packages", "items": []}';
    final manifest = {
      ...newer().$1,
      'files': {
        ...(bundled['files'] as Map).cast<String, String>(),
        'packages.json': contentHash(broken),
      },
    };
    final updater = ContentUpdater(prefs, client: server(manifest, broken));
    expect(await updater.check(), UpdateResult.rejected);
    expect(await priceOf52(prefs), 74.29);
  });

  test('no network: nothing changes', () async {
    final prefs = await SharedPreferences.getInstance();
    final updater = ContentUpdater(
      prefs,
      client: MockClient((_) async => throw const SocketException('offline')),
    );
    expect(await updater.check(), UpdateResult.offline);
    expect(await priceOf52(prefs), 74.29);
  });

  test('the manifest inside the app matches its content files', () async {
    for (final s in ContentSection.values) {
      final raw = await rootBundle.loadString(s.assetPath);
      expect(
        contentHash(raw),
        (bundled['files'] as Map)['${s.key}.json'],
        reason: '${s.key}.json changed: run dart run tool/sync_official.dart',
      );
    }
  });
}
