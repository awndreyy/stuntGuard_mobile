import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/mandiri_record.dart';
import 'auth_service.dart';

class MandiriHistoryService {
  static Database? _database;
  final AuthService _auth = AuthService();

  Future<Database> get _db async {
    if (_database != null && _database!.isOpen) return _database!;
    final directory = await getDatabasesPath();
    _database = await openDatabase(
      path.join(directory, 'stuntguard_mandiri.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE mandiri_checks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            account_id TEXT NOT NULL,
            child_id TEXT NOT NULL,
            child_name TEXT NOT NULL,
            gender TEXT NOT NULL,
            measured_at TEXT NOT NULL,
            weight REAL NOT NULL,
            height REAL NOT NULL,
            body_position TEXT NOT NULL,
            head_circumference REAL,
            lila REAL,
            result_json TEXT NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_mandiri_account_date '
          'ON mandiri_checks(account_id, measured_at DESC)',
        );
      },
    );
    return _database!;
  }

  Future<int> save(MandiriRecord record) async {
    final accountId = await _auth.localAccountId();
    if (record.accountId != accountId) {
      throw Exception('Catatan tidak sesuai dengan akun yang aktif.');
    }
    final db = await _db;
    return db.insert('mandiri_checks', record.toDatabase());
  }

  Future<String> accountId() => _auth.localAccountId();

  Future<List<MandiriRecord>> list({String? childId}) async {
    final accountId = await _auth.localAccountId();
    final db = await _db;
    final rows = await db.query(
      'mandiri_checks',
      where: childId == null
          ? 'account_id = ?'
          : 'account_id = ? AND child_id = ?',
      whereArgs: childId == null ? [accountId] : [accountId, childId],
      orderBy: 'measured_at DESC, id DESC',
    );
    return rows.map(MandiriRecord.fromDatabase).toList();
  }

  Future<void> delete(int id) async {
    final accountId = await _auth.localAccountId();
    final db = await _db;
    await db.delete(
      'mandiri_checks',
      where: 'id = ? AND account_id = ?',
      whereArgs: [id, accountId],
    );
  }
}
