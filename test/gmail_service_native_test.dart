import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:password_manager/features/auth/gmail_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class MockGoogleSignInAuthorizationClient extends Mock implements GoogleSignInAuthorizationClient {}
class MockGoogleSignInClientAuthorization extends Mock implements GoogleSignInClientAuthorization {}
class MockAuthClient extends Mock implements gapis.AuthClient {}

void main() {
  late GmailService gmailService;
  late MockFlutterSecureStorage mockStorage;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockAccount;
  late MockGoogleSignInAuthorizationClient mockAuthzClient;
  late MockGoogleSignInClientAuthorization mockAuthz;

  setUp(() {
    GmailService.reset();
    mockStorage = MockFlutterSecureStorage();
    mockGoogleSignIn = MockGoogleSignIn();
    mockAccount = MockGoogleSignInAccount();
    mockAuthzClient = MockGoogleSignInAuthorizationClient();
    mockAuthz = MockGoogleSignInClientAuthorization();
    
    gmailService = GmailService(storage: mockStorage, googleSignIn: mockGoogleSignIn);

    when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    
    when(() => mockAccount.authorizationClient).thenReturn(mockAuthzClient);
  });

  group('GmailService Native Auth', () {
    test('authenticateNative returns true on successful sign in', () async {
      when(() => mockGoogleSignIn.authenticate(scopeHint: any(named: 'scopeHint')))
          .thenAnswer((_) async => mockAccount);
      when(() => mockAuthzClient.authorizeScopes(any()))
          .thenAnswer((_) async => mockAuthz);
      when(() => mockAuthz.accessToken).thenReturn('test-token');
      
      final result = await gmailService.authenticateNative();
      
      expect(result, isTrue);
      verify(() => mockGoogleSignIn.authenticate(scopeHint: any(named: 'scopeHint'))).called(1);
    });

    test('authenticateNative returns false when authentication fails', () async {
      when(() => mockGoogleSignIn.authenticate(scopeHint: any(named: 'scopeHint')))
          .thenThrow(Exception('Auth failed'));
      
      final result = await gmailService.authenticateNative();
      
      expect(result, isFalse);
    });

    test('signInSilently returns true on successful silent sign in', () async {
      when(() => mockGoogleSignIn.attemptLightweightAuthentication())
          .thenAnswer((_) => Future.value(mockAccount));
      when(() => mockAuthzClient.authorizationForScopes(any()))
          .thenAnswer((_) async => mockAuthz);
      when(() => mockAuthz.accessToken).thenReturn('test-token');
      
      final result = await gmailService.signInSilently();
      
      expect(result, isTrue);
      verify(() => mockGoogleSignIn.attemptLightweightAuthentication()).called(1);
    });
  });
}