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

  Future<List<Pengukuran>> fetchByChild(String childId) async {
    if (childId.trim().isEmpty) return const [];

    final response = await ApiClient.get(
      'balita/${Uri.encodeComponent(childId)}/pengukuran',
      headers: await _headers(),
    );
    final data = _parse(response);
    final rows = data['data'];
    if (rows is! List) {
      throw Exception('Format daftar pengukuran dari server tidak sesuai.');
    }

    return rows
        .map(
          (row) => Pengukuran.fromJson(
            Map<String, dynamic>.from(row as Map),
            balitaId: childId,
          ),
        )
        .toList();
  }

  Future<Map<String, dynamic>> saveForChild({
    required String childId,
    required DateTime date,
    required double weight,
    required double height,
    required String bodyPosition,
  }) async {
    if (childId.trim().isEmpty) {
      throw Exception('Pilih anak yang akan diukur.');
    }

    final dateOnly =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final response = await ApiClient.post(
      'balita/${Uri.encodeComponent(childId)}/pengukuran',
      headers: await _headers(),
      body: jsonEncode({
        'tanggal_pengukuran': dateOnly,
        'weight': weight,
        'height': height,
        'posisi_badan': bodyPosition,
      }),
    );
    return _parse(response);
  }
}
