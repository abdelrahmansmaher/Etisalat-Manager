import 'package_info.dart';
import 'recharge_rule.dart';

/// How long the package should last.
enum ValidityNeed {
  any,

  /// 28 days or more.
  monthly,

  /// Less than 28 days (daily, weekly, a few days).
  short,
}

class RecommendNeeds {
  const RecommendNeeds({
    this.budget,
    this.gb,
    this.minutes,
    this.use = PackageUse.mobile,
    this.validity = ValidityNeed.any,
  });

  /// What the customer will pay (the card, tax included).
  final double? budget;
  final double? gb;
  final double? minutes;
  final PackageUse use;
  final ValidityNeed validity;

  bool get isEmpty =>
      budget == null &&
      gb == null &&
      minutes == null &&
      validity == ValidityNeed.any;

  /// Only a budget (and maybe a duration): spend it well.
  bool get budgetOnly => budget != null && gb == null && minutes == null;
}

enum NeedKind { budget, gb, minutes, validity }

enum Verdict { met, missed, unknown }

enum VerdictReason {
  /// Compared with a number the content states.
  stated,

  /// The card was worked out from the price deducted from balance with the
  /// recharge ratio of the official prices.
  computed,

  /// Only the price before tax is stated and it fits; the full cost is not.
  totalNotStated,

  /// Quota is in mixes/units; the content gives no GB.
  mixOnly,

  /// Units cover the minutes only if the calls are to e& numbers.
  mixEandOnly,

  /// Units cover the minutes even to other networks.
  mixAnyNetwork,

  /// The content does not state it.
  notStated,
}

class NeedResult {
  const NeedResult(this.need, this.verdict, this.reason, this.value);

  final NeedKind need;
  final Verdict verdict;
  final VerdictReason reason;

  /// The package's own number, when stated or computed.
  final double? value;
}

class Recommendation {
  const Recommendation(this.package, this.needs, {this.pays, this.computed});

  final PackageInfo package;
  final List<NeedResult> needs;

  /// What the customer pays, when known.
  final double? pays;

  /// [pays] was computed, not stated.
  final bool? computed;

  int get missed => _count(Verdict.missed);

  /// Internet / minutes needs this package covers.
  int get quotaMet => needs
      .where(
        (n) =>
            (n.need == NeedKind.gb || n.need == NeedKind.minutes) &&
            n.verdict == Verdict.met,
      )
      .length;
  int get unknown => _count(Verdict.unknown);
  int _count(Verdict v) => needs.where((n) => n.verdict == v).length;

  bool get fits => missed == 0 && unknown == 0;
}

class RecommendResult {
  const RecommendResult({
    required this.fits,
    required this.maybe,
    required this.closest,
  });

  /// Every need is met (stated or computed numbers). The first one is the
  /// recommendation.
  final List<Recommendation> fits;

  /// Nothing missed, but something is not stated.
  final List<Recommendation> maybe;

  /// At least one need is missed and at least one is met.
  final List<Recommendation> closest;

  bool get nothingFits => fits.isEmpty;
  Recommendation? get best => fits.firstOrNull;
}

/// What the customer pays for [p]: the stated total, else (for a price
/// deducted from balance) the card worked out with [rule].
(double?, bool) paymentOf(PackageInfo p, RechargeRule? rule) {
  if (p.total != null) return (p.total, false);
  final price = p.price;
  if (price != null && rule != null && p.priceIsDeducted) {
    return (rule.cardFor(price), true);
  }
  return (null, false);
}

RecommendResult recommend(
  List<PackageInfo> packages,
  RecommendNeeds needs, {
  RechargeRule? rule,
  int limit = 8,
}) {
  final all = <Recommendation>[
    if (!needs.isEmpty)
      for (final p in packages)
        if (p.use == needs.use) _evaluate(p, needs, rule),
  ];

  double pays(Recommendation r) => r.pays ?? r.package.price ?? double.infinity;
  double quota(Recommendation r) =>
      r.package.gb ?? r.package.minutes ?? r.package.callUnits ?? 0;

  int order(Recommendation a, Recommendation b) {
    int c(num x, num y) => x.compareTo(y);
    var r = c(a.missed, b.missed);
    // A stated quota that covers the need beats one in units.
    if (r == 0) r = c(b.quotaMet, a.quotaMet);
    if (r == 0) r = c(a.package.confirmed ? 0 : 1, b.package.confirmed ? 0 : 1);
    if (r == 0) r = c(a.unknown, b.unknown);
    if (r == 0) {
      // A budget only: the most the money buys comes first. Otherwise the
      // cheapest package that covers the needs.
      r = needs.budgetOnly ? c(pays(b), pays(a)) : c(pays(a), pays(b));
    }
    if (r == 0) r = c(quota(b), quota(a));
    if (r == 0) r = a.package.item.id.compareTo(b.package.item.id);
    return r;
  }

  List<Recommendation> pick(bool Function(Recommendation) test) =>
      (all.where(test).toList()..sort(order)).take(limit).toList();

  return RecommendResult(
    fits: pick((r) => r.fits),
    // Something must be known for it to be a suggestion at all.
    maybe: pick(
      (r) =>
          r.missed == 0 &&
          r.unknown > 0 &&
          r.needs.any(
            (n) =>
                n.verdict == Verdict.met ||
                n.reason == VerdictReason.mixEandOnly,
          ),
    ),
    closest: pick(
      (r) => r.missed > 0 && r.needs.any((n) => n.verdict == Verdict.met),
    ),
  );
}

Recommendation _evaluate(PackageInfo p, RecommendNeeds n, RechargeRule? rule) {
  final (pays, computed) = paymentOf(p, rule);
  return Recommendation(
    p,
    evaluate(p, n, rule: rule),
    pays: pays,
    computed: pays == null ? null : computed,
  );
}

List<NeedResult> evaluate(
  PackageInfo p,
  RecommendNeeds n, {
  RechargeRule? rule,
}) => [
  if (n.budget != null) _budget(p, n.budget!, rule),
  if (n.gb != null) _gb(p, n.gb!),
  if (n.minutes != null) _minutes(p, n.minutes!),
  if (n.validity != ValidityNeed.any) _validity(p, n.validity),
];

NeedResult _budget(PackageInfo p, double budget, RechargeRule? rule) {
  NeedResult r(Verdict v, VerdictReason why, double? value) =>
      NeedResult(NeedKind.budget, v, why, value);
  final (pays, computed) = paymentOf(p, rule);
  if (pays != null) {
    return r(
      pays <= budget + 0.005 ? Verdict.met : Verdict.missed,
      computed ? VerdictReason.computed : VerdictReason.stated,
      pays,
    );
  }
  final price = p.price;
  if (price == null) return r(Verdict.unknown, VerdictReason.notStated, null);
  return price > budget
      ? r(Verdict.missed, VerdictReason.stated, price)
      : r(Verdict.unknown, VerdictReason.totalNotStated, price);
}

NeedResult _gb(PackageInfo p, double need) {
  final has = p.gb;
  if (has != null) {
    return NeedResult(
      NeedKind.gb,
      has >= need ? Verdict.met : Verdict.missed,
      VerdictReason.stated,
      has,
    );
  }
  return p.mix != null || p.callUnits != null
      ? NeedResult(
          NeedKind.gb,
          Verdict.unknown,
          VerdictReason.mixOnly,
          p.mix ?? p.callUnits,
        )
      : const NeedResult(
          NeedKind.gb,
          Verdict.unknown,
          VerdictReason.notStated,
          null,
        );
}

NeedResult _minutes(PackageInfo p, double need) {
  final has = p.minutes;
  if (has != null) {
    return NeedResult(
      NeedKind.minutes,
      has >= need ? Verdict.met : Verdict.missed,
      VerdictReason.stated,
      has,
    );
  }
  final units = p.callUnits;
  final eand = p.unitsPerMinuteEand, other = p.unitsPerMinuteOther;
  if (units != null && eand != null && other != null) {
    // The content states how many units a minute uses on each network.
    if (units >= need * other) {
      return NeedResult(
        NeedKind.minutes,
        Verdict.met,
        VerdictReason.mixAnyNetwork,
        units,
      );
    }
    if (units >= need * eand) {
      return NeedResult(
        NeedKind.minutes,
        Verdict.unknown,
        VerdictReason.mixEandOnly,
        units,
      );
    }
    return NeedResult(
      NeedKind.minutes,
      Verdict.missed,
      VerdictReason.mixEandOnly,
      units,
    );
  }
  return units != null
      ? NeedResult(
          NeedKind.minutes,
          Verdict.unknown,
          VerdictReason.mixOnly,
          units,
        )
      : const NeedResult(
          NeedKind.minutes,
          Verdict.unknown,
          VerdictReason.notStated,
          null,
        );
}

NeedResult _validity(PackageInfo p, ValidityNeed need) {
  final days = p.validityDays;
  if (days == null) {
    return const NeedResult(
      NeedKind.validity,
      Verdict.unknown,
      VerdictReason.notStated,
      null,
    );
  }
  final ok = need == ValidityNeed.monthly ? days >= 28 : days < 28;
  return NeedResult(
    NeedKind.validity,
    ok ? Verdict.met : Verdict.missed,
    VerdictReason.stated,
    days,
  );
}
