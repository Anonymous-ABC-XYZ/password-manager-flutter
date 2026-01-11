# Research: Mobile Native Gmail Sign-In

## 1. Selected Packages

### [google_sign_in](https://p

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

## 6. Google Cloud Console Configuration



### Android Client ID

1.  **Register App:** Use the package name found in `android/app/build.gradle` (e.g., `com.example.password_manager`).

2.  **SHA-1 Fingerprint:** Required for both Debug and Release.

    -   **Debug:** `keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore` (password: `android`).

    -   **Release:** Obtain from the `.keystore` file used to sign the APK or from Google Play Console (App Integrity).

3.  **Client ID Type:** "Android".



### iOS Client ID

1.  **Register App:** Use the Bundle ID found in Xcode (e.g., `com.example.passwordManager`).

2.  **Client ID Type:** "iOS".

3.  **REVERSED_CLIENT_ID:** This will be provided by Google and must be added to `Info.plist`.



### OAuth Consent Screen

- **User Type:** External (for general availability).

- **Scopes:** Add `https://www.googleapis.com/auth/gmail.readonly`.

- **Test Users:** While in "Testing" state, add developer/tester emails.



## 7. Platform Specific Configurations

### Android

#### 1. AndroidManifest.xml
- **Location:** android/app/src/main/AndroidManifest.xml
- **Permission:** Ensure INTERNET permission is present.
  ```xml
  <uses-permission android:name="android.permission.INTERNET"/>
  ```

#### 2. build.gradle (Project-level)
- **Location:** android/build.gradle
- **Plugin:** Add the google-services classpath.
  ```gradle
  dependencies {
      classpath 'com.google.gms:google-services:4.3.15' // or latest
  }
  ```

#### 3. build.gradle (App-level)
- **Location:** android/app/build.gradle
- **Apply Plugin:** Add 'com.google.gms.google-services' to the plugins block or at the bottom.
- **minSdkVersion:** Should be at least 21.

#### 4. google-services.json
- **Location:** android/app/google-services.json
- **Source:** Download from Firebase Console or Google Cloud Console (APIs & Services).

### iOS

(To be documented in next task)

### iOS

#### 1. GoogleService-Info.plist
- **Location:** ios/Runner/GoogleService-Info.plist
- **Source:** Download from Firebase Console or Google Cloud Console.

#### 2. Info.plist
- **Location:** ios/Runner/Info.plist
- **Configuration:**
  - Add `GIDClientID` with your iOS Client ID.
  - Add `CFBundleURLTypes` with your `REVERSED_CLIENT_ID`.
  ```xml
  <key>GIDClientID</key>
  <string>[YOUR_IOS_CLIENT_ID]</string>
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleTypeRole</key>
      <string>Editor</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>[YOUR_REVERSED_CLIENT_ID]</string>
      </array>
    </dict>
  </array>
  ```

#### 3. Entitlements (Optional)
- Generally not required for basic Google Sign-In unless using advanced keychain sharing features.

## 8. Implementation Roadmap

### Phase 1: Environment Setup
1. Create Android Client ID in Google Cloud Console.
2. Create iOS Client ID in Google Cloud Console.
3. Configure OAuth Consent Screen with `gmail.readonly` scope.
4. Download and add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).

### Phase 2: Project Configuration
1. Add `google_sign_in` and `extension_google_sign_in_as_googleapis_auth` to `pubspec.yaml`.
2. Update Android `build.gradle` and `AndroidManifest.xml`.
3. Update iOS `Info.plist` with URL Schemes.

### Phase 3: Code Implementation
1. Refactor `GmailService` to include a native authentication method.
2. Implement `signInSilently()` on app initialization to restore sessions.
3. Update UI (Splash Screen/Settings) to trigger the native sign-in flow on mobile.
4. Test end-to-end OTP fetching using the native flow.
