import 'package:sqflite/sqflite.dart';
import 'package:password_manager/features/vault/credential_model.dart';

class CredentialRepository {
  final Database _db;

  CredentialRepository(this._db);

  Future<void> insertCredential(Credential credential) async {
    await _db.insert(
      'demo',
      credential.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCredential(Credential credential) async {
    // Assuming Website is the PK and doesn't change on edit (which matches current app logic)
    await _db.update(
      'demo',
      credential.toMap(),
      where: 'Website = ?',
      whereArgs: [credential.website],
    );
  }
  
  Future<void> deleteCredential(String website) async {
      await _db.delete(
          'demo',
          where: 'Website = ?',
          whereArgs: [website]
      );
  }

  Future<List<Credential>> getCredentialsByCategory(String? category) async {
    List<Map<String, dynamic>> maps;
    
    if (category != null && category.isNotEmpty) {
      maps = await _db.query(
        'demo',
        where: 'category = ?',
        whereArgs: [category],
      );
    } else {
      maps = await _db.query('demo');
    }

    return List.generate(maps.length, (i) {
      return Credential.fromMap(maps[i]);
    });
  }
  
  Future<List<Credential>> getAllCredentials() async {
      return getCredentialsByCategory(null);
  }
}
