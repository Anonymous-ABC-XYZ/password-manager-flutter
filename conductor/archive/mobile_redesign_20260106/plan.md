# Implementation Plan - Comprehensive Mobile UI Redesign

This plan outlines the steps to overhaul the Password Manager's UI into a mobile-first experience inspired by the "Stitch" design assets.

## Phase 1: Foundation & Theming Refinement
Refine the global theme and constants to support the new "Stitch" aesthetic across all screens.

- [x] Task: Update `BentoColors` and `BentoStyles` in `lib/bento_constants.dart` to match "Stitch" color palette and typography. 94959fb
- [x] Task: Create reusable `StitchBottomSheet` wrapper for consistent modal interactions. 94959fb
- [x] Task: Conductor - User Manual Verification 'Phase 1: Foundation' (Protocol in workflow.md) [checkpoint: 2dad833]

## Phase 2: Mobile-First Splash Screen
Redesign the onboarding and authentication flow with a full-bleed layout and bottom-sheet configuration.

- [x] Task: Write tests for `SplashScreen` mobile layout and Bottom Sheet triggers. df20948
- [x] Task: Implement new full-bleed UI in `lib/splash_screen.dart` with background blobs and branding. df20948
- [x] Task: Transition Google OAuth and DuckDuckGo configuration dialogs to Bottom Sheets. df20948
- [x] Task: Conductor - User Manual Verification 'Phase 2: Splash Screen' (Protocol in workflow.md) [checkpoint: 7f5b570]

## Phase 2.5: Authentication Refinement
Address user feedback to allow entry without Google/DuckDuckGo authentication (Offline/Guest Mode).

- [x] Task: Update `SplashScreen` to include a "Skip" or "Guest Mode" button. c315188
- [x] Task: Ensure app functionality persists without auth tokens (graceful degradation). c315188
- [x] Task: Conductor - User Manual Verification 'Phase 2.5: Auth Refinement' (Protocol in workflow.md) [checkpoint: 54bf40e]

## Phase 3: Main Navigation & App Scaffold
Update the core navigation structure to prioritize a refined mobile Bottom Navigation Bar.

- [x] Task: Refactor `MyHomePage` in `lib/main.dart` to use a modern `NavigationBar` with optimized icons and labels. 6c8cf9c
- [x] Task: Implement smooth page transitions between Vault, Credentials, and Settings. 2d7a622
- [x] Task: Conductor - User Manual Verification 'Phase 3: Main Navigation' (Protocol in workflow.md) [checkpoint: bbc5832]

## Phase 4: Vault Dashboard & Entry Form
Redesign the "Home" screen as a dashboard for adding and managing credentials with the new aesthetic.

- [x] Task: Write tests for the mobile-optimized credential entry form. 0a3b232
- [x] Task: Redesign `lib/home_screen.dart` using "Stitch" input fields and dashboard components. af0dfa9
- [x] Task: Conductor - User Manual Verification 'Phase 4: Vault Dashboard' (Protocol in workflow.md) [checkpoint: 558a619]

## Phase 5: Credentials List & Detail View
Modernize the password list and implement a dedicated detail view for viewing specific credential data.

- [x] Task: Write tests for the `CredentialDetailScreen`. 06a4355
- [x] Task: Redesign `lib/passwords_page.dart` list items and search bar. dff63d3
- [x] Task: Create `lib/credential_detail_screen.dart` based on the `entry_screen` design assets. 06a4355
- [x] Task: Conductor - User Manual Verification 'Phase 5: List & Details' (Protocol in workflow.md) [checkpoint: dff63d3]

## Phase 6: Settings & Configuration
Redesign the Settings screen to use mobile-native patterns and Bottom Sheets for all sub-configurations.

- [x] Task: Write tests for Settings interaction and Bottom Sheet persistence. 55fa9a9
- [x] Task: Redesign `lib/settings_screen.dart` with a clean, list-based layout. 55fa9a9
- [x] Task: Implement sub-settings (Theme, API Keys) as interactive Bottom Sheets. 55fa9a9
- [x] Task: Conductor - User Manual Verification 'Phase 6: Settings' (Protocol in workflow.md) [checkpoint: 55fa9a9]

## Phase 7: Final Polish (UI Overhaul)
Implement high-fidelity "Pop-Out" focus view and Catppuccin theming per design requirements.

- [x] Task: Refactor `PasswordsPage` to use `showGeneralDialog` for "Pop-Out" focus. dff63d3
- [x] Task: Create `CredentialFocusCard` with Catppuccin palette. dff63d3
- [x] Task: Update `ThemeModel` to Catppuccin Mocha defaults. dff63d3
- [x] Task: Implement Glassmorphism Bottom Bar and Gradient FAB in `main.dart`. dff63d3
