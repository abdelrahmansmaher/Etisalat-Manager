import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/content/content.dart';
import 'package:knowledge_hub/features/tools/package_info.dart';
import 'package:knowledge_hub/features/tools/recharge_rule.dart';
import 'package:knowledge_hub/features/tools/recommend_logic.dart';
import 'package:knowledge_hub/features/tools/value_logic.dart';

/// Value for money on the REAL content.
void main() {
  late List<PackageInfo> infos;
  late RechargeRule rule;

  setUpAll(() async {
    final lib = await ContentLoader.load(
      MemoryContentSource({
        for (final s in ContentSection.values)
          s: File(s.assetPath).readAsStringSync(),
      }),
    );
    infos = [
      for (final i in lib.all)
        if (i.type == ItemType.package) PackageInfo.of(i),
    ];
    rule = RechargeRule.tryParse(
      lib.all.firstWhere((i) => i.id == RechargeRule.itemId),
    )!;
  });

  PackageInfo byId(String id) => infos.firstWhere((p) => p.item.id == id);

  void show(ValueRanking r) {
    for (final s in r.scores) {
      // ignore: avoid_print
      print(
        '  ${r.basis.name} ${s.package.item.id}: pays ${s.pays} '
        'units ${s.units} -> ${unitCostText(r, s)}',
      );
    }
  }

  test('four Hekaya packages: the bigger one gives the cheapest minute', () {
    final r = compareValue([
      byId('pkg-hekaya-mixat-52'),
      byId('pkg-hekaya-mixat-69'),
      byId('pkg-hekaya-mixat-92'),
      byId('pkg-hekaya-mixat-120'),
    ], rule: rule)!;
    show(r);
    expect(r.scores, hasLength(4));
    expect(r.tie, isFalse);
    for (var i = 1; i < r.scores.length; i++) {
      expect(r.scores[i].unitCost, greaterThanOrEqualTo(r.best.unitCost));
    }
  });

  test('a budget of 100 names the cheapest GB and minute it can buy', () {
    final rs = valueForBudget(
      infos,
      const RecommendNeeds(budget: 100),
      rule: rule,
    );
    for (final r in rs) {
      show(r);
      for (final s in r.scores) {
        expect(s.pays, lessThanOrEqualTo(100.005));
      }
    }
    expect(rs, isNotEmpty);
  });

  test('home internet is weighed per GB', () {
    final rs = valueForBudget(
      infos,
      const RecommendNeeds(budget: 500, use: PackageUse.home),
      rule: rule,
    );
    for (final r in rs) {
      show(r);
      expect(r.basis, ValueBasis.gb);
    }
  });

  test('packages that share no unit are not weighed', () {
    final mix = infos.firstWhere(
      (p) =>
          p.mix != null &&
          p.gb == null &&
          unitsOf(p, ValueBasis.minute) == null,
    );
    final gb = infos.firstWhere(
      (p) =>
          p.gb != null &&
          p.mix == null &&
          unitsOf(p, ValueBasis.minute) == null,
    );
    expect(compareValue([mix, gb], rule: rule), isNull);
  });
}
