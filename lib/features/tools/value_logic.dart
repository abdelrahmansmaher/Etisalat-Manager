import 'package_info.dart';
import 'recharge_rule.dart';
import 'recommend_logic.dart';

/// What a pound buys: the unit packages are weighed by.
enum ValueBasis {
  /// Internet: price of one GB.
  gb,

  /// Calls: price of one minute. Packages in mixes/units count only the
  /// minutes the content says they give to ANY network (the cautious
  /// figure), never more.
  minute,

  /// Mixes of one family (they are used up differently in each family, so
  /// mixes of two families are never weighed against each other).
  mix,
}

/// One package's price per unit.
class ValueScore {
  const ValueScore(this.package, this.pays, this.units);

  final PackageInfo package;

  /// What the comparison charges: the same kind of price for every package
  /// in a ranking (what the customer pays, or the price before tax).
  final double pays;

  /// GB, minutes or mixes the package gives.
  final double units;

  double get unitCost => pays / units;
}

/// Packages ranked by price per unit, cheapest unit first.
class ValueRanking {
  const ValueRanking(this.basis, this.scores, {required this.paysTotal});

  final ValueBasis basis;
  final List<ValueScore> scores;

  /// Prices are what the customer pays (tax included), not before tax.
  final bool paysTotal;

  ValueScore get best => scores.first;

  /// Every package costs the same per unit: nobody wins.
  bool get tie =>
      scores.length > 1 &&
      (scores.last.unitCost - best.unitCost).abs() < 0.0005;

  /// How much cheaper per unit the winner is than the runner-up (0.12 =
  /// 12 %), `null` when there is no runner-up.
  double? get leadOverNext {
    if (scores.length < 2) return null;
    final next = scores[1].unitCost;
    return next <= 0 ? null : (next - best.unitCost) / next;
  }

  /// How much cheaper per unit the winner is than the dearest package.
  double? get leadOverLast {
    if (scores.length < 2) return null;
    final last = scores.last.unitCost;
    return last <= 0 ? null : (last - best.unitCost) / last;
  }
}

/// Units [p] gives on [basis], or `null` when the content does not say.
double? unitsOf(PackageInfo p, ValueBasis basis) {
  final double? v = switch (basis) {
    ValueBasis.gb => p.gb,
    ValueBasis.minute => p.minutes ?? _anyNetworkMinutes(p),
    ValueBasis.mix => p.mix,
  };
  return v == null || v <= 0 ? null : v;
}

double? _anyNetworkMinutes(PackageInfo p) {
  final units = p.callUnits, rate = p.unitsPerMinuteOther;
  if (units == null || rate == null || rate <= 0) return null;
  return units / rate;
}

/// Ranks [packages] by price per unit of [basis]. Packages that do not
/// state the unit or a price are left out. Prices are what the customer
/// pays when every package has it, else the price before tax for all:
/// never a mix of the two.
ValueRanking? rankByValue(
  List<PackageInfo> packages,
  ValueBasis basis, {
  RechargeRule? rule,
}) {
  final withUnits = [
    for (final p in packages)
      if (unitsOf(p, basis) != null) p,
  ];
  if (basis == ValueBasis.mix &&
      {for (final p in withUnits) p.family}.length > 1) {
    return null;
  }
  final totals = [for (final p in withUnits) paymentOf(p, rule).$1];
  final useTotal = totals.every((t) => t != null);
  final scores =
      <ValueScore>[
        for (final (i, p) in withUnits.indexed)
          if ((useTotal ? totals[i] : p.price) case final double pays
              when pays > 0)
            ValueScore(p, pays, unitsOf(p, basis)!),
      ]..sort((a, b) {
        final c = a.unitCost.compareTo(b.unitCost);
        // Same price per unit: the bigger package is the better buy.
        return c != 0 ? c : b.units.compareTo(a.units);
      });
  if (scores.isEmpty) return null;
  return ValueRanking(basis, scores, paysTotal: useTotal);
}

/// The fairest unit to weigh these exact packages by (all of them must
/// state it), or `null` when they cannot be weighed honestly.
ValueBasis? commonBasis(List<PackageInfo> packages) {
  if (packages.length < 2) return null;
  for (final b in ValueBasis.values) {
    if (packages.every((p) => unitsOf(p, b) != null)) {
      if (b == ValueBasis.mix &&
          {for (final p in packages) p.family}.length > 1) {
        continue;
      }
      return b;
    }
  }
  return null;
}

/// Best value among the packages being compared (all of them weighed).
ValueRanking? compareValue(List<PackageInfo> packages, {RechargeRule? rule}) {
  final basis = commonBasis(packages);
  if (basis == null) return null;
  final r = rankByValue(packages, basis, rule: rule);
  return r == null || r.scores.length != packages.length ? null : r;
}

/// Best value for the customer's money: among the packages of their kind
/// that the budget covers and that miss none of their needs, the cheapest
/// GB and/or the cheapest minute.
List<ValueRanking> valueForBudget(
  List<PackageInfo> packages,
  RecommendNeeds needs, {
  RechargeRule? rule,
}) {
  final budget = needs.budget;
  if (budget == null) return const [];
  final candidates = [
    for (final p in packages)
      if (p.use == needs.use &&
          evaluate(
            p,
            needs,
            rule: rule,
          ).every((n) => n.verdict != Verdict.missed) &&
          ((paymentOf(p, rule).$1 ?? p.price) ?? double.infinity) <=
              budget + 0.005)
        p,
  ];
  final bases = needs.gb != null || needs.use == PackageUse.home
      ? [ValueBasis.gb]
      : needs.minutes != null
      ? [ValueBasis.minute]
      : [ValueBasis.gb, ValueBasis.minute];
  return [
    for (final b in bases)
      if (rankByValue(candidates, b, rule: rule) case final r?
          when r.scores.length >= 2 && !r.tie)
        r,
  ];
}

/// `3.5 ج` per GB, `19 قرش` per minute, per 100 mixes for mixes.
String unitCostText(ValueRanking r, ValueScore s) {
  final cost = r.basis == ValueBasis.mix ? s.unitCost * 100 : s.unitCost;
  if (cost < 1) return '${formatNumber((cost * 100).roundToDouble())} قرش';
  return '${formatNumber(cost)} ج';
}
