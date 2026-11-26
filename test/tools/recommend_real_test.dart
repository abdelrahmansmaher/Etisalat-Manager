import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/content/content.dart';
import 'package:knowledge_hub/features/tools/package_info.dart';
import 'package:knowledge_hub/features/tools/recharge_rule.dart';
import 'package:knowledge_hub/features/tools/recommend_logic.dart';

/// The recommender on the REAL content gives the answers a counter
/// employee would give.
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

  String best(RecommendNeeds n) =>
      recommend(infos, n, rule: rule).best!.package.item.id;

  test('a budget alone gets the most it can buy, not the cheapest', () {
    expect(best(const RecommendNeeds(budget: 100)), 'pkg-hekaya-mixat-69');
  });

  test('minutes in mixes count only as the content states', () {
    // 5,375 mixes = 1,075 minutes even to other networks (5 mixes each).
    expect(best(const RecommendNeeds(minutes: 1000)), 'pkg-hekaya-mixat-120');
    final r = recommend(infos, const RecommendNeeds(minutes: 1000), rule: rule);
    // 3,750 mixes: enough only if the calls are to e& numbers.
    expect(
      r.maybe.map((x) => x.package.item.id),
      contains('pkg-hekaya-mixat-92'),
    );
  });

  test('a price deducted from balance is compared as the card to buy', () {
    final sc = infos.firstWhere((p) => p.item.id == 'net-super-connect-120');
    expect(sc.priceIsDeducted, isTrue);
    final (pays, computed) = paymentOf(sc, rule);
    expect(pays, 171.43);
    expect(computed, isTrue);
    final r = recommend(
      infos,
      const RecommendNeeds(budget: 150, gb: 5),
      rule: rule,
    );
    expect(r.fits.map((x) => x.package.item.id), isNot(contains(sc.item.id)));
  });

  test('a monthly need leaves out short packages', () {
    final r = recommend(
      infos,
      const RecommendNeeds(budget: 50, validity: ValidityNeed.monthly),
      rule: rule,
    );
    for (final x in r.fits) {
      expect(
        x.package.validityDays,
        greaterThanOrEqualTo(28),
        reason: x.package.item.id,
      );
    }
  });

  test('home internet: the budget buys the biggest plan it covers', () {
    expect(
      best(const RecommendNeeds(budget: 300, use: PackageUse.home)),
      'net-dsl-150gb',
    );
  });
}
