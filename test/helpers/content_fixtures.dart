import 'dart:io';

import 'package:knowledge_hub/core/content/content.dart';

/// Fake content from `test/fixtures/content` (never the real JSON files).
MemoryContentSource fixtureContentSource() {
  final files = <ContentSection, String>{};
  for (final s in ContentSection.values) {
    final f = File('test/fixtures/content/${s.key}.json');
    if (f.existsSync()) files[s] = f.readAsStringSync();
  }
  return MemoryContentSource(files);
}

/// The fixture library, parsed.
Future<ContentLibrary> fixtureLibrary() =>
    ContentLoader.load(fixtureContentSource());
