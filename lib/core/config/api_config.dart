import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    final configured = _configuredBaseUrl.trim();
    if (configured.isNotEmpty) {
      return configured.replaceFirst(RegExp(r'/+$'), '');
    }

    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return 'http://127.0.0.1:8000/api';
    }

    // Android Emulator host alias; use API_BASE_URL for a physical device.
    return 'http://10.0.2.2:8000/api';
  }

  static const Duration timeout = Duration(seconds: 30);
}
