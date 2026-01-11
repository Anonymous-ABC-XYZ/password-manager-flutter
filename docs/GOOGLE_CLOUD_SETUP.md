# Google Cloud Console Setup for Native Mobile Authentication

To enable native Google Sign-In on mobile, specific Client IDs must be configured in the Google Cloud Console.

## Android Configuration

1.  **Create Client ID:**
    *   Navigate to **APIs & Services > Credentials**.
    *   Click **Create Credentials > OAuth client ID**.
    *   Select **Android** as the Application type.

2.  **Package Name:**
    *   Enter the package name found in `android/app/build.gradle` (typically `com.example.password_manager` or similar).

3.  **SHA-1 Certificate Fingerprint:**
    *   **Debug Key:** Run the following command to get the debug SHA-1:
        ```bash
        keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android
        ```
    *   **Release Key:** For production, use the keystore that signs the release APK/App Bundle.

## iOS Configuration

1.  **Create Client ID:**
    *   Navigate to **APIs & Services > Credentials**.
    *   Click **Create Credentials > OAuth client ID**.
    *   Select **iOS** as the Application type.

2.  **Bundle ID:**
    *   Enter the Bundle Identifier found in `ios/Runner.xcodeproj` (typically `com.example.passwordManager`).

3.  **Download Config:**
    *   Download the `GoogleService-Info.plist` file generated for iOS.
    *   Note the `REVERSED_CLIENT_ID` inside this file (needed for `Info.plist`).

## OAuth Consent Screen

1.  **Scopes:**
    *   Ensure `https://www.googleapis.com/auth/gmail.readonly` is added to the scopes.
    *   Since this is a sensitive scope, the app may need verification for production use.
2.  **Test Users:**
    *   Add your Google email as a test user if the app status is "Testing".
