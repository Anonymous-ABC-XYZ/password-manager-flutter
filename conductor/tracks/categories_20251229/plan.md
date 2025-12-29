# Plan: Add Credential Categories

## Phase 1: Database & Model Updates [checkpoint: 40fc435]
- [x] Task: Create a reproduction test case for database migration. e61ac20
- [x] Task: Update the `Credential` data model. 78df814
- [x] Task: Implement Database Migration. c862e17
- [x] Task: Update Database Operations. c309a84
- [x] Task: Conductor - User Manual Verification 'Phase 1: Database & Model Updates' (Protocol in workflow.md)

## Phase 2: UI Implementation - Add/Edit Credentials [checkpoint: 07713c2]
- [x] Task: Add Category Selector to `HomeScreen`. 50bb494
- [x] Task: Update `CredentialCard` display. 9916072
- [x] Task: Conductor - User Manual Verification 'Phase 2: UI Implementation - Add/Edit Credentials' (Protocol in workflow.md)

## Phase 3: UI Implementation - Filtering & Browsing
- [x] Task: Add Category Filter to `PasswordsPage`. d24b8ed
    - **Sub-task:** Implement a `FilterBar` widget (horizontal list of `FilterChip`s) at the top of `passwords_page.dart`.
    - **Sub-task:** Manage the selected category state (local state or via Provider).
- [x] Task: Connect Filter to Data Source. d24b8ed
    - **Sub-task:** Update the `FutureBuilder` or data fetching logic in `PasswordsPage` to request filtered data when a category is selected.
    - **Sub-task:** Alternatively, filter the list in memory if the dataset is small (decide based on `tech-stack.md` preference for performance). *Decision: Filter in memory for now given typical password DB sizes.*
- [~] Task: Conductor - User Manual Verification 'Phase 3: UI Implementation - Filtering & Browsing' (Protocol in workflow.md)
