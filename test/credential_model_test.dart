import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/credential_model.dart';

void main() {
  test('Credential model supports category', () {
    final credential = Credential(
      website: 'example.com',
      username: 'user',
      email: 'user@example.com',
      password: 'password',
      category: 'Work',
    );

    expect(credential.category, 'Work');
    
    final map = credential.toMap();
    expect(map['category'], 'Work');
    
    final fromMap = Credential.fromMap(map);
    expect(fromMap.category, 'Work');
  });
  
  test('Credential model defaults category to null if missing', () {
      final map = {
          'Website': 'example.com',
          'Username': 'user',
          'Email': 'email',
          'Password': 'pass',
      };
      final cred = Credential.fromMap(map);
      expect(cred.category, null);
  });
}
