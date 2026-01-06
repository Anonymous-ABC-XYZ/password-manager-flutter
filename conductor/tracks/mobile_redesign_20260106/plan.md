# Implementation Plan - Comprehensive Mobile UI Redesign

This plan outlines the steps to overhaul the Password Manager's UI into a mobile-first experience inspired by the "Stitch" design assets.

## Phase 1: Foundation & Theming Refinement
Refine the global theme and constants to support the new "Stitch" aesthetic across all screens.

- [x] Task: Update `BentoColors` and `BentoStyles` in `lib/bento_constants.dart` to match "Stitch" color palette and typography. 94959fb
- [x] Task: Create reusable `StitchBottomSheet` wrapper for consistent modal interactions. 94959fb
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Foundation' (Protocol in workflow.md)

## Phase 2: Mobile-First Splash Screen
Redesign the onboarding and authentication flow with a full-bleed layout and bottom-sheet configuration.

- [ ] Task: Write tests for `SplashScreen` mobile layout and Bottom Sheet triggers.
- [ ] Task: Implement new full-bleed UI in `lib/splash_screen.dart` with background blobs and branding.
- [ ] Task: Transition Google OAuth and DuckDuckGo configuration dialogs to Bottom Sheets.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Splash Screen' (Protocol in workflow.md)

## Phase 3: Main Navigation & App Scaffold
Update the core navigation structure to prioritize a refined mobile Bottom Navigation Bar.

- [ ] Task: Refactor `MyHomePage` in `lib/main.dart` to use a modern `NavigationBar` with optimized icons and labels.
- [ ] Task: Implement smooth page transitions between Vault, Credentials, and Settings.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Main Navigation' (Protocol in workflow.md)

## Phase 4: Vault Dashboard & Entry Form
Redesign the "Home" screen as a dashboard for adding and managing credentials with the new aesthetic.

- [ ] Task: Write tests for the mobile-optimized credential entry form.
- [ ] Task: Redesign `lib/home_screen.dart` using "Stitch" input fields and dashboard components.
- [ ] Task: Conductor - User Manual Verification 'Phase 4: Vault Dashboard' (Protocol in workflow.md)

## Phase 5: Credentials List & Detail View
Modernize the password list and implement a dedicated detail view for viewing specific credential data.

- [ ] Task: Write tests for the `CredentialDetailScreen`.
- [ ] Task: Redesign `lib/passwords_page.dart` list items and search bar.
- [ ] Task: Create `lib/credential_detail_screen.dart` based on the `entry_screen` design assets.
- [ ] Task: Conductor - User Manual Verification 'Phase 5: List & Details' (Protocol in workflow.md)

## Phase 6: Settings & Configuration
Redesign the Settings screen to use mobile-native patterns and Bottom Sheets for all sub-configurations.

- [ ] Task: Write tests for Settings interaction and Bottom Sheet persistence.
- [ ] Task: Redesign `lib/settings_screen.dart` with a clean, list-based layout.
- [ ] Task: Implement sub-settings (Theme, API Keys) as interactive Bottom Sheets.
- [ ] Task: Conductor - User Manual Verification 'Phase 6: Settings' (Protocol in workflow.md)
