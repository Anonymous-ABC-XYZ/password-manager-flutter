import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:password_manager/gmail_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'dart:convert';
import 'package:googleapis/gmail/v1.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockOAuth2Client extends Mock implements oauth2.Client {}
class MockOAuth2Credentials extends Mock implements oauth2.Credentials {}

void main() {
  late GmailService gmailService;
  late MockFlutterSecureStorage mockStorage;
  late MockOAuth2Client mockClient;
  late MockOAuth2Credentials mockCredentials;

  setUp(() {
    GmailService.reset();
    mockStorage = MockFlutterSecureStorage();
    gmailService = GmailService(storage: mockStorage);
    mockClient = MockOAuth2Client();
    mockCredentials = MockOAuth2Credentials();
    
    when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    when(() => mockClient.credentials).thenReturn(mockCredentials);
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

  group('GmailService Silent Refresh', () {
    test('signIn performs silent refresh if credentials are expired', () async {
      final expiredCreds = {
        'accessToken': 'old-token',
        'refreshToken': 'refresh-token',
        'idToken': null,
        'tokenEndpoint': 'https://oauth2.googleapis.com/token',
        'scopes': ['https://www.googleapis.com/auth/gmail.readonly'],
        'expiration': DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
      };

      when(() => mockStorage.read(key: 'google_credentials_v2'))
          .thenAnswer((_) async => json.encode(json.encode(expiredCreds)));
      when(() => mockStorage.read(key: 'google_client_id'))
          .thenAnswer((_) async => 'client-id');
      when(() => mockStorage.read(key: 'google_client_secret'))
          .thenAnswer((_) async => 'client-secret');
      
      final mockNewClient = MockOAuth2Client();
      final mockNewCredentials = MockOAuth2Credentials();
      when(() => mockNewCredentials.toJson()).thenReturn(json.encode({'accessToken': 'new-token'}));
      when(() => mockCredentials.toJson()).thenReturn(json.encode({'accessToken': 'old-token'}));
      when(() => mockNewClient.credentials).thenReturn(mockNewCredentials);
      
      when(() => mockCredentials.isExpired).thenReturn(true);
      when(() => mockClient.refreshCredentials()).thenAnswer((_) async => mockNewClient);

      final result = await gmailService.signIn(
        clientFactory: (creds, id, secret) => mockClient,
      );
      
      expect(result, isTrue);
      verify(() => mockClient.refreshCredentials()).called(1);
      verify(() => mockStorage.write(key: 'google_credentials_v2', value: any(named: 'value'))).called(1);
    });
  });
}
