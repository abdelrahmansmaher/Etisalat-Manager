import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Trust-surface formatting (doc 04 §2.9):
/// * dates as `22 نوفمبر 2026` / `22 Nov 2026` — never `22/11/2026`;
/// * Western digits (0–9) everywhere, also in Arabic.
abstract final class TrustFormat {
  static String date(DateTime value, Locale locale) {
    final tag = locale.languageCode;
    final pattern = tag == 'ar' ? 'd MMMM y' : 'd MMM y';
    final format = DateFormat(pattern, tag)..useNativeDigits = false;
    return format.format(value);
  }

  /// Amount with Western digits and grouping, max 2 decimals.
  static String amount(num value) =>
      NumberFormat('#,##0.##', 'en_US').format(value);
}
