# Specification: Custom Color Schemes (Theming System)

## Overview
Implement a dynamic theming system that allows users to select from pre-bundled color schemes or upload their own custom themes via JSON files. This feature will be integrated into the existing Settings screen and will allow for a highly personalized UI experience similar to IDE theme plugins.

## Functional Requirements
- **Theme Selection UI**: Add an "Appearance" section in the Settings screen to switch between available themes.
- **JSON Theme Upload**: 
    - Provide an "Upload Theme" button that opens a file picker.
    - Support JSON files that map directly to the `BentoColors` class fields (e.g., `primary`, `backgroundDark`, `surfaceDark`, `textWhite`, `textMuted`, etc.).
- **Validation & Feedback**: 
    - Validate JSON structure on upload.
    - If a required color field is missing or the format is invalid, display a specific error message to the user (e.g., "Missing field: primary").
- **Persistence**: 
    - Save the currently selected theme preference and any custom uploaded theme data to a `themes.json` file in the application's local documents directory.
    - Ensure the selected theme is applied immediately upon selection and persists across application restarts.
- **Pre-bundled Themes**: Include a few default high-quality themes (e.g., "Bento Default", "Catppuccin Mocha").

## Non-Functional Requirements
- **Performance**: Theme switching should be instantaneous without requiring an app restart.
- **Reliability**: If the `themes.json` file is corrupted or the selected theme is missing, fall back to the "Bento Default" theme.

## Acceptance Criteria
- [ ] User can see a list of available themes in Settings.
- [ ] User can upload a valid JSON file and see it added to the list.
- [ ] Invalid JSON uploads trigger an informative error message.
- [ ] The selected theme persists after closing and reopening the app.
- [ ] The entire UI updates its colors immediately when a new theme is selected.

## Out of Scope
- Runtime "Theme Editor" (UI for picking individual colors within the app).
- Sharing custom themes via a cloud-based marketplace (local only for now).