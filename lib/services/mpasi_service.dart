import 'dart:convert';

import '../core/services/api_client.dart';
import '../models/mpasi.dart';
import 'auth_service.dart';

class MpasiAuthenticationException implements Exception {
  const MpasiAuthenticationException();
}

class MpasiService {
  Future<MpasiPage> fetchRecipes({
    String query = '',
    String? kategoriUsia,
    int page = 1,
  }) async {
    final token = await AuthService().getToken();
    if (token == null || token.trim().isEmpty) {
      throw const MpasiAuthenticationException();
    }

    final parameters = {
      'page': '$page',
      if (query.trim().isNotEmpty) 'q': query.trim(),
      if (kategoriUsia != null) 'kategori_usia': kategoriUsia,
    };
    final response = await ApiClient.get(
      'mpasi?${Uri(queryParameters: parameters).query}',
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw const MpasiAuthenticationException();
    }

    Map<String, dynamic> data;
    try {
      data = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {
      throw Exception('Respons resep tidak valid. Periksa API Laravel.');
    }

    if (response.statusCode != 200) {
      throw Exception(data['message']?.toString() ?? 'Resep gagal dimuat.');
    }

    return MpasiPage.fromJson(data);
  }
}
