import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/content_models.dart';
import 'json_store.dart';

/// Raw JSON of a content item, as stored in `assets/content/*.json`.
typedef RawItem = Map<String, dynamic>;

/// Words shown on every edited or added item until it is restored.
const String kEditedByOwner = 'معدّل منك';

/// One edit of the owner: replaced fields of a bundled item, or a whole new
/// item. Lives only on this device.
@immutable
class ContentOverride {
  const ContentOverride({
    required this.id,
    required this.section,
    required this.editedAt,
    this.isNew = false,
    this.hidden = false,
    this.fields = const {},
    this.baseFingerprint,
  });

  final String id;
  final ContentSection section;

  /// Added by the owner; there is no bundled original.
  final bool isNew;

  /// Hidden by the owner ("إخفاء"); the item disappears from the app until
  /// it is restored from the edits list.
  final bool hidden;

  /// Replaced JSON fields; only keys in [editableKeys].
  final RawItem fields;
  final DateTime editedAt;

  /// [fingerprint] of the bundled item when it was edited.
  final String? baseFingerprint;

  static const Set<String> editableKeys = {
    'title_ar',
    'summary_ar',
    'category_ar',
    'type',
    'facts',
    'codes',
    'phones',
    'status_note_ar',
  };

  static const int _maxText = 20000;
  static const int _maxList = 300;

  ContentOverride copyWith({
    bool? hidden,
    RawItem? fields,
    DateTime? editedAt,
    String? baseFingerprint,
  }) => ContentOverride(
    id: id,
    section: section,
    isNew: isNew,
    hidden: hidden ?? this.hidden,
    fields: fields ?? this.fields,
    editedAt: editedAt ?? this.editedAt,
    baseFingerprint: baseFingerprint ?? this.baseFingerprint,
  );

  RawItem toJson() => {
    'id': id,
    'section': section.key,
    if (isNew) 'new': true,
    if (hidden) 'hidden': true,
    'fields': fields,
    'edited_at': editedAt.toIso8601String(),
    'base': ?baseFingerprint,
  };

  /// Same edit, ignoring when it was made.
  bool sameEditAs(ContentOverride o) =>
      id == o.id &&
      section == o.section &&
      isNew == o.isNew &&
      hidden == o.hidden &&
      canonicalJson(fields) == canonicalJson(o.fields);

  /// Strict: throws [FormatException] on anything unexpected, so an import
  /// can never bring in a status, a source or a wrong type.
  factory ContentOverride.fromJson(Object? j) {
    if (j is! Map) throw const FormatException('edit is not an object');
    final id = j['id'];
    if (id is! String || id.trim().isEmpty || id.length > 200) {
      throw const FormatException('edit without id');
    }
    final section = ContentSection.fromKey(
      j['section'] is String ? j['section'] as String : null,
    );
    if (section == null) throw FormatException('unknown section in $id');
    final at = j['edited_at'] is String
        ? DateTime.tryParse(j['edited_at'] as String)
        : null;
    if (at == null) throw FormatException('no date in $id');
    final rawFields = j['fields'];
    if (rawFields is! Map) throw FormatException('no fields in $id');
    final fields = <String, dynamic>{};
    for (final e in rawFields.entries) {
      final k = e.key;
      if (k is! String || !editableKeys.contains(k)) {
        throw FormatException('field "$k" not allowed in $id');
      }
      fields[k] = _checkField(id, k, e.value);
    }
    final isNew = j['new'] == true;
    final title = fields['title_ar'];
    if ((isNew || fields.containsKey('title_ar')) &&
        (title is! String || title.trim().isEmpty)) {
      throw FormatException('no title in $id');
    }
    return ContentOverride(
      id: id.trim(),
      section: section,
      isNew: isNew,
      hidden: j['hidden'] == true,
      fields: fields,
      editedAt: at,
      baseFingerprint: j['base'] is String ? j['base'] as String : null,
    );
  }

  static Object? _checkField(String id, String key, Object? v) {
    Never bad() => throw FormatException('bad value for "$key" in $id');
    String text(Object? t) {
      if (t is! String || t.length > _maxText) bad();
      return t;
    }

    switch (key) {
      case 'facts':
        if (v is! List || v.length > _maxList) bad();
        return [
          for (final f in v)
            if (f is Map)
              {
                'label_ar': text(f['label_ar']),
                'value': text(f['value']),
                if (f['unit'] != null) 'unit': text(f['unit']),
                'kind': FactKind.parse(f['kind']).name,
              }
            else
              bad(),
        ];
      case 'codes' || 'phones':
        if (v is! List || v.length > _maxList) bad();
        return [for (final s in v) text(s)];
      default:
        return text(v);
    }
  }

  /// Structured values derived from the original facts. They are dropped
  /// when the facts are edited, so an old number can never win over the
  /// owner's new one.
  static bool _isDerived(String key) =>
      key.startsWith('price_') ||
      key.startsWith('quota_') ||
      key.startsWith('validity_');

  /// Anything that claims a check happened.
  static bool _isVerification(String key) =>
      key.startsWith('checked') ||
      key.startsWith('verified') ||
      key.startsWith('official') ||
      key.startsWith('last_verified');

  /// The item as the app should see it, or `null` when it must not be shown
  /// (hidden, or the bundled original is gone).
  ///
  /// The result is never `confirmed` and carries no check date, so
  /// `officiallyVerified` is false and no screen can call it confirmed.
  RawItem? applyTo(RawItem? base) {
    if (hidden) return null;
    if (base == null && !isNew) return null;
    final out = <String, dynamic>{
      'id': id,
      if (base != null)
        for (final e in base.entries)
          if (!_isVerification(e.key)) e.key: e.value,
    };
    if (fields.containsKey('facts')) out.removeWhere((k, _) => _isDerived(k));
    out.addAll(fields);
    out['id'] = id;
    if (out['status'] != 'conflict') out['status'] = 'unconfirmed';
    final stamp = '$kEditedByOwner – ${isoDate(editedAt)}';
    final note = out['status_note_ar'];
    out['status_note_ar'] = note is String && note.trim().isNotEmpty
        ? '$stamp. ${note.trim()}'
        : stamp;
    out['sources'] = [
      {'name': stamp, 'type': 'other'},
      if (base?['sources'] case final List<dynamic> list)
        for (final s in list)
          if (s is Map)
            {
              for (final e in s.entries)
                if (e.key is String && !_isVerification(e.key as String))
                  e.key as String: e.value,
            },
    ];
    out['user_edited_at'] = editedAt.toIso8601String();
    return out;
  }
}

/// JSON with sorted keys, for comparing.
String canonicalJson(Object? v) => jsonEncode(_sorted(v));

Object? _sorted(Object? v) {
  if (v is Map) {
    final keys = [for (final k in v.keys) '$k']..sort();
    return {for (final k in keys) k: _sorted(v[k])};
  }
  if (v is List) return [for (final e in v) _sorted(e)];
  return v;
}

/// Short hash of what the owner sees of a bundled item. Re-checking a source
/// (dates, tags, page numbers) does not change it.
String fingerprint(RawItem item) => hashText(
  canonicalJson({
    for (final k in const [
      'title_ar',
      'category_ar',
      'summary_ar',
      'body_ar',
      'facts',
      'steps_ar',
      'codes',
      'phones',
      'status',
      'status_note_ar',
    ])
      if (item[k] != null) k: item[k],
  }),
);

/// Small stable hash (safe for web integers).
String hashText(String s) {
  var a = 7, b = 17;
  for (final c in s.codeUnits) {
    a = (a * 31 + c) & 0x7fffffff;
    b = (b * 131 + c) & 0x7fffffff;
  }
  return '${a.toRadixString(36)}-${b.toRadixString(36)}-${s.length}';
}

/// The owner's edits by item id.
final overridesProvider =
    NotifierProvider<Overrides, Map<String, ContentOverride>>(Overrides.new);

/// The edit of one item, if any (badge "معدّل منك – date").
final itemOverrideProvider = Provider.family<ContentOverride?, String>(
  (ref, id) => ref.watch(overridesProvider)[id],
);

class Overrides extends Notifier<Map<String, ContentOverride>> {
  @override
  Map<String, ContentOverride> build() {
    final doc = readJsonDoc(ref, UserKeys.overrides);
    final out = <String, ContentOverride>{};
    if (doc is List) {
      for (final e in doc) {
        try {
          final o = ContentOverride.fromJson(e);
          out[o.id] = o;
        } catch (err) {
          debugPrint('user data: skipped an edit: $err');
        }
      }
    }
    return out;
  }

  void save(ContentOverride o) => _set({...state, o.id: o});

  void saveAll(Iterable<ContentOverride> list) =>
      _set({...state, for (final o in list) o.id: o});

  /// Back to the bundled original (or deletes an added item).
  void restore(String id) => _set({...state}..remove(id));

  /// The owner saw the newer bundled version and keeps the edit.
  void keepMine(String id, String newBase) {
    final o = state[id];
    if (o != null) save(o.copyWith(baseFingerprint: newBase));
  }

  /// Id for a new item, never equal to a bundled one.
  String newId() {
    final base = 'user-${ref.read(clockProvider)().millisecondsSinceEpoch}';
    var id = base;
    for (var n = 2; state.containsKey(id); n++) {
      id = '$base-$n';
    }
    return id;
  }

  void _set(Map<String, ContentOverride> next) {
    state = next;
    writeJsonDoc(ref, UserKeys.overrides, [
      for (final o in next.values) o.toJson(),
    ]);
  }
}
