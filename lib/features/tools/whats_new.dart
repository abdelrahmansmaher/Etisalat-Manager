import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/content.dart';
import '../../core/user/content_overlay.dart';
import '../../core/user/content_overrides.dart';
import '../../core/user/json_store.dart';
import '../content/package_facts.dart';

enum ChangeField { price, code }

@immutable
class ContentChange {
  const ContentChange({
    required this.id,
    required this.title,
    required this.field,
    required this.before,
    required this.after,
  });

  final String id;
  final String title;
  final ChangeField field;

  /// Empty = not stated.
  final String before;
  final String after;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'field': field.name,
    'before': before,
    'after': after,
  };
}

/// What changed when a newer content version arrived.
@immutable
class ContentUpdate {
  const ContentUpdate({
    required this.at,
    this.changes = const [],
    this.added = const [],
    this.removed = 0,
    this.seen = false,
  });

  final DateTime at;
  final List<ContentChange> changes;

  /// (id, title) of new items.
  final List<(String, String)> added;

  /// Only a count: "اتشال N بند".
  final int removed;
  final bool seen;

  bool get isEmpty => changes.isEmpty && added.isEmpty && removed == 0;

  ContentUpdate asSeen() => ContentUpdate(
    at: at,
    changes: changes,
    added: added,
    removed: removed,
    seen: true,
  );

  Map<String, dynamic> toJson() => {
    'at': at.toIso8601String(),
    'changes': [for (final c in changes) c.toJson()],
    'added': [
      for (final (id, title) in added) [id, title],
    ],
    'removed': removed,
    'seen': seen,
  };

  static ContentUpdate? tryParse(Object? j) {
    if (j is! Map) return null;
    final at = DateTime.tryParse('${j['at']}');
    if (at == null) return null;
    return ContentUpdate(
      at: at,
      seen: j['seen'] == true,
      removed: j['removed'] is int ? j['removed'] as int : 0,
      added: [
        if (j['added'] case final List<dynamic> l)
          for (final e in l)
            if (e is List && e.length == 2) ('${e[0]}', '${e[1]}'),
      ],
      changes: [
        if (j['changes'] case final List<dynamic> l)
          for (final e in l)
            if (e is Map)
              ContentChange(
                id: '${e['id']}',
                title: '${e['title']}',
                field: e['field'] == 'code'
                    ? ChangeField.code
                    : ChangeField.price,
                before: '${e['before']}',
                after: '${e['after']}',
              ),
      ],
    );
  }
}

/// id → [title, price, code] of the bundled content.
typedef ContentSnapshot = Map<String, List<String>>;

ContentSnapshot snapshotOf(RawItems raw) {
  final out = <String, List<String>>{};
  for (final e in raw.entries) {
    final ContentItem item;
    try {
      item = ContentItem.fromJson(e.value.$2, e.value.$1);
    } catch (_) {
      continue;
    }
    String price, code;
    if (item.type == ItemType.package) {
      final f = PackageFacts.of(item);
      price = f.price?.display ?? f.rechargePrice?.display ?? '';
      code = f.code?.value ?? item.codes.firstOrNull ?? '';
    } else {
      price =
          item.facts
              .where((f) => f.kind == FactKind.price)
              .firstOrNull
              ?.display ??
          '';
      code = ([...item.codes]..sort()).join(' · ');
    }
    out[item.id] = [item.title, price, code];
  }
  return out;
}

ContentUpdate diffSnapshots(
  ContentSnapshot before,
  ContentSnapshot after,
  DateTime at,
) {
  final changes = <ContentChange>[];
  final added = <(String, String)>[];
  for (final e in after.entries) {
    final old = before[e.key];
    final now = e.value;
    if (old == null) {
      added.add((e.key, now[0]));
      continue;
    }
    for (final (i, field) in const [
      (1, ChangeField.price),
      (2, ChangeField.code),
    ]) {
      if (_canon(old[i], field) == _canon(now[i], field)) continue;
      changes.add(
        ContentChange(
          id: e.key,
          title: now[0],
          field: field,
          before: old[i],
          after: now[i],
        ),
      );
    }
  }
  return ContentUpdate(
    at: at,
    changes: changes,
    added: added,
    removed: before.keys.where((k) => !after.containsKey(k)).length,
  );
}

/// Wording of the unit (`ج` / `جنيه`) or spacing is not a change.
String _canon(String v, ChangeField field) {
  final s = v.replaceAll(RegExp(r'[\s,\u200E\u200F]'), '');
  if (field == ChangeField.code) return s;
  final m = RegExp(r'^(\d+(?:\.\d+)?)(?:ج|جنيه)?$').firstMatch(s);
  return m == null ? s : '${double.parse(m[1]!)}';
}

/// Newest first; only this device, no network.
///
/// The first read after an app update compares the bundle with the stored
/// snapshot, so watch it (or [whatsNewUnseenProvider]) from the home screen.
final whatsNewProvider =
    AsyncNotifierProvider<WhatsNewNotifier, List<ContentUpdate>>(
      WhatsNewNotifier.new,
    );

/// Some update was not opened yet (badge / banner).
final whatsNewUnseenProvider = Provider<bool>(
  (ref) => (ref.watch(whatsNewProvider).value ?? const []).any((u) => !u.seen),
);

class WhatsNewNotifier extends AsyncNotifier<List<ContentUpdate>> {
  static const int keep = 5;

  @override
  Future<List<ContentUpdate>> build() async {
    final savedChanges = readJsonDoc(ref, UserKeys.changes);
    final savedSnapshot = readJsonDoc(ref, UserKeys.snapshot);
    final raw = await ref.watch(bundledRawProvider.future);
    final updates = <ContentUpdate>[
      if (savedChanges is List)
        for (final e in savedChanges) ?ContentUpdate.tryParse(e),
    ];
    if (raw.isEmpty) return updates; // content not readable: compare later

    final now = snapshotOf(raw);
    final hash = hashText(canonicalJson(now));
    if (savedSnapshot is Map && savedSnapshot['hash'] == hash) return updates;

    final before = _parseSnapshot(savedSnapshot);
    if (before != null) {
      final u = diffSnapshots(before, now, ref.read(clockProvider)());
      if (!u.isEmpty) {
        updates.insert(0, u);
        if (updates.length > keep) updates.length = keep;
        _store(updates);
      }
    }
    writeJsonDoc(ref, UserKeys.snapshot, {'hash': hash, 'items': now});
    return updates;
  }

  void markSeen() {
    final list = state.value;
    if (list == null || list.every((u) => u.seen)) return;
    final next = [for (final u in list) u.asSeen()];
    state = AsyncData(next);
    _store(next);
  }

  void _store(List<ContentUpdate> list) =>
      writeJsonDoc(ref, UserKeys.changes, [for (final u in list) u.toJson()]);

  static ContentSnapshot? _parseSnapshot(Object? doc) {
    final items = doc is Map ? doc['items'] : null;
    if (items is! Map) return null;
    return {
      for (final e in items.entries)
        if (e.value case final List<dynamic> l when l.length == 3)
          '${e.key}': [for (final v in l) '$v'],
    };
  }
}
