import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/services/api_client.dart';
import '../models/pengukuran.dart';
import 'auth_service.dart';

class PengukuranService {
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
        if (first is List && first.isNotEmpty) {
          throw Exception(first.first.toString());
        }
      }
      throw Exception(data['message']?.toString() ?? 'Permintaan gagal.');
    }
    return data;
  }

  /// Riwayat dari petugas / data lama. Kalkulasi orang tua tidak tersimpan.
  Future<List<Pengukuran>> fetchByChild(String childId) async {
    if (childId.trim().isEmpty) return const [];
    final result = <Pengukuran>[];
    var page = 1;
    while (true) {
      final response = await ApiClient.get(
        'balita/${Uri.encodeComponent(childId)}/pengukuran?page=$page&per_page=50',
        headers: await _headers(),
      );
      final data = _parse(response);
      final pagination = data['pengukurans'];
      if (pagination is! Map || pagination['data'] is! List) {
        throw Exception('Format riwayat pengukuran server tidak sesuai.');
      }
      for (final row in pagination['data'] as List) {
        result.add(
          Pengukuran.fromJson(
            Map<String, dynamic>.from(row as Map),
            balitaId: childId,
          ),
        );
      }
      final current = (pagination['current_page'] as num?)?.toInt() ?? page;
      final last = (pagination['last_page'] as num?)?.toInt() ?? current;
      if (current >= last) break;
      page = current + 1;
    }
    return result;
  }

  /// Hanya menghitung WHO. Endpoint Laravel tidak menulis ke database.
  Future<Map<String, dynamic>> calculateForChild({
    required String childId,
    required DateTime date,
    required double weight,
    required double height,
    required String bodyPosition,
    double? headCircumference,
    double? lila,
  }) async {
    if (childId.trim().isEmpty) {
      throw Exception('Pilih anak yang akan diukur.');
    }
    final dateOnly =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final response = await ApiClient.post(
      'pengukuran/hitung',
      headers: await _headers(),
      body: jsonEncode({
        'balita_id': childId,
        'tanggal_pengukuran': dateOnly,
        'berat_badan': weight,
        'tinggi_badan': height,
        'posisi_badan': bodyPosition,
        'lingkar_kepala': ?headCircumference,
        'lila': ?lila,
      }),
    );
    return _parse(response);
  }
}
