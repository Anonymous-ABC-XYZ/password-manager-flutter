# Plan: Add Credential Categories

## Phase 1: Database & Model Updates
- [x] Task: Create a reproduction test case for database migration. e61ac20
    - **Sub-task:** Write a test that initializes an old version of the DB, inserts data, runs the migration, and verifies the new column exists.
- [x] Task: Update the Credential data model. 78df814
    - **Sub-task:** Add `String? category` to the `Credential` class.
    - **Sub-task:** Update `toMap` and `fromMap` methods.
    - **Sub-task:** Update unit tests for the `Credential` model.
- [x] Task: Implement Database Migration. c862e17
    - **Sub-task:** Modify `dbinit.dart` to increment the database version.
    - **Sub-task:** Implement the `onUpgrade` callback to execute `ALTER TABLE credentials ADD COLUMN category TEXT`.
    - **Sub-task:** Verify the migration using the test case created earlier.
- [x] Task: Update Database Operations. c309a84
    - **Sub-task:** Update `insertCredential` to save the category.
    - **Sub-task:** Update `updateCredential` to modify the category.
    - **Sub-task:** Create a new method `getCredentialsByCategory(String category)` or update the existing fetch to support optional filtering.
    - **Sub-task:** Write integration tests for these DB operations.
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Database & Model Updates' (Protocol in workflow.md)

## Phase 2: UI Implementation - Add/Edit Credentials
- [ ] Task: Add Category Selector to `HomeScreen`.
    - **Sub-task:** Create a `CategorySelector` widget (e.g., using `DropdownButtonFormField` or `ChoiceChip`).
    - **Sub-task:** Integrate this widget into the form in `home_screen.dart`.
    - **Sub-task:** Update the "Save" logic to capture the selected category.
- [ ] Task: Update `CredentialCard` display.
    - **Sub-task:** Modify `credential_card.dart` (or `identity_tile.dart`/`secure_credentials_tile.dart` as appropriate) to visually display the assigned category (e.g., a small text label or icon).
    - **Sub-task:** Ensure the design aligns with the `product-guidelines.md` (Material 3).
- [ ] Task: Conductor - User Manual Verification 'Phase 2: UI Implementation - Add/Edit Credentials' (Protocol in workflow.md)

## Phase 3: UI Implementation - Filtering & Browsing
- [ ] Task: Add Category Filter to `PasswordsPage`.
    - **Sub-task:** Implement a `FilterBar` widget (horizontal list of `FilterChip`s) at the top of `passwords_page.dart`.
    - **Sub-task:** Manage the selected category state (local state or via Provider).
- [ ] Task: Connect Filter to Data Source.
    - **Sub-task:** Update the `FutureBuilder` or data fetching logic in `PasswordsPage` to request filtered data when a category is selected.
    - **Sub-task:** Alternatively, filter the list in memory if the dataset is small (decide based on `tech-stack.md` preference for performance). *Decision: Filter in memory for now given typical password DB sizes.*
- [ ] Task: Conductor - User Manual Verification 'Phase 3: UI Implementation - Filtering & Browsing' (Protocol in workflow.md)
