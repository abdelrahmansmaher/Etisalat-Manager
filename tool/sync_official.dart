// Syncs the app's content with e& Egypt's official bundle files.
//
//   dart run tool/sync_official.dart [--ar FILE --en FILE] [--today YYYY-MM-DD]
//                                    [--dry-run] [--report FILE]
//
// * A changed price or quota is updated (the old value is replaced, never
//   kept), and the item stays "confirmed from the official site".
// * A new package on a page the app already covers is added.
// * A package that disappears from the site is removed.
// * Anything that looks wrong is HELD, not applied: a price that moves by
//   more than 60 %, a changed subscription code, or many packages vanishing
//   at once. Held changes are listed in the report for a person to check.
//
// Matches between site packages and app items are kept in
// tool/sync/official_map.json so that later runs compare like with like.

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import 'sync/official.dart';

const _base = 'https://www.etisalat.com.eg/portal/assets/json/bundles';
const _contentDir = 'assets/content';
const _mapFile = 'tool/sync/official_map.json';
const _contentFiles = [
  'packages',
  'internet',
  'procedures',
  'numbers',
  'wallet',
  'glossary',
  'company',
];

/// Files whose items can be matched to site packages.
const _syncedFiles = ['packages', 'internet'];

Future<void> main(List<String> args) async {
  String? opt(String name) {
    final i = args.indexOf(name);
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  // After editing content by hand: refresh the checksums the app checks.
  if (args.contains('--manifest-only')) {
    writeManifest(changed: false);
    return;
  }
  final dryRun = args.contains('--dry-run');
  final today =
      opt('--today') ??
      DateTime.now().toUtc().toIso8601String().substring(0, 10);
  final arJson = opt('--ar') != null
      ? File(opt('--ar')!).readAsStringSync()
      : await _download('$_base/bundles_ar.json');
  final enJson = opt('--en') != null
      ? File(opt('--en')!).readAsStringSync()
      : await _download('$_base/bundles_en.json');

  final List<OfficialBundle> official;
  try {
    official = parseOfficial(arJson, enJson);
  } catch (e) {
    stderr.writeln('The official files could not be read: $e');
    exit(1);
  }
  final usable = official.where((b) => b.usable).toList();
  if (usable.length < 20) {
    // The site changed its format: never act on a half-read file.
    stderr.writeln('Only ${usable.length} packages could be read; stopping.');
    exit(1);
  }

  final sync = Sync(
    files: {
      for (final f in _contentFiles)
        f: jsonDecode(
          File('$_contentDir/$f.json').readAsStringSync(),
        ) as Map<String, dynamic>,
    },
    map: File(_mapFile).existsSync()
        ? (jsonDecode(File(_mapFile).readAsStringSync()) as Map)
              .cast<String, String>()
        : <String, String>{},
    today: today,
  )..run(usable);

  final report = sync.report;
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(report));
  final reportPath = opt('--report');
  if (reportPath != null) {
    File(reportPath)
        .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));
  }
  if (dryRun) return;

  if (sync.touched.isNotEmpty) {
    for (final f in sync.touched) {
      final file = sync.files[f]!;
      file['as_of'] = today;
      _writeJson('$_contentDir/$f.json', file);
    }
  }
  _writeJson(
    _mapFile,
    Map.fromEntries(
      sync.map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    ),
  );
  writeManifest(changed: sync.touched.isNotEmpty);
}

Future<String> _download(String url) async {
  final client = HttpClient()..userAgent = 'N-Core content sync';
  try {
    final req = await client.getUrl(Uri.parse(url));
    final res = await req.close().timeout(const Duration(seconds: 60));
    if (res.statusCode != 200) {
      throw HttpException('HTTP ${res.statusCode}', uri: Uri.parse(url));
    }
    return await res.transform(utf8.decoder).join();
  } finally {
    client.close();
  }
}

void _writeJson(String path, Object json) {
  File(
    path,
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(json)}\n');
}

/// `assets/content/manifest.json`: the content version the app compares
/// with its own, and a checksum per file so a broken download is refused.
void writeManifest({required bool changed}) {
  final path = '$_contentDir/manifest.json';
  final old = File(path).existsSync()
      ? jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>
      : <String, dynamic>{};
  final files = <String, String>{
    for (final f in _contentFiles)
      '$f.json': sha256
          .convert(
            utf8.encode(
              File('$_contentDir/$f.json')
                  .readAsStringSync()
                  .replaceAll('\r\n', '\n'),
            ),
          )
          .toString(),
  };
  final same =
      !changed &&
      old['files'] is Map &&
      const DeepEquality().equals(old['files'] as Map, files);
  final now = DateTime.now().toUtc();
  final version = same
      ? old['version']
      : int.parse(
          '${now.year}${_two(now.month)}${_two(now.day)}${_two(now.hour)}${_two(now.minute)}',
        );
  _writeJson(path, {
    'version': version,
    'checked_at': now.toIso8601String().substring(0, 10),
    'files': files,
  });
}

/// Same rule as `PostpaidTax` in the app.
double postpaidTotal(double fee) =>
    ((fee * 1.08 * 1.14 + 10 + 1.34) * 100).roundToDouble() / 100;

String _two(int n) => n.toString().padLeft(2, '0');

class DeepEquality {
  const DeepEquality();
  bool equals(Map a, Map b) =>
      a.length == b.length && a.keys.every((k) => '${a[k]}' == '${b[k]}');
}

/// The matching and the changes, kept apart from file I/O for tests.
class Sync {
  Sync({required this.files, required this.map, required this.today});

  final Map<String, Map<String, dynamic>> files;
  final Map<String, String> map;
  final String today;

  final touched = <String>{};
  final changed = <Map<String, dynamic>>[];
  final added = <Map<String, dynamic>>[];
  final removed = <Map<String, dynamic>>[];
  final held = <Map<String, dynamic>>[];
  final notCovered = <Map<String, dynamic>>[];
  int matched = 0;

  Map<String, dynamic> get report => {
    'date': today,
    'matched': matched,
    'changed': changed,
    'added': added,
    'removed': removed,
    'held': held,
    'not_covered_count': notCovered.length,
  };

  bool get hasChanges =>
      changed.isNotEmpty || added.isNotEmpty || removed.isNotEmpty;

  // ---- Lookups ------------------------------------------------------------

  Iterable<(String, Map<String, dynamic>)> get _items sync* {
    for (final f in _syncedFiles) {
      for (final it in (files[f]!['items'] as List)) {
        yield (f, it as Map<String, dynamic>);
      }
    }
  }

  (String, Map<String, dynamic>)? _byId(String id) {
    for (final e in _items) {
      if (e.$2['id'] == id) return e;
    }
    return null;
  }

  /// Site page an item comes from (`hekaya-mixat`), from its official link.
  static String? pageOf(Map<String, dynamic> item) {
    for (final s in (item['sources'] as List? ?? const [])) {
      final url = (s as Map)['url'] as String? ?? '';
      final m = RegExp(r'/portal/[^?#]*?/([^/?#]+)/?$').firstMatch(url);
      if (m != null && (s['type'] == 'official_site')) return m[1];
    }
    return null;
  }

  /// `hekaya-mixat2` and `eHome-DSL2` are second halves of the same page.
  static String pageKey(String section) =>
      section.replaceFirst(RegExp(r'\d+$'), '');

  // ---- Run ----------------------------------------------------------------

  void run(List<OfficialBundle> bundles) {
    final codeCount = <String, int>{};
    final nameCount = <String, int>{};
    for (final b in bundles) {
      if (b.code.isNotEmpty) {
        codeCount.update(
          '${b.section}|${b.code}',
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      nameCount.update(
        '${b.section}|${normalizeName(b.nameEn)}',
        (n) => n + 1,
        ifAbsent: () => 1,
      );
    }
    String keyOf(OfficialBundle b) {
      final k = b.key(codeIsUnique: codeCount['${b.section}|${b.code}'] == 1);
      // Two packages with one name (`Mini Hekaya Internet 32` for 2 and for
      // 3 weeks) are told apart by their quota.
      return k.contains('|name:') &&
              (nameCount['${b.section}|${normalizeName(b.nameEn)}'] ?? 0) > 1
          ? '$k|q:${b.quota}'
          : k;
    }

    final covered = {
      for (final (_, it) in _items)
        if (pageOf(it) case final p?) pageKey(p),
    };
    final seenKeys = <String>{};
    final usedIds = {...map.values};

    for (final b in bundles) {
      final key = keyOf(b);
      if (!seenKeys.add(key)) continue; // listed twice on the site
      var id = map[key];
      if (id != null && _byId(id) == null) id = null; // removed by hand
      id ??= _match(b, usedIds);
      if (id != null) {
        map[key] = id;
        usedIds.add(id);
        matched++;
        _update(b, _byId(id)!);
      } else if (covered.contains(pageKey(b.section))) {
        final priced = b.price == null ? _priceFromName(b) : b;
        if (priced != null && priced.addable) {
          _add(priced, key);
        } else {
          held.add({
            'page': b.section,
            'name': b.nameAr.isNotEmpty ? b.nameAr : b.nameEn,
            'reason': 'باقة جديدة على الموقع من غير سعر واضح',
          });
        }
      } else {
        notCovered.add(b.toJson());
      }
    }
    _removeGone(seenKeys, bundles);
  }

  /// The app item a site package is, by (1) the same English name
  /// anywhere (a package can be listed on two pages), (2) a name that
  /// contains it on the same page, (3) the same price and quota on the same
  /// page, (4) its own subscription code on the same page.
  String? _match(OfficialBundle b, Set<String> used) {
    final page = pageKey(b.section);
    final name = normalizeName(b.nameEn);
    String? only(Iterable<Map<String, dynamic>> list) {
      final l = list.toList();
      return l.length == 1 ? l.single['id'] as String : null;
    }

    final all = [for (final (_, it) in _items) it];
    if (name.isNotEmpty) {
      final exact = only(
        all.where((it) => normalizeName('${it['title_en'] ?? ''}') == name),
      );
      if (exact != null) return exact;
    }
    final samePage = [
      for (final it in all)
        if (!used.contains(it['id']) &&
            pageOf(it) != null &&
            pageKey(pageOf(it)!) == page)
          it,
    ];
    if (name.isNotEmpty) {
      final contains = only(
        samePage.where((it) {
          final t = normalizeName('${it['title_en'] ?? ''}');
          return t.isNotEmpty &&
              (t.endsWith(' $name') || t.contains(' $name '));
        }),
      );
      if (contains != null) return contains;
    }
    final price = b.price;
    if (price != null) {
      bool samePrice(Map<String, dynamic> it) {
        bool eq(double? a, double? b) =>
            a != null && b != null && (a - b).abs() < 0.005;
        final own = _num(it['price_egp']), total = _num(it['price_total_egp']);
        final t = b.totalPrice;
        // With a stated total, the totals must agree too (two packages can
        // share a price before tax).
        if (t != null && total != null && !eq(t, total)) return false;
        return eq(own, price) || eq(total, price) || eq(total, t);
      }

      bool sameQuota(Map<String, dynamic> it) =>
          b.quota == null ||
          (it['facts'] as List? ?? const []).any((f) {
            final fact = f as Map;
            if (!'${fact['label_ar']}'.contains('الحصة')) return false;
            final n = firstNumber('${fact['value']}');
            return n != null && (n - b.quota!).abs() < 0.005;
          });
      final byValues = only(
        samePage.where((it) => samePrice(it) && sameQuota(it)),
      );
      if (byValues != null) return byValues;
    } else if (b.quota != null) {
      // No price on the site (cards): the same quota on the same page.
      final byQuota = only(
        samePage.where((it) {
          return (it['facts'] as List? ?? const []).any((f) {
            final fact = f as Map;
            if (!'${fact['label_ar']}'.contains('الحصة')) return false;
            final n = firstNumber('${fact['value']}');
            return n != null && (n - b.quota!).abs() < 0.005;
          });
        }),
      );
      if (byQuota != null) return byQuota;
    }
    if (b.code.isEmpty) return null;
    return only(
      samePage.where(
        (it) => (it['codes'] as List? ?? const []).contains(b.code),
      ),
    );
  }

  /// Pages like Hekaya Internet name each package by its price (`Hekaya
  /// Internet 46` costs 46) and state no price. The price is taken from the
  /// name only when every package of that page in the app follows the rule.
  OfficialBundle? _priceFromName(OfficialBundle b) {
    final m = RegExp(r'(\d+(?:\.\d+)?)\s*$').firstMatch(b.nameEn);
    if (m == null) return null;
    final page = pageKey(b.section);
    final named = [
      for (final (_, it) in _items)
        if (pageOf(it) case final p? when pageKey(p) == page)
          if (RegExp(r'(\d+(?:\.\d+)?)\s*$')
                  .firstMatch('${it['title_en'] ?? ''}')
              case final n?)
            (double.parse(n[1]!), _num(it['price_egp'])),
    ];
    final follows =
        named.length >= 3 &&
        named.every((e) => e.$2 != null && (e.$1 - e.$2!).abs() < 0.005);
    return follows ? b.withPrice(double.parse(m[1]!)) : null;
  }

  // ---- Changes ------------------------------------------------------------

  void _update(OfficialBundle b, (String, Map<String, dynamic>) entry) {
    final (file, it) = entry;
    final edits = <(String, String, String)>[]; // field, before, after
    if (it['status'] != 'conflict') {
      final total = _num(it['price_total_egp']);
      final own = _num(it['price_egp']);
      final newTotal = b.totalPrice;
      final newOwn = b.basePrice;
      var ownDone = false;
      if (newTotal != null &&
          total != null &&
          (total - newTotal).abs() > 0.005) {
        if (_jump(total, newTotal)) {
          _hold(it, 'السعر شامل الضريبة', total, newTotal);
        } else {
          it['price_total_egp'] = _clean(newTotal);
          _replaceFact(it, (l) => _isTotalLabel(l), total, newTotal);
          edits.add(('total', _fmt(total), _fmt(newTotal)));
          // The balance price follows the official card ratio (x 0.7)
          // when this item already follows it and the site gives no
          // price before tax of its own.
          if (newOwn == null &&
              own != null &&
              (own - total * 0.7).abs() < 0.02) {
            final derived = _round(newTotal * 0.7);
            it['price_egp'] = _clean(derived);
            _replaceFact(it, (l) => !_isTotalLabel(l), own, derived);
            edits.add(('price', _fmt(own), _fmt(derived)));
            ownDone = true;
          }
        }
      }
      if (!ownDone &&
          newOwn != null &&
          own != null &&
          (own - newOwn).abs() > 0.005) {
        if (_jump(own, newOwn)) {
          _hold(it, 'السعر', own, newOwn);
        } else {
          it['price_egp'] = _clean(newOwn);
          _replaceFact(it, (l) => !_isTotalLabel(l), own, newOwn);
          edits.add(('price', _fmt(own), _fmt(newOwn)));
        }
      }
    }

    final quota = b.quota;
    final field = switch (b.quotaUnit.toLowerCase()) {
      'mix' => 'quota_mix',
      'gb' || 'gbs' => 'quota_gb',
      _ => null,
    };
    if (quota != null && field != null && _num(it[field]) != null) {
      final old = _num(it[field])!;
      if ((old - quota).abs() > 0.005) {
        if (_jump(old, quota)) {
          _hold(it, 'الحصة', old, quota);
        } else {
          it[field] = _clean(quota);
          _replaceQuotaFact(it, old, quota);
          edits.add(('quota', _fmt(old), _fmt(quota)));
        }
      }
    }

    if (b.code.isNotEmpty) {
      final codes = (it['codes'] as List? ?? const []).cast<String>();
      if (codes.isNotEmpty && !codes.contains(b.code)) {
        held.add({
          'id': it['id'],
          'title': it['title_ar'],
          'reason': 'كود الاشتراك على الموقع اتغير',
          'before': codes.join(' '),
          'after': b.code,
        });
      }
    }

    if (edits.isEmpty) return;
    // A postpaid fee changed: its total with taxes and fees follows
    // (fee x 1.08 x 1.14 + 10 development fee + 1.34 stamp duty).
    final fee = _num(it['price_egp']);
    for (final f in (it['facts'] as List? ?? const [])) {
      final fact = f as Map<String, dynamic>;
      if (fact['label_ar'] != 'السعر شامل الضرائب والرسوم' || fee == null) {
        continue;
      }
      final before = firstNumber('${fact['value']}');
      final after = postpaidTotal(fee);
      if (before == null || (before - after).abs() < 0.005) continue;
      fact['value'] = _fmt(after);
      edits.add(('total', _fmt(before), _fmt(after)));
    }
    for (final (_, before, after) in edits) {
      it['summary_ar'] = _swapNumber(
        '${it['summary_ar'] ?? ''}',
        before,
        after,
      );
    }
    it['status'] = 'confirmed';
    it['status_note_ar'] = 'مؤكد من الموقع الرسمي (${_arDate(today)}).';
    _stampSource(it);
    touched.add(file);
    for (final (field, before, after) in edits) {
      changed.add({
        'id': it['id'],
        'title': it['title_ar'],
        'field': field,
        'before': before,
        'after': after,
      });
    }
  }

  void _add(OfficialBundle b, String key) {
    final page = pageKey(b.section);
    final siblings = [
      for (final e in _items)
        if (pageOf(e.$2) case final p? when pageKey(p) == page) e,
    ];
    final file = _mostCommon(siblings.map((e) => e.$1)) ?? 'packages';
    final sib = siblings.map((e) => e.$2).toList();
    final family = _mostCommon(sib.map((i) => '${i['family'] ?? ''}'));
    final category = _mostCommon(sib.map((i) => '${i['category_ar'] ?? ''}'));
    final url = sib
        .expand((i) => (i['sources'] as List? ?? const []))
        .map((s) => (s as Map)['url'] as String?)
        .firstWhere(
          (u) => u != null && u.contains('/portal/'),
          orElse: () => 'https://www.etisalat.com.eg/portal/',
        )!;
    // Do the siblings show the balance price as card x 0.7?
    final ratio = sib.any((i) {
      final t = _num(i['price_total_egp']), p = _num(i['price_egp']);
      return t != null && p != null && (p - t * 0.7).abs() < 0.02;
    });

    final id =
        'auto-${b.section.toLowerCase()}-'
        '${_slug(b.nameEn.isNotEmpty ? b.nameEn : '${b.tabEn} ${_fmt(b.quota!)}')}';
    if (_byId(id) != null) return;
    final unitAr0 = switch (b.quotaUnit.toLowerCase()) {
      'mix' => 'ميكس',
      'gb' || 'gbs' => 'جيجا',
      'mb' => 'ميجا',
      _ => b.quotaUnit,
    };
    final title = b.nameAr.isNotEmpty
        ? b.nameAr
        : b.nameEn.isNotEmpty
        ? b.nameEn
        : '${sib.isNotEmpty ? sib.first['category_ar'] : b.section} '
              '${_fmt(b.quota!)} $unitAr0'
              '${b.tab.isNotEmpty ? ' (${b.tab})' : ''}';
    final facts = <Map<String, dynamic>>[];
    final price = b.price;
    double? own = b.basePrice, total = b.totalPrice;
    if (own == null && total != null && ratio) own = _round(total * 0.7);
    if (own != null) {
      facts.add(
        _fact(
          total != null && b.basePrice == null
              ? 'السعر (الخصم من الرصيد)'
              : (total != null ? 'السعر (قبل الضريبة)' : 'السعر'),
          _fmt(own),
          'price',
          'ج',
        ),
      );
    }
    if (total != null) {
      facts.add(
        _fact(
          b.basePrice == null
              ? 'السعر المطلوب شحنه / شامل الضريبة'
              : 'السعر شامل الضريبة',
          _fmt(total),
          'price',
          'ج',
        ),
      );
    }
    final unitAr = switch (b.quotaUnit.toLowerCase()) {
      'mix' => 'ميكس',
      'gb' || 'gbs' => 'جيجا',
      'mb' => 'ميجا',
      'min' => 'دقيقة',
      'unit' => 'وحدة',
      _ => b.quotaUnit,
    };
    if (b.quota != null) {
      facts.add(_fact('الحصة ($unitAr)', _fmt(b.quota!), 'quantity'));
    }
    for (final (t, v) in b.benefits) {
      if (t.isEmpty || v.isEmpty || v == '-') continue;
      final isCode = v.replaceAll(' ', '') == b.code && b.code.isNotEmpty;
      facts.add(
        _fact(
          isCode ? 'كود الاشتراك' : t,
          isCode ? b.code : v,
          isCode ? 'code' : 'text',
        ),
      );
    }
    final item = <String, dynamic>{
      'id': id,
      'type': 'package',
      'category_ar': (category?.isNotEmpty ?? false) ? category : b.tab,
      if (family != null && family.isNotEmpty) 'family': family,
      'title_ar': title,
      'title_en': b.nameEn,
      'summary_ar': [
        if (b.quota != null) '${_fmt(b.quota!)} $unitAr',
        if (price != null)
          b.priceIncludesTax
              ? 'بـ ${_fmt(price)} ج شامل الضريبة'
              : 'بـ ${_fmt(price)} ج',
        if (b.code.isNotEmpty) '— اشترك ${b.code}',
      ].join(' '),
      'facts': facts,
      if (own != null) 'price_egp': _clean(own),
      if (total != null) 'price_total_egp': _clean(total),
      if (b.quotaUnit.toLowerCase() == 'mix' && b.quota != null)
        'quota_mix': _clean(b.quota!),
      if ((b.quotaUnit.toLowerCase() == 'gb' ||
              b.quotaUnit.toLowerCase() == 'gbs') &&
          b.quota != null)
        'quota_gb': _clean(b.quota!),
      'codes': [if (b.code.isNotEmpty) b.code],
      'phones': <String>[],
      'tags': {
        ...title.split(' '),
        ...b.nameEn.split(' '),
        'جديد',
      }.where((t) => t.trim().isNotEmpty).toList(),
      'status': 'confirmed',
      'status_note_ar': 'مؤكد من الموقع الرسمي (${_arDate(today)}).',
      'sources': [
        {
          'name': 'الموقع الرسمي — ${b.nameEn} (تم التحقق $today)',
          'url': url,
          'type': 'official_site',
          'checked_at': today,
        },
      ],
    };
    (files[file]!['items'] as List).add(item);
    map[key] = id;
    touched.add(file);
    added.add({'id': id, 'title': title, 'price': price, 'code': b.code});
  }

  void _removeGone(Set<String> seen, List<OfficialBundle> bundles) {
    final pages = {for (final b in bundles) pageKey(b.section)};
    final gone = <String, List<String>>{}; // page -> keys
    final perPage = <String, int>{};
    for (final key in map.keys) {
      final page = pageKey(key.split('|').first);
      perPage.update(page, (n) => n + 1, ifAbsent: () => 1);
      // Only pages the site still lists: a page that vanished entirely is
      // more likely a format change than every package withdrawn.
      if (!seen.contains(key) && pages.contains(page)) {
        (gone[page] ??= []).add(key);
      }
    }
    for (final MapEntry(key: page, value: keys) in gone.entries) {
      final limit = (perPage[page]! * 0.3).ceil().clamp(1, 4);
      if (keys.length > limit) {
        held.add({
          'page': page,
          'reason': 'باقات كتير اختفت من صفحة واحدة مرة واحدة',
          'count': keys.length,
        });
        continue;
      }
      for (final key in keys) {
        final id = map.remove(key)!;
        final entry = _byId(id);
        if (entry == null) continue;
        final (file, it) = entry;
        (files[file]!['items'] as List).remove(it);
        for (final (_, other) in _items) {
          (other['related'] as List?)?.remove(id);
        }
        touched.add(file);
        removed.add({'id': id, 'title': it['title_ar']});
      }
    }
  }

  // ---- Helpers ------------------------------------------------------------

  void _hold(
    Map<String, dynamic> it,
    String what,
    double before,
    double after,
  ) => held.add({
    'id': it['id'],
    'title': it['title_ar'],
    'reason': '$what اتغير بنسبة كبيرة',
    'before': _fmt(before),
    'after': _fmt(after),
  });

  static bool _jump(double before, double after) =>
      before > 0 && ((after - before).abs() / before) > 0.6;

  static bool _isTotalLabel(String l) =>
      l.contains('شامل') || l.contains('المطلوب شحنه') || l.contains('الكارت');

  void _replaceFact(
    Map<String, dynamic> it,
    bool Function(String label) which,
    double before,
    double after,
  ) {
    for (final f in (it['facts'] as List? ?? const [])) {
      final fact = f as Map<String, dynamic>;
      if (fact['kind'] != 'price' || !which('${fact['label_ar']}')) continue;
      final v = '${fact['value']}';
      if (firstNumber(v) case final n? when (n - before).abs() < 0.005) {
        fact['value'] = _swapNumber(v, _fmt(before), _fmt(after));
        return;
      }
    }
  }

  void _replaceQuotaFact(Map<String, dynamic> it, double before, double after) {
    for (final f in (it['facts'] as List? ?? const [])) {
      final fact = f as Map<String, dynamic>;
      if (!'${fact['label_ar']}'.contains('الحصة')) continue;
      final v = '${fact['value']}';
      if (firstNumber(v) case final n? when (n - before).abs() < 0.005) {
        fact['value'] = _swapNumber(v, _fmt(before), _fmt(after));
        return;
      }
    }
  }

  void _stampSource(Map<String, dynamic> it) {
    for (final s in (it['sources'] as List? ?? const [])) {
      final src = s as Map<String, dynamic>;
      if (src['type'] == 'official_site') {
        src['checked_at'] = today;
        src['name'] = '${src['name']}'.replaceFirst(
          RegExp(r'\(تم التحقق [^)]*\)'),
          '(تم التحقق $today)',
        );
      }
    }
  }

  static Map<String, dynamic> _fact(
    String l,
    String v,
    String kind, [
    String? unit,
  ]) => {'label_ar': l, 'value': v, 'kind': kind, 'unit': ?unit};

  static double? _num(Object? v) => v is num ? v.toDouble() : null;

  static num _clean(double v) =>
      v == v.roundToDouble() ? v.round() : double.parse(v.toStringAsFixed(2));

  static double _round(double v) {
    final r = double.parse(v.toStringAsFixed(2));
    return (r - r.round()).abs() < 0.011 ? r.roundToDouble() : r;
  }

  /// `1,900`, `74.29`, `52`.
  static String _fmt(double v) {
    final c = _clean(v);
    if (c is int) {
      return c.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
    }
    return c.toString();
  }

  /// Replaces [before] with [after] as a whole number (not inside another).
  static String _swapNumber(String text, String before, String after) {
    final plainBefore = before.replaceAll(',', '');
    for (final form in {before, plainBefore}) {
      // Not inside another number or a code (`*319*52#`).
      final re = RegExp(
        '(?<![\\d.,*#])${RegExp.escape(form)}(?![\\d*#]|[.,]\\d)',
      );
      if (re.hasMatch(text)) return text.replaceAll(re, after);
    }
    return text;
  }

  static String? _mostCommon(Iterable<String> values) {
    final count = <String, int>{};
    for (final v in values) {
      if (v.isEmpty) continue;
      count.update(v, (n) => n + 1, ifAbsent: () => 1);
    }
    if (count.isEmpty) return null;
    return (count.entries.toList()..sort((a, b) => b.value - a.value))
        .first
        .key;
  }

  static String _slug(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9.]+'), '-')
      .replaceAll('.', '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  static const _months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  static String _arDate(String iso) {
    final d = DateTime.parse(iso);
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }
}
