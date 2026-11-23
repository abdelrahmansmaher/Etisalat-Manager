import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/content/content.dart';

import '../../helpers/content_fixtures.dart';

void main() {
  late ContentLibrary lib;
  setUpAll(() async => lib = await fixtureLibrary());

  test('loads valid sections and skips malformed items', () {
    final pkgs = lib.itemsOf(ContentSection.packages);
    // 7 entries in the file: one without id, one not an object → skipped.
    expect(pkgs.map((i) => i.id), [
      'pkg-test-alpha',
      'pkg-test-beta',
      'pkg-test-gamma',
      'pkg-test-unverified',
      'pkg-test-weird',
    ]);
    expect(lib.sections[ContentSection.packages]!.asOf, DateTime(2026, 1, 10));
  });

  test('missing file, invalid JSON and wrong root are empty sections', () {
    expect(lib.itemsOf(ContentSection.company), isEmpty); // missing
    expect(lib.itemsOf(ContentSection.wallet), isEmpty); // not JSON
    expect(lib.itemsOf(ContentSection.internet), isEmpty); // array root
  });

  test('parses every field', () {
    final a = lib.byId('pkg-test-alpha')!;
    expect(a.section, ContentSection.packages);
    expect(a.type, ItemType.package);
    expect(a.titleEn, 'Alpha Test Bundle');
    expect(a.facts, hasLength(5));
    expect(a.facts.first.kind, FactKind.price);
    expect(a.facts.first.display, '11.11 ج');
    expect(a.codes, ['*999#']);
    expect(a.status, ItemStatus.confirmed);
    expect(a.sources[1].type, ContentSourceType.officialSite);
    expect(a.sources[1].url, 'https://example.com/alpha');
    expect(a.pdfPages, [7]);
    expect(a.related, ['pkg-test-beta']);
    expect(a.leadValue, '11.11 ج');
  });

  test('unknown enum values fall back safely', () {
    final w = lib.byId('pkg-test-weird')!;
    expect(w.type, ItemType.article);
    expect(w.status, ItemStatus.unconfirmed); // never upgraded
    expect(w.facts.single.kind, FactKind.text);
    expect(w.sources.single.type, ContentSourceType.other);
  });

  test('library helpers', () {
    expect(lib.latestAsOf, DateTime(2026, 3, 1));
    expect(
      lib.needsReview.map((i) => i.id),
      containsAll([
        'pkg-test-beta',
        'pkg-test-gamma',
        'pkg-test-unverified',
        'pkg-test-weird',
      ]),
    );
    expect(lib.needsReview.any((i) => i.status == ItemStatus.confirmed), false);
    expect(lib.byId('nope'), isNull);
  });

  test('empty source never throws', () async {
    final empty = await ContentLoader.load(const MemoryContentSource({}));
    expect(empty.isEmpty, isTrue);
    expect(empty.latestAsOf, isNull);
  });

  test('duplicate ids across files keep the first', () async {
    const a = '{"items":[{"id":"x","title_ar":"أ","status":"confirmed"}]}';
    const b = '{"items":[{"id":"x","title_ar":"ب"}]}';
    final l = await ContentLoader.load(
      const MemoryContentSource({
        ContentSection.packages: a,
        ContentSection.glossary: b,
      }),
    );
    expect(l.length, 1);
    expect(l.byId('x')!.title, 'أ');
    expect(l.itemsOf(ContentSection.glossary), isEmpty);
  });

  test('parseSection rejects non-object root', () {
    expect(ContentLoader.parseSection(ContentSection.packages, '[]'), isNull);
    expect(ContentLoader.parseSection(ContentSection.packages, '{'), isNull);
    final ok = ContentLoader.parseSection(ContentSection.packages, '{}');
    expect(ok!.items, isEmpty);
  });
}
