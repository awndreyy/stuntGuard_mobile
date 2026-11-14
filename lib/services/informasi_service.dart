import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/services/api_client.dart';
import '../models/informasi.dart';
import 'auth_service.dart';

class InformasiService {
  Future<Map<String, String>> _headers() async {
    final token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
    }
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  /// Ambil seluruh halaman hasil paginasi Laravel untuk beranda dan pencarian lokal.
  Future<List<Informasi>> fetchArticles() async {
    final articles = <Informasi>[];
    var page = 1;
    while (true) {
      final response = await ApiClient.get(
        'informasi?page=$page&per_page=50',
        headers: await _headers(),
      );
      final data = _parse(response);
      final rows = data['data'];
      if (rows is! List) {
        throw Exception('Format daftar artikel dari server tidak sesuai.');
      }
      articles.addAll(
        rows.map(
          (row) => _articleFromJson(Map<String, dynamic>.from(row as Map)),
        ),
      );
      final current = (data['current_page'] as num?)?.toInt() ?? page;
      final last = (data['last_page'] as num?)?.toInt() ?? current;
      if (current >= last) break;
      page = current + 1;
    }
    return articles;
  }

  Future<Informasi> fetchArticle(String id) async {
    final response = await ApiClient.get(
      'informasi/${Uri.encodeComponent(id)}',
      headers: await _headers(),
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

    if (response.statusCode == 401) {
      throw Exception('Sesi login telah berakhir. Silakan login kembali.');
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
