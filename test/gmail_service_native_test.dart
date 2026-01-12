import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:password_manager/features/auth/gmail_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockGoogleSignIn extends Mock implements gsi.GoogleSignIn {}
class MockGoogleSignInAccount extends Mock implements gsi.GoogleSignInAccount {}

void main() {
  late GmailService gmailService;
  late MockFlutterSecureStorage mockStorage;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockAccount;

  setUp(() {
    GmailService.reset();
    mockStorage = MockFlutterSecureStorage();
    mockGoogleSignIn = MockGoogleSignIn();
    mockAccount = MockGoogleSignInAccount();
    
    gmailService = GmailService(storage: mockStorage, googleSignIn: mockGoogleSignIn);

    when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    
    // Mock properties required for authenticatedClient extension
    when(() => mockGoogleSignIn.currentUser).thenReturn(mockAccount);
    when(() => mockAccount.authHeaders).thenAnswer((_) async => {'Authorization': 'Bearer token'});
  });

  group('GmailService Native Auth', () {
    test('authenticateNative returns true on successful sign in', () async {
      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
      
      final result = await gmailService.authenticateNative();
      
      expect(result, isTrue);
      verify(() => mockGoogleSignIn.signIn()).called(1);
    });

    test('authenticateNative returns false when authentication fails', () async {
      when(() => mockGoogleSignIn.signIn()).thenThrow(Exception('Auth failed'));
      
      final result = await gmailService.authenticateNative();
      
      expect(result, isFalse);
    });

    test('signInSilently returns true on successful silent sign in', () async {
      when(() => mockGoogleSignIn.signInSilently()).thenAnswer((_) async => mockAccount);
      
      final result = await gmailService.signInSilently();
      
      expect(result, isTrue);
      verify(() => mockGoogleSignIn.signInSilently()).called(1);
    });
  });
}
