/// Reads e& Egypt's official bundle files (the JSON the website itself
/// renders its package pages from) into plain records.
///
/// Pure Dart: no Flutter, so it runs with `dart run` in CI.
library;

import 'dart:convert';

/// One package as the official site states it.
class OfficialBundle {
  OfficialBundle({
    required this.section,
    required this.tab,
    required this.tabEn,
    required this.index,
    required this.nameAr,
    required this.nameEn,
    required this.price,
    required this.priceText,
    required this.feesText,
    required this.quota,
    required this.quotaUnit,
    required this.code,
    required this.benefits,
    this.statedTotal,
  });

  /// Key of the site page (`hekaya-mixat`, `eHome-DSL`...).
  final String section;

  /// Tab on that page (Arabic), empty when the page has none.
  final String tab;

  /// The tab's English name (stable key for unnamed packages).
  final String tabEn;
  final int index;
  final String nameAr;
  final String nameEn;

  /// The stated price in EGP, `null` when none.
  final double? price;
  final String priceText;

  /// What the price covers (`Monthly Fees Including Recharge Tax`).
  final String feesText;

  /// Main quota number and its unit (`1900` `Mix`), `null` when none.
  final double? quota;
  final String quotaUnit;

  /// Subscription code (`*319*52#`), empty when none.
  final String code;

  /// (title, value) pairs in Arabic.
  final List<(String, String)> benefits;

  /// Price includes the recharge tax (prepaid card price).
  bool get priceIncludesTax => _taxIncluded.hasMatch(feesText);

  /// The price with tax, stated on its own (`357 EGP tax inclusive`).
  final double? statedTotal;

  /// What the customer pays, tax included, when the site says it.
  double? get totalPrice => statedTotal ?? (priceIncludesTax ? price : null);

  /// The price before tax, when the site says it.
  double? get basePrice => priceIncludesTax ? null : price;

  /// Stable identity on the site: its code when it has one of its own,
  /// else its English name.
  String key({required bool codeIsUnique}) => codeIsUnique && code.isNotEmpty
      ? '$section|code:$code'
      : nameEn.isNotEmpty
      ? '$section|name:${normalizeName(nameEn)}'
      // Unnamed packages (DSL, cards) by their tab and quota.
      : '$section|tab:${normalizeName(tabEn)}|q:$quota';

  /// Enough to recognise the package.
  bool get usable =>
      (nameEn.isNotEmpty || quota != null) && (price != null || quota != null);

  /// Enough to add it as a new package: a name or a quota, and a price.
  bool get addable => (nameEn.isNotEmpty || quota != null) && price != null;

  /// The same package with a price before tax the site implies.
  OfficialBundle withPrice(double value) => OfficialBundle(
    section: section,
    tab: tab,
    tabEn: tabEn,
    index: index,
    nameAr: nameAr,
    nameEn: nameEn,
    price: value,
    priceText: priceText,
    feesText: feesText,
    quota: quota,
    quotaUnit: quotaUnit,
    code: code,
    benefits: benefits,
    statedTotal: statedTotal,
  );

  Map<String, dynamic> toJson() => {
    'section': section,
    'tab': tab,
    'name_ar': nameAr,
    'name_en': nameEn,
    'price': price,
    'total': totalPrice,
    'fees': feesText,
    'quota': quota,
    'quota_unit': quotaUnit,
    'code': code,
  };
}

String normalizeName(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9.]+'), ' ').trim();

/// Plain text of a site string: no HTML tags, single spaces.
String plain(Object? v) => (v ?? '')
    .toString()
    .replaceAll(RegExp(r'<[^>]+>'), ' ')
    .replaceAll('&amp;', '&')
    .replaceAll('&nbsp;', ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// First number in [s] (Western or Arabic digits, `1,900` and `74.29`).
double? firstNumber(String s) {
  final t = _asciiDigits(s);
  final m = RegExp(r'\d[\d,]*(?:\.\d+)?').firstMatch(t);
  if (m == null) return null;
  return double.tryParse(m[0]!.replaceAll(',', ''));
}

String _asciiDigits(String s) => s.replaceAllMapped(
  RegExp('[٠-٩]'),
  (m) => '${m[0]!.codeUnitAt(0) - 0x0660}',
);

final _taxIncluded = RegExp(
  r'including\s+recharge\s+tax|tax\s+inclusive|شامل|بما في ذلك ضريبة',
  caseSensitive: false,
);
final _ussd = RegExp(r'^[*#][\d*#]*\d[\d*#]*#$');
final _money = RegExp(r'EGP|جني|جنيه|ج\.م', caseSensitive: false);

/// Every bundle of the two official files, Arabic and English paired by
/// position (both files describe the same bundles in the same order).
List<OfficialBundle> parseOfficial(String arJson, String enJson) {
  final ar = jsonDecode(arJson) as Map<String, dynamic>;
  final en = jsonDecode(enJson) as Map<String, dynamic>;
  final out = <OfficialBundle>[];
  for (final section in en.keys) {
    final arGroups = _groups(ar[section], '');
    final enGroups = _groups(en[section], '');
    for (var g = 0; g < enGroups.length; g++) {
      final (enTab, enBundles) = enGroups[g];
      final arPair = g < arGroups.length ? arGroups[g] : null;
      for (var i = 0; i < enBundles.length; i++) {
        final e = enBundles[i];
        final a = arPair != null && i < arPair.$2.length ? arPair.$2[i] : e;
        out.add(_bundle(section, arPair?.$1 ?? enTab, enTab, i, a, e));
      }
    }
  }
  return out;
}

/// (tab name, bundles) of a page, walking nested tabs.
List<(String, List<Map<String, dynamic>>)> _groups(Object? node, String tab) {
  final out = <(String, List<Map<String, dynamic>>)>[];
  if (node is Map<String, dynamic>) {
    final name = plain(node['name']);
    final here = name.isEmpty ? tab : name;
    final bundles = node['bundles'];
    if (bundles is List) {
      out.add((
        here,
        [
          for (final b in bundles)
            if (b is Map<String, dynamic>) b,
        ],
      ));
    }
    for (final k in const ['tabs', 'mainTabs']) {
      final tabs = node[k];
      if (tabs is List) {
        for (final t in tabs) {
          out.addAll(_groups(t, here));
        }
      }
    }
  }
  return out;
}

OfficialBundle _bundle(
  String section,
  String tab,
  String tabEn,
  int index,
  Map<String, dynamic> a,
  Map<String, dynamic> e,
) {
  Map<String, dynamic> m(Object? v) =>
      v is Map<String, dynamic> ? v : const <String, dynamic>{};
  final ta = m(a['title']), te = m(e['title']);
  final de = m(e['bundleDesc']);

  var priceText = plain(te['bundlePrice']);
  var price = firstNumber(priceText);
  final unit = plain(te['unit']);
  // Main quota: `value` + `unit` (or `desc1`); cards put it in the title
  // (`bundleName_unit` + `bundleUnit`).
  var quotaText = plain(de['value']);
  var quotaUnit = plain(de['unit'] ?? de['desc1']);
  if (quotaText.isEmpty && te['bundleName_unit'] != null) {
    quotaText = plain(te['bundleName_unit']);
    quotaUnit = plain(te['bundleUnit']);
  }
  // Some pages state the price in the description (`0.5 EGP`), or as the
  // second value (`150 EGP` under `100 GBs`).
  final second = plain(de['value2']);
  final secondUnit = plain(de['unit2'] ?? de['desc2']);
  if (price == null &&
      (_money.hasMatch(quotaText) || _money.hasMatch(quotaUnit))) {
    priceText = '$quotaText $quotaUnit'.trim();
    price = firstNumber(quotaText);
    quotaText = '';
    quotaUnit = '';
  } else if (price == null && _money.hasMatch(secondUnit)) {
    priceText = '$second $secondUnit'.trim();
    price = firstNumber(second);
  }
  // `fair: 357 EGP tax inclusive` under a price before tax.
  final fair = plain(de['fair']);
  final statedTotal = _taxIncluded.hasMatch(fair) ? firstNumber(fair) : null;
  quotaUnit = switch (quotaUnit.toLowerCase()) {
    'megabytes' || 'megabyte' || 'mbs' => 'MB',
    _ => quotaUnit,
  };
  if (priceText.isNotEmpty && unit.isNotEmpty) priceText = '$priceText $unit';

  String code = '';
  final benefits = <(String, String)>[];
  for (final (i, b) in ((e['benefitList'] as List?) ?? const []).indexed) {
    if (b is! Map) continue;
    final title = plain(b['benefitTitle']);
    final value = plain(b['benefitValue']);
    final arList = (a['benefitList'] as List?) ?? const [];
    final arB = i < arList.length && arList[i] is Map ? arList[i] as Map : b;
    benefits.add((plain(arB['benefitTitle']), plain(arB['benefitValue'])));
    if (code.isEmpty &&
        (RegExp('code', caseSensitive: false).hasMatch(title) ||
            _ussd.hasMatch(value))) {
      code = value.replaceAll(' ', '');
    }
  }

  return OfficialBundle(
    section: section,
    tab: tab,
    tabEn: tabEn,
    index: index,
    nameAr: plain(ta['bundleName']),
    nameEn: plain(te['bundleName']),
    price: price,
    priceText: priceText,
    feesText: plain(te['fees']),
    quota: firstNumber(quotaText),
    quotaUnit: quotaUnit,
    code: _ussd.hasMatch(code) ? code : '',
    benefits: benefits,
    statedTotal: statedTotal,
  );
}
