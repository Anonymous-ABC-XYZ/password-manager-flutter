# Plan: Custom Color Schemes (Theming System)

This plan outlines the implementation of a dynamic theming system, allowing for pre-bundled themes and custom JSON theme uploads.

## Phase 1: Core Theming Infrastructure [checkpoint: d882501]
Establish the data models, persistence logic, and the global theme state management.

- [x] Task: Create `ThemeModel` to represent a color scheme 1f6d040
    - Define a class that holds all fields currently in `BentoColors`.
    - Add `fromJson` and `toJson` methods.
- [x] Task: Create `ThemeService` for persistence f762b74
    - Implement logic to read/write to `themes.json` in the local documents directory.
    - Handle fallback to "Bento Default" if the file is missing or invalid.
- [x] Task: Implement `ThemeProvider` for state management ed07527
    - Use `ChangeNotifier` to manage the current `ThemeModel`.
    - Provide a method to switch themes and notify listeners.
- [x] Task: Refactor `BentoColors` to be dynamic d882501
    - Update the application to consume colors from `ThemeProvider` instead of static constants.
- [x] Task: Conductor - User Manual Verification 'Phase 1: Core Theming Infrastructure' (Protocol in workflow.md) d882501

## Phase 2: Theme Management UI
Build the user interface for selecting and uploading themes in the Settings screen.

- [x] Task: Implement "Appearance" section in `SettingsScreen` 8c31473
    - Display a list of available themes (Default + Uploaded).
    - Add a visual indicator for the currently active theme.
- [x] Task: Implement JSON Theme Upload logic 814d6fb
    - Integrate `file_picker` to allow users to select JSON files.
    - Implement validation logic to check for required `BentoColors` fields.
    - Display specific error messages (as per spec) for invalid uploads.
- [x] Task: Implement Theme Selection and UI Refresh c030f48
    - Update `ThemeProvider` when a user selects a theme from the list.
    - Ensure the UI refreshes immediately.
- [x] Task: Conductor - User Manual Verification 'Phase 2: Theme Management UI' (Protocol in workflow.md) 0be0ee3

## Phase 3: Polish and Pre-bundled Themes
Add default themes and ensure a seamless user experience.

- [x] Task: Bundle "Catppuccin Mocha" theme a5c9e00
    - Create the JSON/Model for Catppuccin Mocha.
    - Include it in the initial state of the `ThemeService`.
- [x] Task: Final UI Polish 653c1b0
- [x] Task: Improve Theme Selection UI 1257384
- [x] Task: Conductor - User Manual Verification 'Phase 3: Polish and Pre-bundled Themes' (Protocol in workflow.md) 924afdb

## Phase 4: Documentation and Additional Themes
Add in-app instructions for creating custom themes and bundle the Rose Pine theme.

- [x] Task: Bundle "Rose Pine" theme fedb653
    - Add Rose Pine colors to `ThemeModel`.
    - Register it in `ThemeModel` static fields.
- [x] Task: Implement Theme Creation Instructions UI 5132a98
    - Add a "Help" or "Info" button near the "Upload Theme" button.
    - Display a dialog or modal showing the required JSON structure and available color keys.
- [~] Task: Conductor - User Manual Verification 'Phase 4: Documentation and Additional Themes' (Protocol in workflow.md)