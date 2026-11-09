import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/services/api_client.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  // LOGIN
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      'login',
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = _parseResponse(response.body);

    if (response.statusCode == 200) {
      final token = data['token'];

      if (token is! String || token.isEmpty) {
        throw Exception('Token login tidak ditemukan.');
      }

      await _storage.write(key: 'auth_token', value: token);

      return data;
    }

    throw Exception(_errorMessage(data, 'Login gagal.'));
  }

  // REGISTER
  Future<Map<String, dynamic>> register({
    required String nama,
    required String nik,
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      'register',
      body: jsonEncode({
        'name': nama,
        'nik': nik,
        'email': email,
        'password': password,
      }),
    );

    final data = _parseResponse(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }

    throw Exception(_errorMessage(data, 'Registrasi gagal.'));
  }

  // AMBIL TOKEN
  Future<String?> getToken() async {
    return _storage.read(key: 'auth_token');
  }

  // Hapus token dari perangkat.
  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Pulihkan sesi dan ambil data pengguna dari server.
Future<Map<String, dynamic>?> restoreSession() async {
  final token = await getToken();

  if (token == null || token.trim().isEmpty) {
    return null;
  }

  final response = await ApiClient.get(
    'user',
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  // Token sudah kedaluwarsa atau dicabut.
  if (response.statusCode == 401) {
    await clearToken();
    return null;
  }

  // Gangguan server tidak menghapus token.
  if (response.statusCode != 200) {
    throw Exception('Sesi belum dapat diperiksa. Silakan coba lagi.');
  }

  final data = _parseResponse(response.body);

  // Mendukung respons user langsung maupun dibungkus user/data.
  final user = data['user'] ?? data['data'] ?? data;

  if (user is! Map) {
    throw Exception('Data pengguna dari server tidak valid.');
  }

  return Map<String, dynamic>.from(user);
}

  // LOGOUT
  Future<void> logout() async {
    final token = await getToken();

    if (token != null) {
      final response = await ApiClient.post(
        'logout',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Gagal logout dari server.');
      }
    }

    await _storage.delete(key: 'auth_token');
  }

  Map<String, dynamic> _parseResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      throw Exception('Respons server tidak valid. Periksa API Laravel.');
    }

    throw Exception('Format respons server tidak sesuai.');
  }

  String _errorMessage(Map<String, dynamic> data, String fallback) {
    final errors = data['errors'];

    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;

      if (first is List && first.isNotEmpty) {
        return first.first.toString();
      }
    }

    return data['message']?.toString() ?? fallback;
  }
}
