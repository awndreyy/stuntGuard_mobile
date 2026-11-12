import 'dart:convert';

import '../core/services/api_client.dart';
import '../models/informasi.dart';

class InformasiService {
  Future<List<Informasi>> fetchArticles() async {
    final response = await ApiClient.get('informasi');
    final Map<String, dynamic> data;

    try {
      data = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {
      throw Exception('Respons API artikel tidak valid.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['message']?.toString() ?? 'Gagal memuat artikel.');
    }

    final rows = data['data'];
    if (rows is! List) {
      throw Exception('Format daftar artikel dari server tidak sesuai.');
    }

    return rows
        .map((row) => Informasi.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }
}
