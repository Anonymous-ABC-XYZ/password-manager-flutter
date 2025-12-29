import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:password_manager/providers/auth_provider.dart';
import 'package:password_manager/gmail_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockGmailService extends Mock implements GmailService {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AuthProvider authProvider;
  late MockGmailService mockGmailService;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockGmailService = MockGmailService();
    mockStorage = MockFlutterSecureStorage();
    
    // Default mocks to avoid errors during initialization
    when(() => mockGmailService.isSignedIn).thenAnswer((_) async => false);
    when(() => mockStorage.read(key: any(named: 'key'))).thenAnswer((_) async => null);
    when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    when(() => mockStorage.delete(key: any(named: 'key'))).thenAnswer((_) async {});
  });

  group('Session Expiration', () {
    test('session expires if more than 30 days passed since initial login', () async {
      final initialLogin = DateTime.now().subtract(const Duration(days: 31));
      
      when(() => mockStorage.read(key: 'google_initial_login_time'))
          .thenAnswer((_) async => initialLogin.toIso8601String());
      when(() => mockStorage.read(key: 'token_last_refresh'))
          .thenAnswer((_) async => initialLogin.toIso8601String());
      when(() => mockGmailService.isSignedIn).thenAnswer((_) async => true);
      when(() => mockGmailService.signOut()).thenAnswer((_) async {});

      authProvider = AuthProvider(
        gmailService: mockGmailService,
        storage: mockStorage,
      );

      // Wait for initialization
      await Future.delayed(Duration(milliseconds: 100));

      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, contains('expired'));
    });

    test('session remains valid if less than 30 days passed since initial login', () async {
      final initialLogin = DateTime.now().subtract(const Duration(days: 29));
      
      when(() => mockStorage.read(key: 'google_initial_login_time'))
          .thenAnswer((_) async => initialLogin.toIso8601String());
      when(() => mockStorage.read(key: 'token_last_refresh'))
          .thenAnswer((_) async => initialLogin.toIso8601String());
      when(() => mockGmailService.isSignedIn).thenAnswer((_) async => true);
      when(() => mockGmailService.signIn()).thenAnswer((_) async => true);

      authProvider = AuthProvider(
        gmailService: mockGmailService,
        storage: mockStorage,
      );

      await Future.delayed(Duration(milliseconds: 100));

      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.isSessionExpired, isFalse);
    });
  });
}
