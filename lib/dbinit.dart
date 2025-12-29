import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'security_helper.dart';

class InitDB {
  static final InitDB _instance = InitDB._internal();

  factory InitDB() => _instance;

  InitDB._internal();

  Database? _database;

  Future<Database> get dB async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, '.pass.db');
    final key = await SecurityHelper.getEncryptionKey();

    if (await File(path).exists()) {
      try {
        return await _openEncryptedDatabase(path, key);
      } catch (e) {
        print('Encryption check failed, attempting migration... ($e)');
        await _migrateToEncrypted(path, key);
        return await _openEncryptedDatabase(path, key);
      }
    }

    return await _openEncryptedDatabase(path, key);
  }

  Future<Database> _openEncryptedDatabase(String path, String key) async {
    return await openDatabase(
      path,
      version: 2,
      // IMPORTANT: sqflite_common_ffi + sqlcipher doesn't use the 'password' parameter
      // We must use onConfigure to set the key via PRAGMA
      onConfigure: (db) async {
        await db.execute("PRAGMA key = '$key'");
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE demo (
        Website TEXT PRIMARY KEY,
        Username TEXT,
        Email TEXT,
        Password TEXT,
        category TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE demo ADD COLUMN category TEXT");
    }
  }

  Future<void> _migrateToEncrypted(String path, String key) async {
    Database? plainDb;
    try {
      // 1. Open plain text (no PRAGMA key)
      plainDb = await openDatabase(path, version: 1); // No onConfigure

      // 2. Fetch data
      final tables = await plainDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='demo'",
      );
      if (tables.isEmpty) {
        await plainDb.close();
        return;
      }
      final List<Map<String, dynamic>> data = await plainDb.query('demo');
      await plainDb.close();

      // 3. Delete plain file
      await File(path).delete();

      // 4. Create encrypted DB
      final encryptedDb = await _openEncryptedDatabase(path, key);

      // 5. Insert data
      final batch = encryptedDb.batch();
      for (var row in data) {
        batch.insert('demo', row);
      }
      await batch.commit();
      await encryptedDb.close();

      print('Migration to encrypted database completed successfully.');
    } catch (e) {
      print('Migration failed: $e');
      if (plainDb != null && plainDb.isOpen) await plainDb.close();
      rethrow;
    }
  }
}
