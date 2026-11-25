import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/widgets/trust/trust.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('TrustFormat.date uses Western digits and month names', (
    tester,
  ) async {
    // Inside a localized app so intl date symbols are initialised.
    late String arDate;
    late String enDate;
    await pumpLocalized(
      tester,
      Builder(
        builder: (context) {
          arDate = TrustFormat.date(DateTime(2026, 11, 22), ar);
          enDate = TrustFormat.date(DateTime(2026, 11, 22), en);
          return const SizedBox();
        },
      ),
    );
    expect(arDate, '22 نوفمبر 2026');
    expect(enDate, '22 Nov 2026');
  });
}
