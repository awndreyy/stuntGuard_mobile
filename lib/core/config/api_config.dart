import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    if (kIsWeb) {
      // run di browser
      return 'http://127.0.0.1:8000/api';
    }
    // run di emulator
    return 'http://10.0.2.2:8000/api';
  }

  static const Duration timeout = Duration(seconds: 30);
}
