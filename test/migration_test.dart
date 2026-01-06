import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:password_manager/core/dbinit.dart';

// Mock PathProvider
class MockPathProviderPlatform extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  final String tmpPath;
  MockPathProviderPlatform(this.tmpPath);

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return tmpPath;
  }
  
  // Implement other required methods with simple mocks or throws if needed
  // Since we only expect getApplicationDocumentsDirectoryPath, others can throw UnimplementedError (default behavior of Fake)
}

void main() {
  late String tmpPath;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    
    // Mock Secure Storage
    FlutterSecureStorage.setMockInitialValues({'db_encryption_key': 'dummy_key'});
  });

  setUp(() async {
    // Create a temp directory for each test
    final directory = await Directory.systemTemp.createTemp('migration_test_');
    tmpPath = directory.path;
    
    PathProviderPlatform.instance = MockPathProviderPlatform(tmpPath);
  });

  tearDown(() async {
    // Cleanup
    if (await Directory(tmpPath).exists()) {
        await Directory(tmpPath).delete(recursive: true);
    }
  });

  test('InitDB migrates to version 2 and adds category column', () async {
    final dbPath = join(tmpPath, '.pass.db');
    
    // 1. Manually create a V1 database
    var db = await openDatabase(dbPath, version: 1, 
      onConfigure: (db) async {
        await db.execute("PRAGMA key = 'dummy_key'");
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE demo (
            Website TEXT PRIMARY KEY,
            Username TEXT,
            Email TEXT,
            Password TEXT
          )
        ''');
      }
    );
    
    await db.insert('demo', {
      'Website': 'test.com',
      'Username': 'user',
      'Email': 'user@example.com',
      'Password': 'password'
    });
    
    await db.close();
    
    // 2. Initialize InitDB (which should trigger migration when we implement it)
    final database = await InitDB().initDB();
    
    // 3. Verify schema
    try {
        final result = await database.rawQuery("SELECT category FROM demo LIMIT 1");
        // If we get here, the column exists
    } catch (e) {
        fail('Column category does not exist: $e');
    }
    
    // Also verify data is still there
    final rows = await database.query('demo');
    expect(rows.length, 1);
    expect(rows.first['Website'], 'test.com');
    
    await database.close();
  });
}
