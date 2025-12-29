# Plan: Add Credential Categories

## Phase 1: Database & Model Updates [checkpoint: 40fc435]
- [x] Task: Create a reproduction test case for database migration. e61ac20
- [x] Task: Update the `Credential` data model. 78df814
- [x] Task: Implement Database Migration. c862e17
- [x] Task: Update Database Operations. c309a84
- [x] Task: Conductor - User Manual Verification 'Phase 1: Database & Model Updates' (Protocol in workflow.md)

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
