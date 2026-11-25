import 'package_info.dart';

enum CompareRow { price, total, quota, gb, minutes, mix, validity, code, after }

/// Values of one row; `best` are the indexes to mark (empty when the values
/// cannot be compared honestly).
class CompareValues {
  const CompareValues(this.row, this.texts, this.best);

  final CompareRow row;

  /// `null` = not stated.
  final List<String?> texts;
  final Set<int> best;
}

List<CompareValues> compareRows(List<PackageInfo> packages) {
  List<T> each<T>(T Function(PackageInfo) f) => [for (final p in packages) f(p)];

  final days = each((p) => p.validityDays);
  // A daily and a monthly price (or quota) are not comparable.
  final samePeriod = !periodsDiffer(packages);
  final families = {for (final p in packages) p.family};

  Set<int> lowest(List<double?> v, {bool when = true}) =>
      when ? _extreme(v, (a, b) => a < b) : const {};
  Set<int> highest(List<double?> v, {bool when = true}) =>
      when ? _extreme(v, (a, b) => a > b) : const {};

  final gb = each((p) => p.gb);
  final minutes = each((p) => p.minutes);
  final mix = each((p) => p.mix);
  List<String?> fmt(List<double?> v) => [
    for (final n in v) n == null ? null : formatNumber(n),
  ];

  return [
    CompareValues(
      CompareRow.price,
      each((p) => p.priceText),
      lowest(each((p) => p.price), when: samePeriod),
    ),
    CompareValues(
      CompareRow.total,
      each((p) => p.totalText),
      lowest(each((p) => p.total), when: samePeriod),
    ),
    CompareValues(CompareRow.quota, each((p) => p.quotaText), const {}),
    if (gb.any((n) => n != null))
      CompareValues(CompareRow.gb, fmt(gb), highest(gb, when: samePeriod)),
    if (minutes.any((n) => n != null))
      CompareValues(
        CompareRow.minutes,
        fmt(minutes),
        highest(minutes, when: samePeriod),
      ),
    if (mix.any((n) => n != null))
      CompareValues(
        CompareRow.mix,
        fmt(mix),
        // Mixes are used up differently in each family.
        highest(mix, when: samePeriod && families.length == 1),
      ),
    CompareValues(
      CompareRow.validity,
      each((p) => p.validityText),
      highest(days),
    ),
    CompareValues(CompareRow.code, each((p) => p.codeText), const {}),
    CompareValues(CompareRow.after, each((p) => p.afterText), const {}),
  ];
}

Set<int> _extreme(List<double?> v, bool Function(double, double) better) {
  if (v.length < 2 || v.any((n) => n == null)) return const {};
  var best = v.first!;
  for (final n in v) {
    if (better(n!, best)) best = n;
  }
  final at = {
    for (var i = 0; i < v.length; i++)
      if (v[i] == best) i,
  };
  return at.length == v.length ? const {} : at; // all equal: nothing to mark
}

/// Periods differ or are not stated, so price and quota are not marked.
bool periodsDiffer(List<PackageInfo> packages) {
  final days = [for (final p in packages) p.validityDays];
  return days.any((d) => d == null) || days.toSet().length > 1;
}
