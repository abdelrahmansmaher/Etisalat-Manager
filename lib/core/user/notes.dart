import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../search/arabic_normalizer.dart';
import 'json_store.dart';

/// A private note, optionally attached to a content item. Never exported.
@immutable
class PrivateNote {
  const PrivateNote({
    required this.id,
    required this.text,
    required this.updatedAt,
    this.itemId,
    this.itemTitle,
  });

  final String id;
  final String text;
  final DateTime updatedAt;
  final String? itemId;

  /// Title when the note was written, so the note still says what it is
  /// about if the item is removed later.
  final String? itemTitle;

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'at': updatedAt.toIso8601String(),
    'item': ?itemId,
    'title': ?itemTitle,
  };

  static PrivateNote? tryParse(Object? j) {
    if (j is! Map || j['id'] is! String || j['text'] is! String) return null;
    return PrivateNote(
      id: j['id'] as String,
      text: j['text'] as String,
      updatedAt:
          DateTime.tryParse('${j['at']}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      itemId: j['item'] is String ? j['item'] as String : null,
      itemTitle: j['title'] is String ? j['title'] as String : null,
    );
  }
}

/// Private notes, newest first, only on this device.
final notesProvider = NotifierProvider<Notes, List<PrivateNote>>(Notes.new);

/// Notes attached to one item.
final itemNotesProvider = Provider.family<List<PrivateNote>, String>(
  (ref, id) => [
    for (final n in ref.watch(notesProvider))
      if (n.itemId == id) n,
  ],
);

class Notes extends Notifier<List<PrivateNote>> {
  @override
  List<PrivateNote> build() {
    final doc = readJsonDoc(ref, UserKeys.notes);
    return [
      if (doc is List)
        for (final e in doc) ?PrivateNote.tryParse(e),
    ];
  }

  /// Adds a note (blank text is ignored).
  void add(String text, {String? itemId, String? itemTitle}) {
    final t = text.trim();
    if (t.isEmpty) return;
    final now = ref.read(clockProvider)();
    var id = 'n${now.microsecondsSinceEpoch}';
    while (state.any((n) => n.id == id)) {
      id = '${id}x';
    }
    _set([
      PrivateNote(
        id: id,
        text: t,
        updatedAt: now,
        itemId: itemId,
        itemTitle: itemTitle,
      ),
      ...state,
    ]);
  }

  void edit(String id, String text) {
    final t = text.trim();
    final old = state.where((n) => n.id == id).firstOrNull;
    if (t.isEmpty || old == null || old.text == t) return;
    _set([
      PrivateNote(
        id: id,
        text: t,
        updatedAt: ref.read(clockProvider)(),
        itemId: old.itemId,
        itemTitle: old.itemTitle,
      ),
      for (final n in state)
        if (n.id != id) n,
    ]);
  }

  void remove(String id) => _set([
    for (final n in state)
      if (n.id != id) n,
  ]);

  /// Undo of [remove].
  void putBack(PrivateNote note) {
    if (state.any((n) => n.id == note.id)) return;
    _set([...state, note]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));
  }

  void _set(List<PrivateNote> next) {
    state = next;
    writeJsonDoc(ref, UserKeys.notes, [for (final n in next) n.toJson()]);
  }
}

/// Notes matching every word of [query] (Arabic spelling variants folded).
List<PrivateNote> searchNotes(List<PrivateNote> notes, String query) {
  final words = normalizeArabic(
    query,
  ).split(' ').where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return notes;
  return [
    for (final n in notes)
      if (_matches(normalizeArabic('${n.text} ${n.itemTitle ?? ''}'), words)) n,
  ];
}

bool _matches(String hay, List<String> words) => words.every(hay.contains);
