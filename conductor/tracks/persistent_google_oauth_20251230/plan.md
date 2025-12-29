# Plan: Persistent Google OAuth Session

This plan implements a 30-day persistent session for Google OAuth using refresh tokens, ensuring users only need to log in once a month.

## Phase 1: Session Metadata & Expiration Logic [checkpoint: f97fc3b]
- [x] Task: TDD - Write unit tests for session expiration logic (calculating 30-day window) in `AuthProvider`. 2556aee
- [x] Task: Implement `_saveInitialLoginTime`, `_loadInitialLoginTime`, and `isSessionExpired` logic in `AuthProvider`. 2556aee
- [x] Task: Conductor - User Manual Verification 'Phase 1: Session Metadata' (Protocol in workflow.md) f97fc3b

## Phase 2: Offline Access & Refresh Token Acquisition
- [ ] Task: TDD - Write unit tests for `GmailService` to verify OAuth parameters for offline access.
- [ ] Task: Update `GmailService.authenticate` to include `access_type=offline` and `prompt=consent`.
- [ ] Task: Update credential storage to ensure refresh tokens are captured and persisted via `flutter_secure_storage`.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Refresh Token Acquisition' (Protocol in workflow.md)

## Phase 3: Silent Refresh & Startup Integration
- [ ] Task: TDD - Write unit tests for `GmailService.signIn` silent refresh flow using mocked credentials.
- [ ] Task: Implement silent token refresh in `GmailService.signIn` using the `oauth2` client's refresh capabilities.
- [ ] Task: Refactor `AuthProvider._initialize` to verify session age before attempting silent refresh.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Silent Refresh' (Protocol in workflow.md)

## Phase 4: Expiration Enforcement & UI Feedback
- [ ] Task: TDD - Write unit tests for `AuthProvider` handling of expired or revoked tokens (state clearing and error messaging).
- [ ] Task: Update `SplashScren` or `AuthWrapper` to display the specific "Session Expired/Revoked" message when re-authentication is required.
- [ ] Task: Implement strict 30-day enforcement that clears all stored Google credentials upon expiration.
- [ ] Task: Conductor - User Manual Verification 'Phase 4: Expiration Enforcement' (Protocol in workflow.md)
