# Specification: Persistent Google OAuth Session

## Overview
The current application requires users to re-authenticate with Google every time the application starts. This track aims to implement a persistent session using Google OAuth refresh tokens, allowing the user to stay authenticated for a fixed period of 30 days before requiring a full re-login.

## Functional Requirements
- **Offline Access:** Update the OAuth flow to request `access_type=offline` and `prompt=consent` to ensure a refresh token is provided by Google.
- **Persistent Storage:** Securely store the refresh token and the **Initial Login Timestamp** using `flutter_secure_storage`.
- **Silent Authentication:** On application startup, the app should attempt to use the stored refresh token to obtain a new access token without user intervention.
- **Fixed 30-Day Session:**
    - The application must track the date of the initial authentication.
    - Exactly 30 days after the initial authentication, the session must be considered expired, regardless of recent activity.
    - Upon expiration, the application must clear the stored credentials.
- **Error Handling & UI:**
    - If silent authentication fails (due to revocation, network issues, or expiration), the user must be prompted to log in again.
    - The re-authentication prompt must clearly state that the "Access session has expired or been revoked" to provide context.
- **Gmail Service Integration:** Ensure `GmailService` correctly handles token refreshing using the stored client ID and secret.

## Non-Functional Requirements
- **Security:** Sensitive tokens (Access and Refresh) must never be stored in plain text or standard `SharedPreferences`. `flutter_secure_storage` (System Keychain/Secret Service) is the mandatory storage mechanism.
- **Reliability:** The background refresh logic should not block the main UI thread during app initialization.

## Acceptance Criteria
1. User logs in once and can close/re-open the app multiple times over several days without being asked for Google credentials.
2. The `AuthProvider` correctly identifies when 30 days have passed since the initial login and triggers a logout/re-auth flow.
3. If the user revokes access via their Google Account settings, the app detects the failure on next launch and shows the "revoked/expired" message.
4. OTP fetching continues to work seamlessly as long as the session is within the 30-day window.

## Out of Scope
- Supporting multiple Google accounts simultaneously.
- Adding biometric locks specifically for the OAuth token (relying on system-level security provided by `flutter_secure_storage`).
