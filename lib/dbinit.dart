import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class InitDB {
  static final InitDB _instance = InitDB._internal();

  factory InitDB() => _instance;

  InitDB._internal();

  Database? _database;

  Future get dB async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  Future initDB() async {
    final directory = await getApplicationDocumentsDirectory();
    String dirString = directory.toString();
    String newdirString = dirString
        .replaceAll("Directory", "")
        .replaceAll("'", "")
        .replaceAll(":", "")
        .replaceAll(" ", "");

    var path = "$newdirString/.pass.db";

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE demo (
            Website TEXT PRIMARY KEY,
            Username TEXT,
            Email TEXT,
            Password TEXT
          )
        ''');
      },
    );
  }
}
