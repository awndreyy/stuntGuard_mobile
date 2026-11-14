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

  static Uri resolveServerUri(String path) {
    final uri = Uri.parse(path);
    if (uri.hasScheme) return uri;

    final baseUri = Uri.parse(ApiConfig.baseUrl);
    final serverPath = baseUri.path
        .replaceFirst(RegExp(r'/api/?$'), '')
        .replaceFirst(RegExp(r'/+$'), '');
    final resourcePath = uri.path.startsWith('/') ? uri.path : '/${uri.path}';

    return baseUri.replace(
      path: '$serverPath$resourcePath',
      query: uri.hasQuery ? uri.query : null,
      fragment: uri.hasFragment ? uri.fragment : null,
    );
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

  static Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _client
        .put(
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

  static Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) {
    return _client
        .delete(
          buildUri(endpoint),
          headers: {'Accept': 'application/json', ...?headers},
        )
        .timeout(ApiConfig.timeout);
  }

  static void close() {
    _client.close();
  }
}
