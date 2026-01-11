import 'package:googleapis/gmail/v1.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:meta/meta.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

class GmailService {
  final FlutterSecureStorage _storage;
  GoogleSignIn _googleSignIn;

  // Singleton pattern
  static GmailService? _instance;

  factory GmailService({
    FlutterSecureStorage? storage,
    GoogleSignIn? googleSignIn,
  }) {
    _instance ??= GmailService._internal(
      storage: storage ?? const FlutterSecureStorage(),
      googleSignIn: googleSignIn ??
          GoogleSignIn.standard(
            scopes: _scopes,
          ),
    );
    return _instance!;
  }

  @visibleForTesting
  static void reset() {
    _instance = null;
  }

  GmailService._internal({
    required FlutterSecureStorage storage,
    required GoogleSignIn googleSignIn,
  })  : _storage = storage,
        _googleSignIn = googleSignIn;

  static const _scopes = ['https://www.googleapis.com/auth/gmail.readonly'];
  static final _authorizationEndpoint = Uri.parse(
    'https://accounts.google.com/o/oauth2/v2/auth',
  );
  static final _tokenEndpoint = Uri.parse(
    'https://oauth2.googleapis.com/token',
  );

  http.Client? _authenticatedClient;
  GmailApi? _gmailApi;

  @visibleForTesting
  set authenticatedClient(http.Client? client) {
    _authenticatedClient = client;
    if (client != null) {
      _gmailApi = GmailApi(client);
    }
  }

  Future<void> initializeNative({String? clientId, String? serverClientId}) async {
    await _googleSignIn.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );
  }

  Future<bool> signIn({
    oauth2.Client? Function(oauth2.Credentials, String, String)? clientFactory,
  }) async {
    try {
      final storedCredentials = await _storage.read(
        key: 'google_credentials_v2',
      );
      if (storedCredentials != null) {
        try {
          final credMap = json.decode(storedCredentials);
          final credentials = oauth2.Credentials.fromJson(credMap);

          final clientCreds = await _getClientCreds();
          if (clientCreds == null) {
            print(
              'GmailService.signIn: Client credentials not found in storage.',
            );
            return false;
          }

          oauth2.Client client;
          if (clientFactory != null) {
            client = clientFactory(
              credentials,
              clientCreds['id']!,
              clientCreds['secret']!,
            )!;
          } else {
            client = oauth2.Client(
              credentials,
              identifier: clientCreds['id'],
              secret: clientCreds['secret'],
            );
          }

          if (client.credentials.isExpired) {
            print('GmailService.signIn: Credentials expired, refreshing...');
            try {
              client = await client.refreshCredentials();
              await _saveCredentials(client.credentials);
              print('GmailService.signIn: Refresh successful.');
            } catch (e) {
              print('GmailService.signIn: Failed to refresh credentials: $e');
              if (e is oauth2.AuthorizationException) {
                print('GmailService.signIn: Deleting invalid credentials.');
                await _storage.delete(key: 'google_credentials_v2');
              }
              return false;
            }
          }

          _authenticatedClient = client;
          _gmailApi = GmailApi(client);
          return true;
        } catch (e) {
          print('GmailService.signIn: Error loading credentials: $e');
          if (e is FormatException || e is TypeError) {
            await _storage.delete(key: 'google_credentials_v2');
          }
        }
      }

      return false;
    } catch (e) {
      print('GmailService.signIn: Unexpected error: $e');
      return false;
    }
  }

  Future<bool> authenticate(
    String clientId,
    String clientSecret,
  {
    Function(Uri)? onUrlLaunched,
  }) async {
    try {
      print('Starting authentication flow...');

      final grant = oauth2.AuthorizationCodeGrant(
        clientId,
        _authorizationEndpoint,
        _tokenEndpoint,
        secret: clientSecret,
      );

      final baseAuthorizationUrl = grant.getAuthorizationUrl(
        Uri.parse('http://localhost:8080'),
        scopes: _scopes,
      );

      final authorizationUrl = baseAuthorizationUrl.replace(
        queryParameters: {
          ...baseAuthorizationUrl.queryParameters,
          'access_type': 'offline',
          'prompt': 'consent',
        },
      );

      print('Authorization URL: $authorizationUrl');

      if (onUrlLaunched != null) {
        onUrlLaunched(authorizationUrl);
      }

      final responseCompleter = Completer<Uri>();

      print('Starting callback server on localhost:8080...');
      await _startCallbackServer(responseCompleter);

      print('Launching browser...');
      final launched = await launchUrl(
        authorizationUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        print('Failed to launch browser');
        return false;
      }

      print('Waiting for OAuth callback...');
      final responseUri = await responseCompleter.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          print('Authentication timeout after 5 minutes');
          throw TimeoutException('Authentication timeout');
        },
      );

      final client = await grant.handleAuthorizationResponse(
        responseUri.queryParameters,
      );

      await setClientCredentials(clientId, clientSecret);
      await _saveCredentials(client.credentials);

      _authenticatedClient = client;
      _gmailApi = GmailApi(client);

      print('Authentication complete!');
      return true;
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }

  Future<void> _startCallbackServer(Completer<Uri> completer) async {
    final server = await HttpServer.bind('localhost', 8080);

    server.listen((request) async {
      final uri = request.uri;

      final htmlContent = '''
<!DOCTYPE html>
<html>
  <head>
    <title>Authentication Successful</title>
    <meta charset="UTF-8">
    <style>
      body {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        margin: 0;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      }
      .container {
        background: white;
        padding: 3rem;
        border-radius: 12px;
        box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        text-align: center;
        max-width: 400px;
      }
      .checkmark {
        font-size: 64px;
        color: #4CAF50;
        margin-bottom: 1rem;
      }
      h1 {
        color: #333;
        margin: 0 0 1rem 0;
      }
      p {
        color: #666;
        margin: 0;
      }
    </style>
    <script>
      setTimeout(function() {
        window.close();
      }, 2000);
    </script>
  </head>
  <body>
    <div class="container">
      <div class="checkmark">&#10004;</div>
      <h1>Authentication Successful!</h1>
      <p>You can now close this window and return to the app.</p>
    </div>
  </body>
</html>
''';

      request.response
        ..statusCode = 200
        ..headers.set('Content-Type', 'text/html; charset=utf-8')
        ..write(htmlContent);
      await request.response.close();

      if (!completer.isCompleted) {
        completer.complete(uri);
      }
      await server.close();
    });
  }

  Future<void> _saveCredentials(oauth2.Credentials credentials) async {
    await _storage.write(
      key: 'google_credentials_v2',
      value: json.encode(credentials.toJson()),
    );
  }

  Future<Map<String, String>?> _getClientCreds() async {
    final storedClientId = await _storage.read(key: 'google_client_id');
    final storedClientSecret = await _storage.read(key: 'google_client_secret');

    if (storedClientId != null && storedClientSecret != null) {
      return {'id': storedClientId, 'secret': storedClientSecret};
    }

    return null;
  }

  Future<void> setClientCredentials(
    String clientId,
    String clientSecret,
  ) async {
    await _storage.write(key: 'google_client_id', value: clientId);
    await _storage.write(key: 'google_client_secret', value: clientSecret);
  }

  Future<String?> fetchOTPFromGmail() async {
    print('fetchOTPFromGmail: Starting OTP fetch...');

    if (_gmailApi == null) {
      print(
        'fetchOTPFromGmail: Gmail API not initialized, attempting sign in...', 
      );
      final signedIn = await signIn();
      if (!signedIn) {
        print('fetchOTPFromGmail: Sign in failed');
        throw Exception('Not signed in to Gmail. Please authenticate first.');
      }
      print('fetchOTPFromGmail: Successfully signed in');
    }

    try {
      print('fetchOTPFromGmail: Fetching messages from Gmail...');
      final messagesResponse = await _gmailApi!.users.messages.list(
        'me',
        q: 'is:unread newer_than:1d',
        maxResults: 10,
      );

      if (messagesResponse.messages == null ||
          messagesResponse.messages!.isEmpty) {
        print('fetchOTPFromGmail: No unread messages found in last 24 hours');
        return null;
      }

      print(
        'fetchOTPFromGmail: Found ${messagesResponse.messages!.length} messages',
      );

      for (int i = 0; i < messagesResponse.messages!.length; i++) {
        final message = messagesResponse.messages![i];
        print(
          'fetchOTPFromGmail: Processing message ${i + 1}/${messagesResponse.messages!.length}...',
        );

        final fullMessage = await _gmailApi!.users.messages.get(
          'me',
          message.id!,
          format: 'full',
        );

        final snippet = fullMessage.snippet ?? '';
        final subject = _extractSubject(fullMessage);
        final body = _extractBody(fullMessage);

        print('fetchOTPFromGmail: Message ${i + 1} - Subject: $subject');
        print(
          'fetchOTPFromGmail: Message ${i + 1} - Snippet: ${snippet.length > 100 ? snippet.substring(0, 100) : snippet}',
        );
        print(
          'fetchOTPFromGmail: Message ${i + 1} - Body length: ${body.length}',
        );

        final textToSearch = '$subject $snippet $body';
        final otp = _extractOTP(textToSearch);

        if (otp != null) {
          print('fetchOTPFromGmail: Found OTP: $otp');
          return otp;
        }
        print('fetchOTPFromGmail: No OTP found in message ${i + 1}');
      }

      print('fetchOTPFromGmail: No OTP found in any message');
      return null;
    } catch (e, stackTrace) {
      print('fetchOTPFromGmail: Error occurred: $e');
      print('fetchOTPFromGmail: Stack trace: $stackTrace');

      // Check for specific Gmail API not enabled error
      if (e.toString().contains('Gmail API has not been used') ||
          e.toString().contains('it is disabled')) {
        throw Exception(
          'Gmail API is not enabled in your Google Cloud project.\n\n' 
          'Please visit: https://console.developers.google.com/apis/api/gmail.googleapis.com/overview\n' 
          'and enable the Gmail API for your project.',
        );
      }

      throw Exception('Failed to fetch emails from Gmail: $e');
    }
  }

  String _extractSubject(Message message) {
    if (message.payload?.headers == null) {
      return '';
    }

    for (final header in message.payload!.headers!) {
      if (header.name?.toLowerCase() == 'subject') {
        return header.value ?? '';
      }
    }

    return '';
  }

  String _extractBody(Message message) {
    String bodyData = '';

    // Try to get body from the main message
    if (message.payload?.body?.data != null &&
        message.payload!.body!.data!.isNotEmpty) {
      bodyData = message.payload!.body!.data!;
    }

    // If not found, look in parts
    if (bodyData.isEmpty && message.payload?.parts != null) {
      for (final part in message.payload!.parts!) {
        // Try text/plain first
        if (part.mimeType == 'text/plain' && part.body?.data != null) {
          bodyData = part.body!.data!;
          break;
        }
        // Fall back to text/html
        if (bodyData.isEmpty &&
            part.mimeType == 'text/html' &&
            part.body?.data != null) {
          bodyData = part.body!.data!;
        }
        // Check nested parts (for multipart/alternative)
        if (bodyData.isEmpty && part.parts != null) {
          for (final nestedPart in part.parts!) {
            if (nestedPart.mimeType == 'text/plain' &&
                nestedPart.body?.data != null) {
              bodyData = nestedPart.body!.data!;
              break;
            }
            if (bodyData.isEmpty &&
                nestedPart.mimeType == 'text/html' &&
                nestedPart.body?.data != null) {
              bodyData = nestedPart.body!.data!;
            }
          }
        }
      }
    }

    if (bodyData.isEmpty) {
      return '';
    }

    try {
      final normalized = bodyData.replaceAll('-', '+').replaceAll('_', '/');
      final padding = (4 - normalized.length % 4) % 4;
      final padded = normalized + ('=' * padding);
      final decoded = utf8.decode(base64.decode(padded));
      return decoded;
    } catch (e) {
      print('_extractBody: Failed to decode body: $e');
      return bodyData; // Return raw data if decoding fails
    }
  }

  String? _extractOTP(String text) {
    print(
      '_extractOTP: Searching for OTP in text (first 200 chars): ${text.length > 200 ? text.substring(0, 200) : text}',
    );

    final patterns = [
      RegExp(
        r'(?:code|otp|verification|verify|pin|token)[\s:]+(\d{4,8})',
        caseSensitive: false,
      ),
      RegExp(
        r'(\d{4,8})[\s]+is your (?:code|otp|verification|pin)',
        caseSensitive: false,
      ),
      RegExp(
        r'your (?:code|otp|verification|pin)[\s:]+(\d{4,8})',
        caseSensitive: false,
      ),
      RegExp(r'\b(\d{8})\b'), // 8 digits
      RegExp(r'\b(\d{7})\b'), // 7 digits
      RegExp(r'\b(\d{6})\b'), // 6 digits
      RegExp(r'\b(\d{5})\b'), // 5 digits
      RegExp(r'\b(\d{4})\b'), // 4 digits
    ];

    for (int i = 0; i < patterns.length; i++) {
      final pattern = patterns[i];
      final match = pattern.firstMatch(text);
      if (match != null) {
        final otp = match.group(1);
        print('OTP: "$otp" with pattern ${i + 1}');
        return otp;
      }
    }

    print('_extractOTP: No OTP pattern matched');
    return null;
  }

  Future<void> signOut() async {
    await _storage.delete(key: 'google_credentials_v2');
    await _googleSignIn.signOut();
    _authenticatedClient?.close();
    _authenticatedClient = null;
    _gmailApi = null;
  }

  Future<bool> authenticateNative({String? serverClientId}) async {
    try {
      if (serverClientId != null) {
        // Re-initialize with serverClientId if provided
        _googleSignIn = GoogleSignIn(
          serverClientId: serverClientId,
          scopes: _scopes,
        );
      }

      final account = await _googleSignIn.signIn();
      if (account == null) return false;

      final authClient = await account.authenticatedClient();
      if (authClient == null) return false;

      _authenticatedClient = authClient;
      _gmailApi = GmailApi(authClient);
      return true;
    } catch (e) {
      print('Native authentication error: $e');
      return false;
    }
  }

  Future<bool> signInSilently() async {
    try {
      final accountFuture = _googleSignIn.attemptLightweightAuthentication();
      if (accountFuture == null) return false;
      
      final account = await accountFuture;
      if (account == null) return false;

      final auth = await account.authorizationClient.authorizationForScopes(_scopes);
      if (auth == null) return false;
      
      final authClient = auth.authClient(scopes: _scopes);

      _authenticatedClient = authClient;
      _gmailApi = GmailApi(authClient);
      return true;
    } catch (e) {
      print('Silent sign-in error: $e');
      return false;
    }
  }

  Future<bool> get isSignedIn async {
    final storedCredentials = await _storage.read(key: 'google_credentials_v2');
    if (storedCredentials != null) return true;
    // We don't have a direct sync way to check if signed in with new API without calling methods.
    // But we can check if a previous lightweight attempt might succeed or just rely on storage/events.
    // For now, let's just return true if we have an authenticated client.
    return _authenticatedClient != null;
  }
}
