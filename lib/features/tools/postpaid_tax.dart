/// Taxes and fees on a postpaid (فاتورة) monthly fee, as the official site
/// states them (8% table tax, 14% VAT, 10 EGP state development fee) plus
/// the 1.34 EGP stamp duty the branch applies.
///
/// VAT is charged on the fee after the table tax, as the official home
/// internet prices show (290 -> 357 = 290 x 1.08 x 1.14).
class PostpaidTax {
  const PostpaidTax(this.fee);

  static const String itemId = 'pkg-postpaid-tax-rule';
  static const double tableTaxRate = 0.08;
  static const double vatRate = 0.14;
  static const double developmentFee = 10;
  static const double stampDuty = 1.34;

  /// Monthly fee before taxes.
  final double fee;

  double get tableTax => _r(fee * tableTaxRate);
  double get vat => _r((fee + fee * tableTaxRate) * vatRate);
  double get fees => developmentFee + stampDuty;

  /// What the customer pays a month.
  double get total =>
      _r(fee * (1 + tableTaxRate) * (1 + vatRate) + developmentFee + stampDuty);

  static double _r(double v) => (v * 100).roundToDouble() / 100;
}
