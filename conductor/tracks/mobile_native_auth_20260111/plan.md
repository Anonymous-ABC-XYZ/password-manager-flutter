# Plan: Mobile Native Gmail Sign-In Implementation

## Phase 1: Project Setup & Platform Configuration
- [x] Task: Document Google Cloud Console setup (Android/iOS Client IDs, SHA-1). 0019db6
- [x] Task: Add dependencies `google_sign_in` and `extension_google_sign_in_as_googleapis_auth` to `pubspec.yaml`. e20be47
- [x] Task: Configure Android `AndroidManifest.xml` and `build.gradle` for Google services. 1083391
- [ ] Task: Configure iOS `Info.plist` with URL Schemes and `GIDClientID`.
- [ ] Task: Conductor - User Manual Verification 'Project Setup & Platform Configuration' (Protocol in workflow.md)

## Phase 2: GmailService & AuthProvider Refactoring (TDD)
- [ ] Task: Write unit tests for native authentication flow in `GmailService`.
- [ ] Task: Implement native `authenticate()` method in `GmailService` for mobile platforms.
- [ ] Task: Implement `signInSilently()` in `GmailService` to restore sessions.
- [ ] Task: Update `AuthProvider` to integrate with the new native flow.
- [ ] Task: Conductor - User Manual Verification 'GmailService & AuthProvider Refactoring' (Protocol in workflow.md)

## Phase 3: UI Integration & Verification
- [ ] Task: Update `SplashScreen` / `AuthWrapper` to trigger `signInSilently()` on startup.
- [ ] Task: Update `SettingsScreen` (or relevant UI) to trigger the native sign-in popup.
- [ ] Task: Verify end-to-end OTP fetching functionality on a mobile device/emulator.
- [ ] Task: Conductor - User Manual Verification 'UI Integration & Verification' (Protocol in workflow.md)
