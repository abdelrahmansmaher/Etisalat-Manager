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
  });

  factory PackageInfo.of(ContentItem item) {
    final facts = PackageFacts.of(item);

    // Two different prices for the same thing: the price is not settled.
    final settled = item.status != ItemStatus.conflict;

    double? price, total, gb, minutes, mix, days;
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
      }
      days ??= _factDays(facts.validity);
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

  static double? _factDays(Fact? f) {
    if (f == null) return null;
    final text = toAsciiDigits('${f.value} ${f.unit ?? ''}');
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
