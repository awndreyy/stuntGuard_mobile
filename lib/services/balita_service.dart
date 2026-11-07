import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/services/api_client.dart';
import '../models/balita.dart';
import 'auth_service.dart';

class BalitaService {
  Future<Map<String, String>> _headers() async {
    final token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
    }
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  Map<String, dynamic> _parse(http.Response response) {
    late final Map<String, dynamic> data;
    try {
      data = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {
      throw Exception('Respons API Laravel tidak valid.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401) {
        throw Exception('Sesi login telah berakhir. Silakan login kembali.');
      }
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty)
          throw Exception(first.first.toString());
      }
      throw Exception(data['message']?.toString() ?? 'Permintaan gagal.');
    }
    return data;
  }

  Future<List<Balita>> fetchChildren() async {
    final response = await ApiClient.get('balita', headers: await _headers());
    final data = _parse(response);
    return (data['data'] as List)
        .map((e) => Balita.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> saveChild({
    String? id,
    required String nama,
    String? nik,
    required String tanggalLahir,
    required String jenisKelamin,
  }) async {
    final payload = jsonEncode({
      'nama_balita': nama.trim(),
      'nik': nik == null || nik.trim().isEmpty ? null : nik.trim(),
      'tanggal_lahir': tanggalLahir,
      'jenis_kelamin': jenisKelamin,
    });
    final headers = await _headers();
    final response = id == null
        ? await ApiClient.post('balita', headers: headers, body: payload)
        : await ApiClient.put(
            'balita/${Uri.encodeComponent(id)}',
            headers: headers,
            body: payload,
          );
    _parse(response);
  }

  Future<void> deleteChild(String id) async {
    final response = await ApiClient.delete(
      'balita/${Uri.encodeComponent(id)}',
      headers: await _headers(),
    );
    _parse(response);
  }
}
