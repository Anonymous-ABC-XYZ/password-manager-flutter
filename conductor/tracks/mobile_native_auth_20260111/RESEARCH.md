# Research: Mobile Native Gmail Sign-In

## 1. Selected Packages

### [google_sign_in](https://pub.dev/packages/google_sign_in)
- **Status:** Official Flutter plugin.
- **Capabilities:** Supports native pop-up for account selection on Android and iOS.
- **Platform Support:** Android, iOS, macOS, Web (Windows/Linux via community support or fallback).

### [extension_google_sign_in_as_googleapis_auth](https://pub.dev/packages/extension_google_sign_in_as_googleapis_auth)
- **Status:** Official bridge package.
- **Purpose:** Converts a `GoogleSignInAccount` into a `googleapis_auth.AuthClient`.
- **Why it matters:** The current codebase uses `googleapis_auth` for Gmail API interactions. This bridge allows a seamless transition from native sign-in to existing API logic.

## 2. Alternatives Considered

### [flutter_appauth](https://pub.dev/packages/flutter_appauth)
- **Pros:** Uses the AppAuth SDK (industry standard for OAuth2 on mobile). More flexible for custom providers.
- **Cons:** More complex configuration than `google_sign_in`. `google_sign_in` is optimized specifically for Google and provides the account-selection pop-up more natively.

### [google_sign_in_all_platforms](https://pub.dev/packages/google_sign_in_all_platforms)
- **Pros:** Unifies mobile and desktop (including Linux).
- **Cons:** Might not be as robust or well-maintained as the official plugin for mobile-specific features.

## 3. Scopes Handling
The Gmail API requires specific scopes. The `google_sign_in` plugin allows specifying scopes during initialization:

```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'https://www.googleapis.com/auth/gmail.readonly',
  ],
);
```

## 4. Integration with `googleapis_auth` & `GmailService`

### Current Implementation
The existing `GmailService` in `lib/features/auth/gmail_service.dart`:
- Uses `oauth2.AuthorizationCodeGrant` for the browser flow.
- Manually starts a localhost server to catch the callback.
- Stores `oauth2.Credentials` in `FlutterSecureStorage`.
- Initializes `GmailApi` with an `oauth2.Client`.

### Proposed Integration
Using `google_sign_in`, the `GmailService` can be refactored as follows:

1.  **Dependency Change:** Add `google_sign_in` and `extension_google_sign_in_as_googleapis_auth`.
2.  **Authentication Flow:**
    ```dart
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['https://www.googleapis.com/auth/gmail.readonly'],
    );

    Future<bool> authenticateNative() async {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return false;

      final authClient = await account.authenticatedClient();
      if (authClient == null) return false;

      _gmailApi = GmailApi(authClient);
      
      // PERSISTENCE:
      // google_sign_in persists the session natively. 
      // We can use _googleSignIn.signInSilently() on app startup to restore.
      return true;
    }
    ```
3.  **Compatibility:** Since `GmailApi` takes an `http.Client`, the `authClient` returned by the extension package is perfectly compatible.

### Persistent Storage Migration
- **Current:** `google_credentials_v2` key in secure storage.
- **Native:** `google_sign_in` manages its own persistence.
- **Recommendation:** During transition, we should decide if we want to store the `oauth2.Credentials` obtained from the native flow into our current secure storage key to maintain a "unified" way of checking `isSignedIn`. However, `google_sign_in` is generally more reliable for managing Google sessions on mobile.


## 5. Scope Verification & Consent Screen

### Requesting Scopes
When using `google_sign_in`, the required scopes must be passed to the constructor. For this project:
- `https://www.googleapis.com/auth/gmail.readonly`

### User Experience
On mobile, calling `_googleSignIn.signIn()` will:
1.  Show a native system dialog listing accounts signed in on the device.
2.  After account selection, if it's the first time or if scopes have changed, it will show the **Google OAuth Consent Screen**.
3.  The user must explicitly grant permission for the app to "Read your emails".

### Security & Verification
- **Sensitive Scopes:** `gmail.readonly` is categorized as a "Sensitive" scope by Google.
- **Verification:** Apps using sensitive scopes typically need to undergo a verification process by Google before they can be used by "External" users. While in "Testing" mode in the Google Cloud Console, up to 100 test users can use the app without verification.
- **Verification Requirement:** For a production password manager, this verification will be necessary to avoid a "Unverified App" warning.
