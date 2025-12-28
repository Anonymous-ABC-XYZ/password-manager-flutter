import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityHelper {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'db_encryption_key';

  static Future<String> getEncryptionKey() async {
    String? key = await _storage.read(key: _keyName);

    if (key == null) {
      key = _generateRandomKey();
      await _storage.write(key: _keyName, value: key);
    }

    return key;
  }

  static String _generateRandomKey() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }
}
