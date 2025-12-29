import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:password_manager/gmail_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late GmailService gmailService;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    GmailService.reset();
    mockStorage = MockFlutterSecureStorage();
    gmailService = GmailService(storage: mockStorage);
    
    when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
  });

  group('GmailService OAuth', () {
    test('authenticate requests offline access and consent prompt', () async {
      Uri? capturedUrl;
      
      // We don't want it to actually start a server or launch a browser
      // So we'll trigger a timeout or mock the launcher if possible.
      // But we just want to see the URL.
      
      try {
        await gmailService.authenticate(
          'client-id',
          'client-secret',
          onUrlLaunched: (url) {
            capturedUrl = url;
            // Throw to stop the rest of the method (server startup etc)
            throw Exception('URL captured');
          },
        );
      } catch (e) {
        if (e.toString() != 'Exception: URL captured') rethrow;
      }

      expect(capturedUrl, isNotNull);
      expect(capturedUrl!.queryParameters['access_type'], equals('offline'));
      expect(capturedUrl!.queryParameters['prompt'], equals('consent'));
    });
  });
}
