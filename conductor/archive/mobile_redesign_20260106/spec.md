# Track Specification - Comprehensive Mobile UI Redesign

## Overview
This track involves a complete overhaul of the application's user interface to align with a mobile-first, modern design language inspired by the "Stitch" UI assets. The redesign covers all primary screens: Splash (Auth), Vault (Home), Credentials (List), Entry Details, and Settings.

## Functional Requirements
- **Mobile-First Architecture**: Transition from desktop-centric layouts to responsive, full-bleed mobile designs.
- **Enhanced Navigation**:
    - Replace the current conditional sidebar/bottom bar with a refined **Bottom Navigation Bar** for all mobile devices.
    - Tabs: **Vault** (Overview/Add), **Credentials** (List), and **Settings**.
- **Splash Screen (`lib/splash_screen.dart`)**:
    - Full-screen design with centered branding and vibrant gradient/blob backgrounds.
    - Auth options (Google/DuckDuckGo) as prominent full-width cards.
    - Configuration for API keys handled via **Bottom Sheets**.
- **Vault/Home Screen (`lib/home_screen.dart`)**:
    - Redesign as a "Dashboard" or "Quick Action" hub.
    - Modernize input fields using the `Stitch` aesthetic (cleaner borders, better spacing).
- **Credentials List (`lib/passwords_page.dart`)**:
    - Implement a "Vault" list view with refined credential cards.
    - Integrated search functionality with a mobile-optimized search bar.
- **Entry Detail Screen (New)**:
    - Dedicated view for viewing/copying/editing specific credentials, based on the `entry_screen` design.
- **Settings Screen (`lib/settings_screen.dart`)**:
    - List-based settings where individual configurations (Theme, Security, Keys) open in **Bottom Sheets**.

## Visual Design Goals (Stitch Aesthetic)
- **Colors**: Utilize `BentoColors` with a focus on deep backgrounds and vibrant accent colors (Primary Blue/Purple).
- **Components**: Use rounded corners (16-24px), subtle multi-layered shadows, and semi-transparent surfaces.
- **Gradients**: Incorporate ambient background blobs to create depth.
- **Typography**: Consistent use of `GoogleFonts` (Oswald/Roboto/Open Sans) with prioritized hierarchy.

## Acceptance Criteria
- [ ] **Splash**: Full-bleed UI with functional Bottom Sheets for configuration.
- [ ] **Main Navigation**: Bottom navigation bar correctly switches between Vault, Credentials, and Settings.
- [ ] **Vault**: User can add new credentials through a mobile-optimized form.
- [ ] **Credentials**: Fuzzy search and list scrolling work smoothly on mobile.
- [ ] **Details**: Clicking a credential navigates to a `CredentialDetailScreen` matching the `entry_screen` assets.
- [ ] **Settings**: All configurations are accessible via Bottom Sheets.
- [ ] **Responsiveness**: The app remains functional on desktop (resizing gracefully) but prioritizes the mobile experience.

## Out of Scope
- Backend database schema changes.
- Implementation of new third-party integrations (e.g., ProtonMail, etc.).