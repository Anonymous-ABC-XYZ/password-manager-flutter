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

## 4. Integration with `googleapis_auth`
Using the extension package:

```dart
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
final authClient = await _googleSignIn.authenticatedClient();
// authClient is now a googleapis_auth.AuthClient ready for Gmail API
```
