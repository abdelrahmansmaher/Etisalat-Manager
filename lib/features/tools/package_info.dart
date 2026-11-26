import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/content.dart';
import '../content/package_facts.dart';
import '../content/package_family.dart';
import 'dial_template.dart';

/// Where a package is used, for the recommender.
enum PackageUse { mobile, home, other }

/// Numbers of one package for compare / recommend / calculator.
///
/// The item's structured values (`priceEgp`, `quotaGb`…) come first; a fact is
/// used only when it states the same thing as one plain number. Anything not
/// stated stays `null` and is shown as "not stated": nothing is guessed and
/// mixes are never turned into GB or minutes.
@immutable
class PackageInfo {
  const PackageInfo._({
    required this.item,
    required this.facts,
    required this.family,
    required this.use,
    this.price,
    this.total,
    this.gb,
    this.minutes,
    this.mix,
    this.validityDays,
    this.mixNote,
    this.units,
  });

  factory PackageInfo.of(ContentItem item) {
    final facts = PackageFacts.of(item);

    // Two different prices for the same thing: the price is not settled.
    final settled = item.status != ItemStatus.conflict;

    double? price, total, gb, minutes, mix, days, units;
    if (settled) {
      price = item.priceEgp?.toDouble() ?? _plain(facts.price?.value);
      total =
          item.priceTotalEgp?.toDouble() ?? _plain(facts.rechargePrice?.value);
      gb = item.quotaGb?.toDouble();
      minutes = item.quotaMinutes?.toDouble();
      mix = item.quotaMix?.toDouble();
      days = item.validityDays?.toDouble();
      for (final q in facts.quotas) {
        gb ??= _factGb(q);
        minutes ??= _factMinutes(q);
        mix ??= _factMix(q);
        units ??= _factCallUnits(q);
      }
      days ??= _factDays(facts.validity);
      // The stated minutes are on-net / family / international only
      // (`الحصة (دقائق e&)`): not minutes to any network.
      final m = minutes;
      if (m != null &&
          facts.quotas.any(
            (q) =>
                _plain(q.value) == m &&
                (_has(_norm(q.label), _notGeneral) ||
                    _has(_norm(q.label), const [
                      'e&',
                      'اتصالات',
                      'عائل',
                      'دولي',
                    ])),
          )) {
        minutes = null;
      }
    }

    return PackageInfo._(
      item: item,
      facts: facts,
      family: familyOf(item),
      use: _useOf(item),
      price: price,
      total: total,
      gb: gb,
      minutes: minutes,
      mix: mix,
      validityDays: days,
      units: units,
      mixNote: item.facts
          .where(
            (f) =>
                f.kind != FactKind.code &&
                _norm(f.label).contains('استهلاك') &&
                f.value.contains('='),
          )
          .firstOrNull
          ?.value,
    );
  }

  final ContentItem item;
  final PackageFacts facts;
  final String family;
  final PackageUse use;
  final double? price;
  final double? total;
  final double? gb;
  final double? minutes;
  final double? mix;
  final double? validityDays;

  /// How mixes/units are used up, in the content's own words.
  final String? mixNote;

  /// Call/SMS units of a package that counts in units, not minutes.
  final double? units;

  /// Mixes or call units that pay for minutes.
  double? get callUnits => mix ?? units;

  /// Units one minute to an e& number uses, as [mixNote] states it.
  double? get unitsPerMinuteEand => _rate(_eandRate);

  /// Units one minute to another network uses, as [mixNote] states it.
  double? get unitsPerMinuteOther => _rate(_otherRate);

  double? _rate(RegExp r) {
    final note = mixNote;
    if (note == null) return null;
    final m = r.firstMatch(toAsciiDigits(note));
    return m == null ? null : double.parse(m[1]!);
  }

  static final RegExp _eandRate = RegExp(r'e&\s*=\s*(\d+(?:\.\d+)?)');
  static final RegExp _otherRate = RegExp(
    r'شبك[ةه]\s*(?:أخرى|اخرى|تانية|تانيه)\s*=\s*(\d+(?:\.\d+)?)',
  );

  /// The stated price excludes taxes.
  bool get priceBeforeTax {
    final f = facts.price;
    return f != null && _norm(f.label).contains('قبل');
  }

  /// The stated price is taken from the balance (the customer recharges
  /// more than that, because of the recharge tax).
  bool get priceIsDeducted {
    final f = facts.price;
    if (f == null) return false;
    final l = _norm(f.label);
    return l.contains('خصم') || l.contains('من الرصيد');
  }

  /// A monthly bill (فاتورة): Emerald, Primo...
  bool get postpaid =>
      item.summary.contains('فاتورة') ||
      item.category.contains('فاتورة') ||
      item.facts.any((f) => f.label.contains('شامل الضرائب والرسوم'));

  /// Confirmed and not edited by the owner.
  bool get confirmed => item.status == ItemStatus.confirmed && !item.userEdited;

  String? get priceText => facts.price?.display ?? _egp(price);
  String? get totalText => facts.rechargePrice?.display ?? _egp(total);

  /// Internet quota as the content states it; the rounded number only when
  /// there is no stated text.
  String? get gbText =>
      gb == null ? null : facts.internetText ?? '${formatNumber(gb!)} جيجا';

  String? get validityText => _text(facts.validity);
  String? get afterText => _text(facts.afterBundle);
  String? get codeText => facts.code?.value ?? item.codes.firstOrNull;
  String? get quotaText {
    final parts = [
      for (final q in facts.quotas)
        if (!q.isBlank) '${_quotaLabel(q.label)}${q.display}',
    ];
    return parts.isEmpty ? null : parts.join('\n');
  }

  static String? _egp(double? v) => v == null ? null : '${formatNumber(v)} ج';

  static String? _text(Fact? f) => f == null || f.isBlank ? null : f.display;

  /// `الحصة (إنترنت)` becomes `إنترنت: `.
  static String _quotaLabel(String label) {
    final m = RegExp(r'\(([^)]+)\)').firstMatch(label);
    final l = (m?[1] ?? label).trim();
    return l.isEmpty ? '' : '$l: ';
  }

  static String _norm(String s) => PackageFacts.normalizeLabel(s);

  /// A value that is exactly one number (`1,250`), else `null`.
  static double? _plain(String? v) {
    if (v == null) return null;
    final s = toAsciiDigits(v).trim().replaceAll(',', '');
    return RegExp(r'^\d+(\.\d+)?$').hasMatch(s) ? double.parse(s) : null;
  }

  static bool _has(String s, List<String> words) => words.any(s.contains);

  static const _notGeneral = [
    'سوشيال',
    'العاب',
    'موسيقي',
    'فيديو',
    'تطبيق',
    'هديه',
    'اضافي',
    'ليل',
    'تجوال',
    'ترفيه',
    'ستريم',
  ];

  static double? _factGb(Fact f) {
    final l = _norm(f.label), u = _norm(f.unit ?? '');
    if (_has(l, _notGeneral) || _has(l, const ['ميكس', 'وحدات', 'دقائق'])) {
      return null;
    }
    final v = _plain(f.value);
    if (v == null) return null;
    if (_has(u, const ['جيجا', 'gb'])) return v;
    if (_has(u, const ['ميجا', 'mb'])) return v / 1024;
    return null;
  }

  static double? _factMinutes(Fact f) {
    final l = _norm(f.label);
    if (!_has(_norm(f.unit ?? ''), const ['دقيقه', 'دقائق'])) return null;
    // Minutes inside the network, international or social only are not
    // general minutes.
    if (_has(l, _notGeneral) ||
        _has(l, const ['e&', 'اتصالات', 'دولي', 'عائل', 'ميكس', 'وحدات'])) {
      return null;
    }
    return _plain(f.value);
  }

  static double? _factMix(Fact f) {
    final l = _norm(f.label);
    if (!l.contains('ميكس') || l.contains('/')) return null;
    return _plain(f.value);
  }

  static double? _factCallUnits(Fact f) {
    final l = _norm(f.label);
    if (!l.contains('وحدات') || !(l.contains('مكالم') || l.contains('دقائق'))) {
      return null;
    }
    return _plain(f.value);
  }

  static double? _factDays(Fact? f) {
    if (f == null) return null;
    final text = toAsciiDigits('${f.value} ${f.unit ?? ''}');
    final months = RegExp(r'^\s*(\d+)\s*(شهر|شهور|أشهر|اشهر)').firstMatch(text);
    if (months != null) return double.parse(months[1]!) * 30;
    if (RegExp(r'^\s*(شهري|شهر)(?=$|[\s(—-])').hasMatch(text)) return 30;
    final m = RegExp(r'^\s*(\d+)\s*(يوم|أيام|ايام|ساعة|ساعه)(?=$|[\s(])')
        .firstMatch(text);
    if (m == null) return null;
    final n = double.parse(m[1]!);
    return m[2]!.startsWith('ساع') ? n / 24 : n;
  }

  static PackageUse _useOf(ContentItem item) {
    if (item.family == 'addon') return PackageUse.other;
    final s = _norm('${item.family ?? ''} ${item.category}');
    if (_has(s, const ['تجوال', 'roaming', 'زوار', 'travel', 'اضافات'])) {
      return PackageUse.other;
    }
    return PackageSegment.of(item) == PackageSegment.home
        ? PackageUse.home
        : PackageUse.mobile;
  }
}

/// `74.29`, `1,250`, `100` (no trailing zeros, at most two decimals).
String formatNumber(double v) {
  var s = v.toStringAsFixed(2);
  s = s.replaceFirst(RegExp(r'\.?0+$'), '');
  final dot = s.indexOf('.');
  final whole = dot < 0 ? s : s.substring(0, dot);
  final rest = dot < 0 ? '' : s.substring(dot);
  final grouped = whole.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return '$grouped$rest';
}

/// Every package of the current content, in content order.
final packageInfosProvider = Provider<List<PackageInfo>>((ref) {
  final library = ref.watch(contentLibraryProvider);
  return [
    for (final s in ContentSection.values)
      for (final i in library.itemsOf(s))
        if (i.type == ItemType.package) PackageInfo.of(i),
  ];
});
