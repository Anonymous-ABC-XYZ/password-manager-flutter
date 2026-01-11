# Plan: Mobile Native Gmail Sign-In Research

## Phase 1: Package Discovery & Scope Verification [checkpoint: 910300e]
- [x] Task: Research `google_sign_in` package and alternative Flutter plugins for native authentication. 2e681fb
- [x] Task: Verify the process for requesting `https://www.googleapis.com/auth/gmail.readonly` via native pop-up. 62e6d15
- [x] Task: Identify how the native flow returns credentials and how they integrate with `googleapis_auth`. 77a061d
- [x] Task: Conductor - User Manual Verification 'Package Discovery & Scope Verification' (Protocol in workflow.md)

## Phase 2: Platform & Infrastructure Requirements
- [ ] Task: Document required Google Cloud Console configurations (Android/iOS Client IDs, SHA-1 fingerprints).
- [ ] Task: Research Android-specific configuration (build.gradle, manifest, internet permissions).
- [ ] Task: Research iOS-specific configuration (Info.plist, URL Schemes, entitlements).
- [ ] Task: Conductor - User Manual Verification 'Platform & Infrastructure Requirements' (Protocol in workflow.md)

## Phase 3: Final Documentation
- [ ] Task: Compile all findings into a comprehensive `RESEARCH.md` or similar document in the track directory.
- [ ] Task: Create a high-level Implementation Plan (sequence of tasks) for the future coding phase.
- [ ] Task: Conductor - User Manual Verification 'Final Documentation' (Protocol in workflow.md)
