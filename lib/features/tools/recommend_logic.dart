import 'package_info.dart';

class RecommendNeeds {
  const RecommendNeeds({
    this.budget,
    this.gb,
    this.minutes,
    this.use = PackageUse.mobile,
  });

  final double? budget;
  final double? gb;
  final double? minutes;
  final PackageUse use;

  bool get isEmpty => budget == null && gb == null && minutes == null;
}

enum NeedKind { budget, gb, minutes }

enum Verdict { met, missed, unknown }

enum VerdictReason {
  /// Compared with a number the content states.
  stated,

  /// Only the price before tax is stated and it fits; the full cost is not.
  totalNotStated,

  /// Quota is in mixes/units; the content gives no GB or minutes.
  mixOnly,

  /// The content does not state it.
  notStated,
}

class NeedResult {
  const NeedResult(this.need, this.verdict, this.reason, this.value);

  final NeedKind need;
  final Verdict verdict;
  final VerdictReason reason;

  /// The package's own number, when stated.
  final double? value;
}

class Recommendation {
  const Recommendation(this.package, this.needs);

  final PackageInfo package;
  final List<NeedResult> needs;

  int get missed => _count(Verdict.missed);
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

  /// Every need is met by stated numbers.
  final List<Recommendation> fits;

  /// Nothing missed, but something is not stated.
  final List<Recommendation> maybe;

  /// At least one need is missed and at least one is met.
  final List<Recommendation> closest;

  bool get nothingFits => fits.isEmpty;
}

RecommendResult recommend(
  List<PackageInfo> packages,
  RecommendNeeds needs, {
  int limit = 8,
}) {
  final all = [
    if (!needs.isEmpty)
      for (final p in packages)
        if (p.use == needs.use) Recommendation(p, evaluate(p, needs)),
  ];
  int order(Recommendation a, Recommendation b) {
    int c(num x, num y) => x.compareTo(y);
    var r = c(a.missed, b.missed);
    if (r == 0) r = c(a.package.confirmed ? 0 : 1, b.package.confirmed ? 0 : 1);
    if (r == 0) r = c(a.unknown, b.unknown);
    if (r == 0) r = c(_cost(a.package), _cost(b.package));
    if (r == 0) r = a.package.item.id.compareTo(b.package.item.id);
    return r;
  }

  List<Recommendation> pick(bool Function(Recommendation) test) =>
      (all.where(test).toList()..sort(order)).take(limit).toList();

  return RecommendResult(
    fits: pick((r) => r.fits),
    // Something must be known for it to be a suggestion at all.
    maybe: pick(
      (r) => r.missed == 0 && r.unknown > 0 && r.unknown < r.needs.length,
    ),
    closest: pick(
      (r) => r.missed > 0 && r.needs.any((n) => n.verdict == Verdict.met),
    ),
  );
}

double _cost(PackageInfo p) => p.total ?? p.price ?? double.infinity;

List<NeedResult> evaluate(PackageInfo p, RecommendNeeds n) => [
  if (n.budget != null) _budget(p, n.budget!),
  if (n.gb != null) _quota(NeedKind.gb, p, p.gb, n.gb!),
  if (n.minutes != null) _quota(NeedKind.minutes, p, p.minutes, n.minutes!),
];

NeedResult _budget(PackageInfo p, double budget) {
  NeedResult r(Verdict v, VerdictReason why, double? value) =>
      NeedResult(NeedKind.budget, v, why, value);
  final total = p.total, price = p.price;
  if (total != null) {
    return r(
      total <= budget ? Verdict.met : Verdict.missed,
      VerdictReason.stated,
      total,
    );
  }
  if (price == null) return r(Verdict.unknown, VerdictReason.notStated, null);
  return price > budget
      ? r(Verdict.missed, VerdictReason.stated, price)
      : r(Verdict.unknown, VerdictReason.totalNotStated, price);
}

NeedResult _quota(NeedKind kind, PackageInfo p, double? has, double need) {
  if (has != null) {
    return NeedResult(
      kind,
      has >= need ? Verdict.met : Verdict.missed,
      VerdictReason.stated,
      has,
    );
  }
  return p.mix != null
      ? NeedResult(kind, Verdict.unknown, VerdictReason.mixOnly, p.mix)
      : NeedResult(kind, Verdict.unknown, VerdictReason.notStated, null);
}
