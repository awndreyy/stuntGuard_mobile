import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stuntguardmobile/core/config/api_config.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('Android emulator targets the host machine', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    expect(ApiConfig.baseUrl, 'http://10.0.2.2:8000/api');
  });

  test('desktop uses localhost when no API URL is configured', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    expect(ApiConfig.baseUrl, 'http://127.0.0.1:8000/api');
  });
}
