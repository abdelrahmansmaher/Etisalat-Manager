import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/content_loader.dart';
import '../content/content_models.dart';
import '../content/content_providers.dart';
import 'content_overrides.dart';

/// Applies the owner's edits to the raw section files, before anything is
/// parsed. Lists, search and every screen therefore see the edited content.
class OverlayContentSource extends ContentSource {
  const OverlayContentSource(this.base, this.overrides);

  final ContentSource base;
  final Map<String, ContentOverride> overrides;

  @override
  Future<String?> read(ContentSection section) async {
    final raw = await base.read(section);
    final mine = [
      for (final o in overrides.values)
        if (o.section == section) o,
    ];
    return mine.isEmpty ? raw : applyOverrides(section, raw, mine);
  }

  /// [raw] with [edits] applied; unchanged when it is not a valid file.
  static String? applyOverrides(
    ContentSection section,
    String? raw,
    Iterable<ContentOverride> edits,
  ) {
    Map<String, dynamic> root;
    if (raw == null || raw.trim().isEmpty) {
      root = {'section': section.key, 'items': <dynamic>[]};
    } else {
      try {
        root = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        return raw; // the loader reports it
      }
    }
    final byId = {for (final o in edits) o.id: o};
    final items = <dynamic>[];
    final list = root['items'];
    for (final e in list is List ? list : const <dynamic>[]) {
      final o = e is RawItem ? byId.remove(e['id']) : null;
      if (o == null) {
        items.add(e);
        continue;
      }
      final edited = o.applyTo(e as RawItem);
      if (edited != null) items.add(edited);
    }
    for (final o in byId.values) {
      if (!o.isNew) continue; // the bundled original was removed
      final added = o.applyTo(null);
      if (added != null) items.add(added);
    }
    return jsonEncode({...root, 'items': items});
  }
}

/// What the content loader reads: the bundle plus the owner's edits.
final effectiveContentSourceProvider = Provider<ContentSource>((ref) {
  final base = ref.watch(contentSourceProvider);
  final overrides = ref.watch(overridesProvider);
  return overrides.isEmpty ? base : OverlayContentSource(base, overrides);
});

/// Raw items by id, with their section.
typedef RawItems = Map<String, (ContentSection, RawItem)>;

Future<RawItems> _readRaw(ContentSource source) async {
  final out = <String, (ContentSection, RawItem)>{};
  for (final s in ContentSection.values) {
    final raw = await source.read(s);
    if (raw == null || raw.trim().isEmpty) continue;
    try {
      final root = jsonDecode(raw);
      final items = root is Map ? root['items'] : null;
      if (items is! List) continue;
      for (final e in items) {
        if (e is RawItem && e['id'] is String) {
          out.putIfAbsent(e['id'] as String, () => (s, e));
        }
      }
    } catch (e) {
      debugPrint('content: ${s.key} raw not readable ($e)');
    }
  }
  return out;
}

/// Raw JSON of the bundled items without the owner's edits.
final bundledRawProvider = FutureProvider<RawItems>(
  (ref) => _readRaw(ref.watch(contentSourceProvider)),
);

/// How an edit relates to the bundled content now.
enum EditState {
  /// Added by the owner.
  added,

  /// The original is unchanged since the edit.
  current,

  /// The bundle has a newer version of the original.
  newerBundled,

  /// The original is no longer in the content.
  removed,
}

EditState editStateOf(ContentOverride o, RawItems bundled) {
  if (o.isNew) return EditState.added;
  final base = bundled[o.id];
  if (base == null) return EditState.removed;
  final was = o.baseFingerprint;
  return was == null || was == fingerprint(base.$2)
      ? EditState.current
      : EditState.newerBundled;
}
