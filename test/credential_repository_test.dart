import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:password_manager/credential_repository.dart';
import 'package:password_manager/credential_model.dart';

void main() {
  late Database db;
  late CredentialRepository repo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await openDatabase(inMemoryDatabasePath, version: 2, onCreate: (db, version) async {
       await db.execute('''
      CREATE TABLE demo (
        Website TEXT PRIMARY KEY,
        Username TEXT,
        Email TEXT,
        Password TEXT,
        category TEXT
      )
    ''');
    });
    repo = CredentialRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('insertCredential saves category', () async {
    final cred = Credential(
      website: 'site.com',
      username: 'user',
      email: 'email',
      password: 'pass',
      category: 'Work',
    );
    await repo.insertCredential(cred);

    final result = await db.query('demo');
    expect(result.first['category'], 'Work');
  });

  test('updateCredential updates category', () async {
    await db.insert('demo', {
      'Website': 'site.com',
      'Username': 'u',
      'Email': 'e',
      'Password': 'p',
      'category': 'Old'
    });

    final cred = Credential(
      website: 'site.com',
      username: 'u',
      email: 'e',
      password: 'p',
      category: 'New',
    );
    
    await repo.updateCredential(cred);
    
    final result = await db.query('demo');
    expect(result.first['category'], 'New');
  });
  
  test('getCredentialsByCategory filters correctly', () async {
      await db.insert('demo', {'Website': '1', 'Username':'u', 'Email':'e', 'Password':'p', 'category': 'Work'});
      await db.insert('demo', {'Website': '2', 'Username':'u', 'Email':'e', 'Password':'p', 'category': 'Personal'});
      
      final work = await repo.getCredentialsByCategory('Work');
      expect(work.length, 1);
      expect(work.first.website, '1');
      
      final all = await repo.getCredentialsByCategory(null); // All
      expect(all.length, 2);
  });
}
