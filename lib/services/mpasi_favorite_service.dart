import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/mpasi.dart';
import 'auth_service.dart';

/// Menyimpan data resep ke SQLite tanpa mengunduh atau menyimpan foto.
/// Database terpisah agar riwayat pengukuran mandiri tidak terpengaruh.
class MpasiFavoriteService {
  static Database? _database;
  static Future<Database>? _opening;
  final AuthService _auth = AuthService();

  Future<Database> get _db async {
    if (_database?.isOpen ?? false) return _database!;
    return _opening ??= _openDatabase().whenComplete(() => _opening = null);
  }

  Future<Database> _openDatabase() async {
    final folder = await getDatabasesPath();
    final db = await openDatabase(
      path.join(folder, 'stuntguard_mpasi_favorites.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE mpasi_favorites (
            account_id TEXT NOT NULL,
            recipe_id TEXT NOT NULL,
            recipe_json TEXT NOT NULL,
            image_bytes BLOB,
            saved_at TEXT NOT NULL,
            PRIMARY KEY (account_id, recipe_id)
          )
        """);
        await db.execute(
          'CREATE INDEX idx_mpasi_favorite_date '
          'ON mpasi_favorites(account_id, saved_at DESC)',
        );
      },
    );
    _database = db;
    return db;
  }

  Future<String> _account() => _auth.localAccountId();

  Future<Set<String>> ids() async {
    final userId = await _account();
    final rows = await (await _db).query(
      'mpasi_favorites',
      columns: ['recipe_id'],
      where: 'account_id = ?',
      whereArgs: [userId],
    );
    return rows.map((r) => r['recipe_id'] as String).toSet();
  }

  Future<List<Mpasi>> list() async {
    final userId = await _account();
    final rows = await (await _db).query(
      'mpasi_favorites',
      where: 'account_id = ?',
      whereArgs: [userId],
      orderBy: 'saved_at DESC',
    );
    debugPrint(
      'MPASI favorit: ${rows.length} resep ditemukan untuk akun aktif.',
    );

    final recipes = <Mpasi>[];
    for (final row in rows) {
      try {
        final data = Map<String, dynamic>.from(
          jsonDecode(row['recipe_json'] as String) as Map,
        );
        recipes.add(
          Mpasi(
            id: (data['id'] ?? row['recipe_id']).toString(),
            nama: (data['nama'] ?? 'Resep MPASI').toString(),
            kategoriUsia: (data['kategoriUsia'] ?? '').toString(),
            waktuMenit: _asInt(data['waktuMenit']),
            jumlahPorsi: _asInt(data['jumlahPorsi']),
            gambarUrl: data['gambarUrl']?.toString(),
            gizi: _asStrings(data['gizi']),
            bahan: _asStrings(data['bahan']),
            langkah: _asStrings(data['langkah']),
          ),
        );
      } catch (error, stackTrace) {
        // Satu resep rusak tidak boleh membuat seluruh daftar terlihat kosong.
        debugPrint('MPASI favorit: gagal membaca salah satu resep: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
    if (rows.isNotEmpty && recipes.isEmpty) {
      throw const FormatException('Data resep tersimpan belum dapat dibaca.');
    }
    return recipes;
  }

  static int _asInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _asStrings(Object? value) {
    if (value is! List) return [];
    return value.map((item) => item.toString()).toList();
  }

  /// Menyimpan detail resep dan URL foto saja. Tidak mengunduh foto.
  /// Nilai bool dipertahankan untuk kompatibilitas pemanggil lama.
  Future<bool> save(Mpasi recipe) async {
    final userId = await _account();
    final data = jsonEncode({
      'id': recipe.id,
      'nama': recipe.nama,
      'kategoriUsia': recipe.kategoriUsia,
      'waktuMenit': recipe.waktuMenit,
      'jumlahPorsi': recipe.jumlahPorsi,
      'gambarUrl': recipe.gambarUrl,
      'gizi': recipe.gizi,
      'bahan': recipe.bahan,
      'langkah': recipe.langkah,
    });
    final db = await _db;
    await db.insert('mpasi_favorites', {
      'account_id': userId,
      'recipe_id': recipe.id,
      'recipe_json': data,
      'image_bytes': null,
      'saved_at': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    final result = await db.query(
      'mpasi_favorites',
      columns: ['recipe_id'],
      where: 'account_id = ? AND recipe_id = ?',
      whereArgs: [userId, recipe.id],
      limit: 1,
    );
    if (result.isEmpty) {
      throw StateError('Resep belum berhasil tercatat dalam penyimpanan.');
    }
    debugPrint('MPASI favorit: resep berhasil disimpan di SQLite.');
    return true;
  }

  Future<void> remove(String recipeId) async {
    final userId = await _account();
    await (await _db).delete(
      'mpasi_favorites',
      where: 'account_id = ? AND recipe_id = ?',
      whereArgs: [userId, recipeId],
    );
  }
}
