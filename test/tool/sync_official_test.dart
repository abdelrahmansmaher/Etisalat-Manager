import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/sync/official.dart';
import '../../tool/sync_official.dart';

/// The daily sync on a small made-up site and content.
void main() {
  Map<String, dynamic> bundle(
    String name,
    String price,
    String mix,
    String code,
  ) => {
    'title': {
      'bundleName': name,
      'bundlePrice': " <span class='englishNumber'> $price</span>",
      'unit': 'EGP',
      'fees': 'Monthly Fees Including Recharge Tax',
    },
    'bundleDesc': {'value': mix, 'unit': 'Mix'},
    'benefitList': [
      {'benefitTitle': 'Code', 'benefitValue': code},
    ],
  };

  String site(List<Map<String, dynamic>> bundles) => jsonEncode({
    'hekaya-mixat': {
      'tabs': [
        {'name': 'Monthly Renewal', 'bundles': bundles},
      ],
    },
  });

  final standard = [
    for (final (n, p, m) in [
      (52, '74.29', '1900'),
      (69, '98.58', '2800'),
      (92, '131.44', '3750'),
      (120, '171.44', '5375'),
    ])
      bundle('Hekaya Mixat $n', p, m, '*319*$n#'),
  ];

  Map<String, dynamic> item(int n, double total, int mix) => {
    'id': 'pkg-hekaya-mixat-$n',
    'type': 'package',
    'category_ar': 'حكاية ميكسات',
    'family': 'hekaya-mixat',
    'title_ar': 'حكاية ميكسات $n',
    'title_en': 'Hekaya Mixat $n',
    'summary_ar': '$mix ميكس بـ $n ج ($total ج شامل الضريبة) — اشترك *319*$n#',
    'facts': [
      {
        'label_ar': 'السعر (الخصم من الرصيد)',
        'value': '$n',
        'kind': 'price',
        'unit': 'ج',
      },
      {
        'label_ar': 'السعر المطلوب شحنه / شامل الضريبة',
        'value': '$total',
        'kind': 'price',
        'unit': 'ج',
      },
      {'label_ar': 'الحصة (ميكس)', 'value': '$mix', 'kind': 'quantity'},
      {'label_ar': 'كود الاشتراك', 'value': '*319*$n#', 'kind': 'code'},
    ],
    'price_egp': n,
    'price_total_egp': total,
    'quota_mix': mix,
    'codes': ['*319*$n#'],
    'status': 'confirmed',
    'sources': [
      {
        'name': 'الموقع الرسمي — Hekaya Mixat (تم التحقق 2026-11-23)',
        'url': 'https://www.etisalat.com.eg/portal/Mobile/hekaya-mixat',
        'type': 'official_site',
        'checked_at': '2026-11-23',
      },
    ],
  };

  Sync newSync() => Sync(
    files: {
      'packages': {
        'section': 'packages',
        'items': [
          item(52, 74.29, 1900),
          item(69, 98.58, 2800),
          item(92, 131.44, 3750),
          item(120, 171.44, 5375),
        ],
      },
      'internet': {'section': 'internet', 'items': <Object>[]},
    },
    map: {},
    today: '2026-12-01',
  );

  List<OfficialBundle> read(List<Map<String, dynamic>> bundles) =>
      parseOfficial(site(bundles), site(bundles));

  Map<String, dynamic> find(Sync s, String id) =>
      (s.files['packages']!['items'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((i) => i['id'] == id);

  test('the same prices change nothing', () {
    final s = newSync()..run(read(standard));
    expect(s.matched, 4);
    expect(s.hasChanges, isFalse);
    expect(s.touched, isEmpty);
    expect(s.held, isEmpty);
  });

  test('a new price replaces the old one; codes stay as they are', () {
    final s = newSync()
      ..run(
        read([
          bundle('Hekaya Mixat 52', '78.58', '1900', '*319*52#'),
          ...standard.skip(1),
        ]),
      );
    final it = find(s, 'pkg-hekaya-mixat-52');
    expect(it['price_total_egp'], 78.58);
    expect(it['price_egp'], 55); // the card ratio the item already follows
    expect(it['summary_ar'], contains('78.58'));
    expect(it['summary_ar'], contains('*319*52#'));
    expect(it['summary_ar'], isNot(contains('74.29')));
    final facts = (it['facts'] as List).cast<Map<String, dynamic>>();
    expect(facts.firstWhere((f) => f['kind'] == 'code')['value'], '*319*52#');
    expect((it['sources'] as List).single['checked_at'], '2026-12-01');
    expect(s.changed.map((c) => c['field']), containsAll(['total', 'price']));
  });

  test('a price that jumps too far is held for a person', () {
    final s = newSync()
      ..run(
        read([
          bundle('Hekaya Mixat 52', '300', '1900', '*319*52#'),
          ...standard.skip(1),
        ]),
      );
    expect(find(s, 'pkg-hekaya-mixat-52')['price_total_egp'], 74.29);
    expect(s.held, hasLength(1));
  });

  test('a new package is added, a gone one removed', () {
    final first = newSync()..run(read(standard));
    final s = Sync(files: first.files, map: first.map, today: '2026-12-02')
      ..run(
        read([
          ...standard.take(3),
          bundle('Hekaya Mixat 150', '214.29', '7000', '*319*150#'),
        ]),
      );
    expect(s.removed.single['id'], 'pkg-hekaya-mixat-120');
    expect(s.added.single['title'], 'Hekaya Mixat 150');
    final added = find(s, s.added.single['id'] as String);
    expect(added['price_total_egp'], 214.29);
    expect(added['price_egp'], 150);
    expect(added['codes'], ['*319*150#']);
    expect(added['status'], 'confirmed');
  });

  test('many packages vanishing at once are held, not removed', () {
    final first = newSync()..run(read(standard));
    final s = Sync(files: first.files, map: first.map, today: '2026-12-02')
      ..run(read(standard.take(1).toList()));
    expect(s.removed, isEmpty);
    expect(s.held, isNotEmpty);
    expect((s.files['packages']!['items'] as List), hasLength(4));
  });
}
