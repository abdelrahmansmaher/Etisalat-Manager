import 'package:flutter/widgets.dart';

import '../../core/theme/app_icons.dart';
import '../../core/content/content_models.dart';
import '../../core/widgets/trust/trust_format.dart';
import '../../l10n/app_localizations.dart';

/// What a fact means inside a package page.
enum PackageFactRole {
  /// السعر (الخصم من الرصيد) — the headline price.
  price,

  /// السعر المطلوب شحنه / شامل الضريبة — the tax-basis line under the price.
  rechargePrice,

  /// الحصة (minutes, MB/GB, mixes, units…).
  quota,

  /// الصلاحية / المدة.
  validity,

  /// كود الاشتراك.
  code,

  /// التجديد.
  renewal,

  /// سعر ما بعد الباقة / بعد نفاد الباقة.
  afterBundle,

  /// Anything else (details table only).
  other,
}

/// Package facts sorted into roles for the dedicated package layout.
///
/// Detection is by `kind` first and Arabic label keywords second, after
/// light normalisation (diacritics, tatweel, alef/ya/ta-marbuta variants),
/// so small wording changes in the data never break the layout.
class PackageFacts {
  PackageFacts._({
    required this.price,
    required this.rechargePrice,
    required this.quotas,
    required this.validity,
    required this.code,
    required this.renewal,
    required this.afterBundle,
    required this.others,
  });

  factory PackageFacts.of(ContentItem item) {
    Fact? price;
    Fact? recharge;
    Fact? validity;
    Fact? code;
    Fact? renewal;
    Fact? after;
    final quotas = <Fact>[];
    final others = <Fact>[];

    // Prefer an explicit "deducted from balance" price over any other price.
    final prices = item.facts
        .where((f) => roleOf(f) == PackageFactRole.price)
        .toList();
    final preferred = prices.where((f) => _isDeductedPrice(f.label));
    price = preferred.isNotEmpty
        ? preferred.first
        : (prices.isEmpty ? null : prices.first);

    final codes = item.facts.where((f) => roleOf(f) == PackageFactRole.code);
    final subscribe = codes.where((f) => _has(f.label, _subscribeWords));
    code = subscribe.isNotEmpty
        ? subscribe.first
        : (codes.isEmpty ? null : codes.first);

    for (final f in item.facts) {
      if (identical(f, price) || identical(f, code)) continue;
      switch (roleOf(f)) {
        case PackageFactRole.rechargePrice when recharge == null:
          recharge = f;
        case PackageFactRole.validity when validity == null:
          validity = f;
        case PackageFactRole.renewal when renewal == null:
          renewal = f;
        case PackageFactRole.afterBundle when after == null:
          after = f;
        case PackageFactRole.quota:
          quotas.add(f);
        default:
          others.add(f);
      }
    }
    return PackageFacts._(
      price: price,
      rechargePrice: recharge,
      quotas: quotas,
      validity: validity,
      code: code,
      renewal: renewal,
      afterBundle: after,
      others: others,
    );
  }

  final Fact? price;
  final Fact? rechargePrice;
  final List<Fact> quotas;
  final Fact? validity;
  final Fact? code;
  final Fact? renewal;
  final Fact? afterBundle;
  final List<Fact> others;

  /// Metric tiles, in reading order: quotas, validity, renewal, after-bundle.
  /// Placeholder values (`–`) stay in the details table only.
  List<(PackageFactRole, Fact)> get metrics => [
    for (final q in quotas)
      if (!q.isBlank) (PackageFactRole.quota, q),
    if (validity != null) (PackageFactRole.validity, validity!),
    if (renewal != null) (PackageFactRole.renewal, renewal!),
    if (afterBundle != null) (PackageFactRole.afterBundle, afterBundle!),
  ];

  static const _renewalWords = ['تجديد', 'يتجدد', 'التجدد', 'renew'];
  static const _afterWords = [
    'بعد البا',
    'بعد نفاد',
    'بعد نفاذ',
    'بعد انتها',
    'بعد خلاص',
    'ما بعد',
    'خارج البا',
  ];
  static const _rechargeWords = [
    'شحن',
    'شامل',
    'بعد الضريب',
    'المطلوب',
    'مطلوب',
    'كارت',
  ];
  static const _deductedWords = ['خصم', 'يخصم', 'الصافي', 'من الرصيد'];
  static const _priceWords = ['سعر', 'السعر', 'اشتراك', 'خصم', 'تكلف', 'price'];
  static const _extraWords = ['اضافي', 'اضافه', 'إضافي'];
  static const _validityWords = ['صلاحي', 'المده', 'مده', 'validity'];
  static const _quotaWords = [
    'حصه',
    'الحصه',
    'ميجا',
    'جيجا',
    'ميكس',
    'دقائق',
    'دقيقه',
    'وحدات',
    'رسائل',
    'انترنت',
    'السعه',
  ];
  static const _subscribeWords = ['اشتراك', 'الاشتراك', 'للاشتراك'];

  static bool _isDeductedPrice(String label) => _has(label, _deductedWords);

  /// Role of a single fact (without the "first wins" tie-breaking that
  /// [PackageFacts.of] adds).
  static PackageFactRole roleOf(Fact f) {
    final l = f.label;
    final hasNumber = RegExp(r'[0-9٠-٩]').hasMatch(f.value);
    if (_has(l, _renewalWords)) return PackageFactRole.renewal;
    if (_has(l, _afterWords) &&
        (f.kind == FactKind.price || f.kind == FactKind.text)) {
      return PackageFactRole.afterBundle;
    }
    switch (f.kind) {
      case FactKind.code:
        return PackageFactRole.code;
      case FactKind.price:
        if (_has(l, _rechargeWords) && !_isDeductedPrice(l)) {
          return PackageFactRole.rechargePrice;
        }
        if (_has(l, _extraWords)) return PackageFactRole.other;
        if (l.isEmpty || _has(l, _priceWords)) return PackageFactRole.price;
        return PackageFactRole.other;
      case FactKind.duration:
        return PackageFactRole.validity;
      case FactKind.quantity:
        return PackageFactRole.quota;
      case FactKind.text:
        if (_has(l, _validityWords) && hasNumber) {
          return PackageFactRole.validity;
        }
        return PackageFactRole.other;
      default:
        if (_has(l, _validityWords)) return PackageFactRole.validity;
        if (_has(l, _quotaWords)) return PackageFactRole.quota;
        return PackageFactRole.other;
    }
  }

  static bool _has(String label, List<String> words) {
    final n = normalizeLabel(label);
    return words.any((w) => n.contains(normalizeLabel(w)));
  }

  /// Light Arabic normalisation for keyword matching.
  static String normalizeLabel(String s) {
    final b = StringBuffer();
    for (final r in s.toLowerCase().runes) {
      // Harakat, tanween, shadda, sukun, superscript alef; tatweel.
      if ((r >= 0x064B && r <= 0x065F) || r == 0x0670 || r == 0x0640) {
        continue;
      }
      b.writeCharCode(switch (r) {
        0x0623 || 0x0625 || 0x0622 || 0x0671 => 0x0627, // أ إ آ ٱ → ا
        0x0629 => 0x0647, // ة → ه
        0x0649 => 0x064A, // ى → ي
        _ => r,
      });
    }
    return b.toString();
  }
}

/// Leading icon for any fact: by package role when given, else by kind,
/// refined by label keywords (data vs minutes vs SMS, fees, limits…).
abstract final class FactIcons {
  static IconData of(Fact f, [PackageFactRole? role]) {
    final l = PackageFacts.normalizeLabel('${f.label} ${f.unit ?? ''}');
    bool has(List<String> w) => w.any(l.contains);
    switch (role ?? PackageFacts.roleOf(f)) {
      case PackageFactRole.validity:
        return AppIcons.validity;
      case PackageFactRole.renewal:
        return AppIcons.renewal;
      case PackageFactRole.afterBundle:
        return AppIcons.afterBundle;
      case PackageFactRole.rechargePrice:
        return AppIcons.recharge;
      case PackageFactRole.code:
        return AppIcons.code;
      case PackageFactRole.price:
        return AppIcons.price;
      case PackageFactRole.quota:
        if (has(['ميجا', 'جيجا', 'انترنت', 'السعه', 'داتا'])) {
          return AppIcons.quotaData;
        }
        if (has(['دقائق', 'دقيقه', 'مكالمات'])) return AppIcons.quotaMinutes;
        if (has(['رسائل'])) return AppIcons.quotaSms;
        if (has(['ميكس'])) return AppIcons.quotaMixes;
        if (has(['خطوط', 'عائله', 'ارقام'])) return AppIcons.quotaLines;
        if (has(['تطبيق'])) return AppIcons.quotaApps;
        return AppIcons.quota;
      case PackageFactRole.other:
        break;
    }
    if (has(['تجوال', 'دولي'])) return AppIcons.roaming;
    if (has(['رسوم', 'عموله'])) return AppIcons.fee;
    if (has(['حد ', 'الحد', 'اقصي', 'limit'])) return AppIcons.limit;
    if (has(['سرعه'])) return AppIcons.speed;
    return switch (f.kind) {
      FactKind.price => AppIcons.price,
      FactKind.code => AppIcons.code,
      FactKind.phone => AppIcons.phone,
      FactKind.quantity => AppIcons.quota,
      FactKind.duration => AppIcons.validity,
      FactKind.percent => AppIcons.percent,
      FactKind.date => AppIcons.date,
      FactKind.text => AppIcons.note,
    };
  }
}

/// First number in [value] (`1,250 ج بدل 2,500` → 1250), or `null`.
double? firstNumber(String value) {
  final m = RegExp(r'\d[\d,]*(?:\.\d+)?').firstMatch(value);
  return m == null ? null : double.tryParse(m[0]!.replaceAll(',', ''));
}

/// Price used for ordering a package (and shown in lists), or `null` when it
/// has no price. The structured `price_egp` wins over the facts.
double? packageSortPrice(ContentItem item) {
  final typed = item.priceEgp ?? item.priceTotalEgp;
  if (typed != null) return typed.toDouble();
  final facts = PackageFacts.of(item);
  for (final f in [facts.price, facts.rechargePrice]) {
    final n = f == null ? null : firstNumber(f.value);
    if (n != null) return n;
  }
  return null;
}

/// Data quota in GB used for ordering; mixes and minutes only break ties
/// when a package has no data. `null` = no quota known.
double? packageSortQuota(ContentItem item) {
  if (item.quotaGb != null) return item.quotaGb!.toDouble();
  final facts = PackageFacts.of(item);
  for (final f in facts.quotas) {
    final text = PackageFacts.normalizeLabel(
      '${f.label} ${f.value} ${f.unit ?? ''}',
    );
    final n = firstNumber(f.value);
    if (n == null) continue;
    if (text.contains('جيجا') || text.contains('gb')) return n;
    if (text.contains('ميجا') || text.contains('mb')) return n / 1000;
  }
  final mix = item.quotaMix ?? item.quotaMinutes;
  if (mix != null) return mix / 1000000;
  return null;
}

enum PackageSort { priceUp, priceDown, quota }

/// Orders the packages among [items]. Packages come first; those without a
/// price (or quota) follow, then every other item in its original order.
List<ContentItem> sortedPackages(
  List<ContentItem> items, [
  PackageSort sort = PackageSort.priceUp,
]) {
  final keyed = <(double, int, ContentItem)>[];
  final unkeyed = <ContentItem>[];
  final rest = <ContentItem>[];
  for (final (n, i) in items.indexed) {
    if (i.type != ItemType.package) {
      rest.add(i);
      continue;
    }
    final k = sort == PackageSort.quota
        ? packageSortQuota(i)
        : packageSortPrice(i);
    k == null ? unkeyed.add(i) : keyed.add((k, n, i));
  }
  final sign = sort == PackageSort.priceUp ? 1 : -1;
  keyed.sort((a, b) {
    final c = a.$1.compareTo(b.$1) * sign;
    return c != 0 ? c : a.$2.compareTo(b.$2);
  });
  return [for (final e in keyed) e.$3, ...unkeyed, ...rest];
}

/// From cheapest to most expensive (the default everywhere).
List<ContentItem> sortedByPrice(List<ContentItem> items) =>
    sortedPackages(items);

/// Everything a package list row shows, as ready text.
class PackageLine {
  const PackageLine._({this.price, this.quota, this.validity, this.code});

  factory PackageLine.of(ContentItem item, AppLocalizations l10n) {
    final facts = PackageFacts.of(item);
    final price = packageSortPrice(item);

    String? validity;
    final days = item.validityDays;
    final v = facts.validity;
    if (days != null && days == days.roundToDouble()) {
      validity = l10n.daysCount(days.toInt());
    } else if (v != null && !v.isBlank) {
      validity = _noBrackets(v.display);
    }

    final quota = <String>[
      if (item.quotaMix case final q?) l10n.quotaMix(TrustFormat.amount(q)),
      if (item.quotaGb case final q?)
        q < 1
            ? l10n.quotaMb(TrustFormat.amount(q * 1000))
            : l10n.quotaGb(TrustFormat.amount(q)),
      if (item.quotaMinutes case final q?)
        l10n.quotaMinutes(TrustFormat.amount(q)),
    ];
    if (quota.isEmpty) {
      for (final f in facts.quotas) {
        if (f.isBlank || quota.length == 2) continue;
        quota.add(_quotaText(f));
      }
    }

    final code = facts.code?.value ?? item.codes.firstOrNull;
    return PackageLine._(
      price: item.status == ItemStatus.conflict || price == null
          ? null
          : TrustFormat.amount(price),
      quota: quota.isEmpty ? null : quota.join('، '),
      validity: validity,
      code: code,
    );
  }

  /// Amount without its unit; `null` = no single price to quote.
  final String? price;
  final String? quota;
  final String? validity;
  final String? code;

  /// "quota · validity".
  String get details => [?quota, ?validity].join(' · ');

  static final RegExp _brackets = RegExp(r'\s*\([^)]*\)');

  static String _noBrackets(String s) {
    final out = s.replaceAll(_brackets, '').split(' — ').first.trim();
    return out.isEmpty ? s : out;
  }

  /// `1,900` under "الحصة (ميكس)" reads "1,900 ميكس"; a value that already
  /// carries words or a unit is kept.
  static String _quotaText(Fact f) {
    final value = _noBrackets(f.display);
    final bracket = RegExp(r'\(([^)]*)\)').firstMatch(f.label)?.group(1);
    if (bracket == null || f.unit != null) {
      // Same unit several times (app hours): say what each one is for.
      return f.unit == 'دقيقة' && bracket != null && !bracket.contains('دقا')
          ? '$value $bracket'
          : value;
    }
    return RegExp('[A-Za-z\u0600-\u06FF]').hasMatch(value)
        ? value
        : '$value $bracket';
  }
}
