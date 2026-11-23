import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'content_models.dart';

/// Where raw section JSON comes from. Injectable for tests.
abstract class ContentSource {
  const ContentSource();

  /// Raw JSON of [section], or `null` when the file does not exist.
  Future<String?> read(ContentSection section);
}

/// Reads `assets/content/<key>.json` from the app bundle.
class AssetContentSource extends ContentSource {
  const AssetContentSource([this.bundle]);

  final AssetBundle? bundle;

  @override
  Future<String?> read(ContentSection section) async {
    try {
      return await (bundle ?? rootBundle).loadString(section.assetPath);
    } catch (_) {
      return null; // missing file → empty section
    }
  }
}

/// In-memory source keyed by section (tests, previews).
class MemoryContentSource extends ContentSource {
  const MemoryContentSource(this.files);

  final Map<ContentSection, String> files;

  @override
  Future<String?> read(ContentSection section) async => files[section];
}

/// Loads and parses every section. Never throws: a missing or unreadable
/// file is an empty section, a malformed item is skipped (debugPrint).
abstract final class ContentLoader {
  static Future<ContentLibrary> load(ContentSource source) async {
    final raws = await Future.wait([
      for (final s in ContentSection.values) source.read(s),
    ]);
    final map = <ContentSection, SectionContent>{};
    final seen = <String>{};
    for (var i = 0; i < ContentSection.values.length; i++) {
      final section = ContentSection.values[i];
      final raw = raws[i];
      if (raw == null || raw.trim().isEmpty) continue;
      final parsed = parseSection(section, raw);
      if (parsed == null) continue;
      final items = <ContentItem>[];
      for (final item in parsed.items) {
        if (!seen.add(item.id)) {
          debugPrint('content: duplicate id ${item.id} in ${section.key}');
          continue;
        }
        items.add(item);
      }
      map[section] = SectionContent(
        section: section,
        asOf: parsed.asOf,
        sourceDocument: parsed.sourceDocument,
        items: items,
      );
    }
    return ContentLibrary(map);
  }

  /// Parses one file; `null` when the whole file is not valid JSON/shape.
  static SectionContent? parseSection(ContentSection section, String raw) {
    final Object? json;
    try {
      json = jsonDecode(raw);
    } catch (e) {
      debugPrint('content: ${section.key}.json is not valid JSON ($e)');
      return null;
    }
    if (json is! Map<String, dynamic>) {
      debugPrint('content: ${section.key}.json root is not an object');
      return null;
    }
    final items = <ContentItem>[];
    final list = json['items'];
    if (list is List) {
      for (var i = 0; i < list.length; i++) {
        final e = list[i];
        try {
          if (e is! Map<String, dynamic>) {
            throw const FormatException('item is not an object');
          }
          items.add(ContentItem.fromJson(e, section));
        } catch (err) {
          debugPrint('content: skipped ${section.key}[$i]: $err');
        }
      }
    }
    final asOf = json['as_of'];
    return SectionContent(
      section: section,
      asOf: asOf is String ? DateTime.tryParse(asOf) : null,
      sourceDocument: json['source_document'] is String
          ? json['source_document'] as String
          : null,
      items: items,
    );
  }
}
