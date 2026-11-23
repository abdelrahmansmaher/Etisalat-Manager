import '../../core/content/content_models.dart';

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
