import 'dart:convert';

import 'content_overrides.dart';

/// Export / import of the owner's edits. Private notes are never part of it.
abstract final class OverridesTransfer {
  static const String format = 'counter_guide.edits';
  static const int version = 1;
  static const int maxLength = 2 * 1024 * 1024;

  static String export(Iterable<ContentOverride> edits, DateTime now) =>
      const JsonEncoder.withIndent(' ').convert({
        'format': format,
        'version': version,
        'exported_at': now.toIso8601String(),
        'edits': [for (final o in edits) o.toJson()],
      });

  /// Throws [FormatException] unless the whole text is valid.
  static List<ContentOverride> parse(String text) {
    final t = text.trim();
    if (t.isEmpty || t.length > maxLength) {
      throw const FormatException('empty or too long');
    }
    final Object? doc = jsonDecode(t);
    if (doc is! Map || doc['format'] != format) {
      throw const FormatException('not an export of this app');
    }
    if (doc['version'] != version) {
      throw const FormatException('unsupported version');
    }
    final list = doc['edits'];
    if (list is! List) throw const FormatException('no edits');
    final out = [for (final e in list) ContentOverride.fromJson(e)];
    if ({for (final o in out) o.id}.length != out.length) {
      throw const FormatException('duplicate id');
    }
    return out;
  }

  static ImportDiff diff(
    Map<String, ContentOverride> mine,
    List<ContentOverride> incoming,
  ) {
    final added = <ContentOverride>[];
    final replaced = <ContentOverride>[];
    var same = 0;
    for (final o in incoming) {
      final old = mine[o.id];
      if (old == null) {
        added.add(o);
      } else if (old.sameEditAs(o)) {
        same++;
      } else {
        replaced.add(o);
      }
    }
    return ImportDiff(added: added, replaced: replaced, same: same);
  }
}

class ImportDiff {
  const ImportDiff({
    required this.added,
    required this.replaced,
    required this.same,
  });

  final List<ContentOverride> added;
  final List<ContentOverride> replaced;
  final int same;

  bool get isEmpty => added.isEmpty && replaced.isEmpty;
}
