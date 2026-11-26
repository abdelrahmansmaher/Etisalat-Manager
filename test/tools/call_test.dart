import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/features/tools/dial.dart';
import 'package:knowledge_hub/features/tools/dial_template.dart';

/// On Android the call button places the call itself: a USSD code reaches
/// the phone exactly as written, `#` included.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('counter_guide/call');

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('a USSD code is placed as a call with its # intact', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return true;
        });
    expect(await placeCall(telUri('*838#')), isTrue);
    expect(calls.single.method, 'call');
    expect(calls.single.arguments, {'number': '*838#'});
  });

  test('a phone number is placed as written', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    String? number;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          number = (call.arguments as Map)['number'] as String;
          return true;
        });
    expect(await placeCall(telUri('+201111234778')), isTrue);
    expect(number, '+201111234778');
  });
}
