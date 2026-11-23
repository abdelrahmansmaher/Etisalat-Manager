/// Models for the bundled content (see `assets/content/SCHEMA.md`).
///
/// Pure Dart. Parsing is lenient: unknown enum values fall back to a safe
/// default, missing optional fields become empty, and only an item without
/// `id` or `title_ar` is rejected (by throwing [FormatException], which the
/// loader catches per item).
library;

/// The content sections, one JSON file each.
enum ContentSection {
  packages('packages'),
  internet('internet'),
  procedures('procedures'),
  numbers('numbers'),
  wallet('wallet'),
  glossary('glossary'),
  company('company');

  const ContentSection(this.key);

  /// Section key as used in the JSON `section` field and in routes.
  final String key;

  /// Asset path of the section file.
  String get assetPath => 'assets/content/$key.json';

  static ContentSection? fromKey(String? key) {
    for (final s in values) {
      if (s.key == key) return s;
    }
    return null;
  }
}

/// Item status. Unknown values are treated as [unconfirmed] — never upgrade
/// to confirmed by accident.
enum ItemStatus {
  confirmed,
  unconfirmed,
  conflict;

  static ItemStatus parse(Object? v) => switch (v) {
    'confirmed' => confirmed,
    'conflict' => conflict,
    _ => unconfirmed,
  };
}

/// Item type. Unknown values fall back to [article].
enum ItemType {
  article,
  package,
  service,
  contact,
  code,
  fee,
  limit,
  procedure,
  rule,
  faq,
  glossary,
  unverified;

  static ItemType parse(Object? v) {
    for (final t in values) {
      if (t.name == v) return t;
    }
    return article;
  }
}

/// Fact kind. Unknown values fall back to [text].
enum FactKind {
  price,
  code,
  phone,
  quantity,
  duration,
  percent,
  date,
  text;

  static FactKind parse(Object? v) {
    for (final k in values) {
      if (k.name == v) return k;
    }
    return text;
  }

  /// Values of this kind are rendered left-to-right.
  bool get isLtr => this != text;
}

/// Source type. Unknown values fall back to [other].
enum ContentSourceType {
  pdfGuide('pdf_guide'),
  officialSite('official_site'),
  regulator('regulator'),
  press('press'),
  wikipedia('wikipedia'),
  appStore('app_store'),
  other('other');

  const ContentSourceType(this.key);
  final String key;

  static ContentSourceType parse(Object? v) {
    for (final t in values) {
      if (t.key == v) return t;
    }
    return other;
  }
}

String _str(Object? v) => v is String ? v.trim() : (v == null ? '' : '$v');

String? _optStr(Object? v) {
  final s = _str(v);
  return s.isEmpty ? null : s;
}

List<String> _strList(Object? v) => v is List
    ? [
        for (final e in v)
          if (e != null && _str(e).isNotEmpty) _str(e),
      ]
    : const [];

class Fact {
  const Fact({
    required this.label,
    required this.value,
    this.unit,
    this.kind = FactKind.text,
  });

  factory Fact.fromJson(Map<String, dynamic> j) => Fact(
    label: _str(j['label_ar']),
    value: _str(j['value']),
    unit: _optStr(j['unit']),
    kind: FactKind.parse(j['kind']),
  );

  final String label;
  final String value;
  final String? unit;
  final FactKind kind;

  /// Value with its unit, e.g. `52 ج`.
  String get display => unit == null ? value : '$value $unit';
}

class Source {
  const Source({
    required this.name,
    this.url,
    this.type = ContentSourceType.other,
  });

  factory Source.fromJson(Map<String, dynamic> j) => Source(
    name: _str(j['name']),
    url: _optStr(j['url']),
    type: ContentSourceType.parse(j['type']),
  );

  final String name;
  final String? url;
  final ContentSourceType type;
}

class ContentItem {
  const ContentItem({
    required this.id,
    required this.section,
    required this.title,
    this.type = ItemType.article,
    this.category = '',
    this.titleEn,
    this.summary = '',
    this.body,
    this.facts = const [],
    this.steps = const [],
    this.codes = const [],
    this.phones = const [],
    this.tags = const [],
    this.status = ItemStatus.unconfirmed,
    this.statusNote,
    this.sources = const [],
    this.pdfPages = const [],
    this.related = const [],
  });

  /// Throws [FormatException] when `id` or `title_ar` is missing.
  factory ContentItem.fromJson(Map<String, dynamic> j, ContentSection section) {
    final id = _str(j['id']);
    final title = _str(j['title_ar']);
    if (id.isEmpty || title.isEmpty) {
      throw const FormatException('item without id/title_ar');
    }
    List<T> objs<T>(Object? v, T Function(Map<String, dynamic>) f) => v is List
        ? [
            for (final e in v)
              if (e is Map<String, dynamic>) f(e),
          ]
        : const [];
    return ContentItem(
      id: id,
      section: section,
      type: ItemType.parse(j['type']),
      category: _str(j['category_ar']),
      title: title,
      titleEn: _optStr(j['title_en']),
      summary: isolateCodes(_str(j['summary_ar'])),
      body: _optIsolated(j['body_ar']),
      facts: objs(j['facts'], Fact.fromJson),
      steps: [for (final s in _strList(j['steps_ar'])) isolateCodes(s)],
      codes: _strList(j['codes']),
      phones: _strList(j['phones']),
      tags: _strList(j['tags']),
      status: ItemStatus.parse(j['status']),
      statusNote: _optIsolated(j['status_note_ar']),
      sources: objs(j['sources'], Source.fromJson),
      pdfPages: [
        if (j['pdf_pages'] is List)
          for (final p in j['pdf_pages'] as List)
            if (p is num)
              p.toInt()
            else if (int.tryParse('$p') != null)
              int.parse('$p'),
      ],
      related: _strList(j['related']),
    );
  }

  final String id;
  final ContentSection section;
  final ItemType type;
  final String category;
  final String title;
  final String? titleEn;
  final String summary;
  final String? body;
  final List<Fact> facts;
  final List<String> steps;
  final List<String> codes;
  final List<String> phones;
  final List<String> tags;
  final ItemStatus status;
  final String? statusNote;
  final List<Source> sources;
  final List<int> pdfPages;
  final List<String> related;

  bool get isUnverifiedGroup =>
      type == ItemType.unverified || status != ItemStatus.confirmed;

  /// First code/phone/price worth showing in a list row.
  String? get leadValue {
    for (final f in facts) {
      if (f.kind == FactKind.code ||
          f.kind == FactKind.phone ||
          f.kind == FactKind.price) {
        if (f.value.isNotEmpty) return f.display;
      }
    }
    if (codes.isNotEmpty) return codes.first;
    if (phones.isNotEmpty) return phones.first;
    return null;
  }
}

/// One parsed section file.
class SectionContent {
  const SectionContent({
    required this.section,
    this.asOf,
    this.sourceDocument,
    this.items = const [],
  });

  final ContentSection section;
  final DateTime? asOf;
  final String? sourceDocument;
  final List<ContentItem> items;
}

/// Everything loaded, with lookups.
class ContentLibrary {
  ContentLibrary(Map<ContentSection, SectionContent> sections)
    : sections = Map.unmodifiable(sections) {
    for (final s in this.sections.values) {
      for (final i in s.items) {
        _byId.putIfAbsent(i.id, () => i);
      }
    }
  }

  static final ContentLibrary empty = ContentLibrary(const {});

  final Map<ContentSection, SectionContent> sections;
  final Map<String, ContentItem> _byId = {};

  List<ContentItem> itemsOf(ContentSection s) => sections[s]?.items ?? const [];

  ContentItem? byId(String id) => _byId[id];

  Iterable<ContentItem> get all => _byId.values;

  int get length => _byId.length;

  bool get isEmpty => _byId.isEmpty;

  /// Most recent `as_of` across files.
  DateTime? get latestAsOf {
    DateTime? best;
    for (final s in sections.values) {
      final d = s.asOf;
      if (d != null && (best == null || d.isAfter(best))) best = d;
    }
    return best;
  }

  /// Every item not confirmed (unconfirmed or conflict), in section order.
  List<ContentItem> get needsReview => [
    for (final s in ContentSection.values)
      for (final i in itemsOf(s))
        if (i.status != ItemStatus.confirmed) i,
  ];
}

/// USSD/MMI codes (`*319#`, `*566*2375#`, `##002#`) embedded in Arabic prose.
final RegExp _codeInProse = RegExp(r'[*#]+[0-9][0-9*#]*#?');

/// Wraps every code inside [text] in LEFT-TO-RIGHT MARKs (U+200E; LRI/PDI isolates are not honoured by the web renderer) so it keeps its
/// left-to-right order inside right-to-left sentences (otherwise `*319#`
/// can render as `#319*`). The search normalizer strips these invisible
/// marks, so indexing is unaffected.
final String _lri = String.fromCharCode(0x200E);
final String _pdi = String.fromCharCode(0x200E);

String isolateCodes(String text) => text.replaceAllMapped(
      _codeInProse,
      (m) => '$_lri${m[0]}$_pdi',
    );

String? _optIsolated(Object? v) {
  final s = _optStr(v);
  return s == null ? null : isolateCodes(s);
}
