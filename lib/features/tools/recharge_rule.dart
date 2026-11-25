import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/content.dart';
import '../content/package_facts.dart';
import 'dial_template.dart';

/// "A card of [card] EGP gives [balance] EGP", as one content item states it.
class RechargeRule {
  const RechargeRule({
    required this.item,
    required this.card,
    required this.balance,
  });

  static const String itemId = 'pkg-recharge-tax-rule';

  final ContentItem item;
  final double card;
  final double balance;

  double balanceFor(double cardValue) => cardValue * balance / card;

  /// Card value needed for [price], rounded up to a piastre.
  double cardFor(double price) =>
      (price * card / balance * 100 - 1e-6).ceilToDouble() / 100;

  /// `null` unless the facts state exactly one card value and one balance.
  static RechargeRule? tryParse(ContentItem? item) {
    if (item == null || item.status == ItemStatus.conflict) return null;
    final cards = <double>{}, balances = <double>{};
    for (final f in item.facts) {
      if (f.kind != FactKind.price) continue;
      final l = PackageFacts.normalizeLabel(f.label);
      if (l.contains('مثال') || l.contains('غير م')) continue;
      final isCard = l.contains('كارت'), isBalance = l.contains('رصيد');
      if (isCard == isBalance) continue;
      final v = double.tryParse(
        toAsciiDigits(f.value).trim().replaceAll(',', ''),
      );
      if (v == null || v <= 0) return null;
      (isCard ? cards : balances).add(v);
    }
    if (cards.length != 1 || balances.length != 1) return null;
    final card = cards.first, balance = balances.first;
    if (balance > card) return null;
    return RechargeRule(item: item, card: card, balance: balance);
  }
}

/// The rule in the current content, or `null` (missing or not readable).
final rechargeRuleProvider = Provider<RechargeRule?>(
  (ref) => RechargeRule.tryParse(
    ref.watch(contentItemProvider(RechargeRule.itemId)),
  ),
);

/// Hide every entry to the calculator when this is false.
final rechargeCalculatorAvailableProvider = Provider<bool>(
  (ref) => ref.watch(rechargeRuleProvider) != null,
);
