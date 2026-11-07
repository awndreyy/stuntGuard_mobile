import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    if (kIsWeb) {
      // Flutter Web (Chrome di laptop)
      return 'http://127.0.0.1:8000/api';
    }

    // Android Emulator atau HP fisik
    return 'http://192.168.18.16:8000/api';
  }

  static const Duration timeout = Duration(seconds: 30);
}
