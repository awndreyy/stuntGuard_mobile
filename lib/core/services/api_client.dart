import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiClient {
  ApiClient._();

  static final http.Client _client = http.Client();

  static Uri buildUri(String endpoint) {
    final normalizedEndpoint = endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint;

    return Uri.parse('${ApiConfig.baseUrl}/$normalizedEndpoint');
  }

  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) {
    return _client
        .get(buildUri(endpoint), headers: headers)
        .timeout(ApiConfig.timeout);
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _client
        .post(
          buildUri(endpoint),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            ...?headers,
          },
          body: body,
        )
        .timeout(ApiConfig.timeout);
  }

  static void close() {
    _client.close();
  }
}
