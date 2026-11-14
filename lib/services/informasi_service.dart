import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/services/api_client.dart';
import '../models/informasi.dart';

class InformasiService {
  Future<List<Informasi>> fetchArticles() async {
    final response = await ApiClient.get(
      'informasi',
      headers: const {'Accept': 'application/json'},
    );
    final data = _parse(response);

    final rows = data['data'];
    if (rows is! List) {
      throw Exception('Format daftar artikel dari server tidak sesuai.');
    }

    return rows
        .map((row) => _articleFromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<Informasi> fetchArticle(String id) async {
    final response = await ApiClient.get(
      'informasi/${Uri.encodeComponent(id)}',
      headers: const {'Accept': 'application/json'},
    );
    final data = _parse(response);
    final row = data['data'];
    if (row is! Map) {
      throw Exception('Format detail artikel dari server tidak sesuai.');
    }

    return _articleFromJson(Map<String, dynamic>.from(row));
  }

  Map<String, dynamic> _parse(http.Response response) {
    late final Map<String, dynamic> data;
    try {
      data = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {
      throw Exception('Respons API artikel tidak valid.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['message']?.toString() ?? 'Gagal memuat artikel.');
    }
    return data;
  }

  Informasi _articleFromJson(Map<String, dynamic> json) {
    final thumbnail = json['thumbnail_url'];
    if (thumbnail is String && thumbnail.trim().isNotEmpty) {
      json['thumbnail_url'] = ApiClient.resolveServerUri(thumbnail).toString();
    }
    return Informasi.fromJson(json);
  }
}
