# Specification: Add Credential Categories

## 1. Overview
This feature introduces a categorization system for stored credentials. Users will be able to assign a category (e.g., "Work", "Personal", "Finance", "Social") to each password entry. The application will then allow users to filter the list of credentials by these categories, improving organization and browsing efficiency.

## 2. User Stories
- **As a user**, I want to assign a category to a new or existing password entry so that I can organize my credentials.
- **As a user**, I want to view a list of all available categories so that I can select one for filtering.
- **As a user**, I want to filter my password list by a specific category so that I can quickly find relevant credentials.
- **As a user**, I want to edit the category of an existing credential in case I made a mistake or my organization needs change.

## 3. Functional Requirements
### 3.1 Database Schema
- The `credentials` table needs a new column `category` (TEXT) or a foreign key to a new `categories` table.
    - *Decision:* To keep it simple for the MVP, we will add a `category` TEXT column to the `credentials` table. Standard categories can be pre-populated in the UI, but stored as text.
- **Migration:** A database migration must be implemented to add the `category` column to existing databases. Existing entries will default to "Uncategorized" or NULL.

### 3.2 Backend Logic
- Update `DBInit` (or the relevant database helper) to handle the schema migration.
- Update `Credential` model to include a `String? category` field.
- Update `createCredential` and `updateCredential` methods to persist the category.
- Update `getCredentials` (or create a new query) to support filtering by category.

### 3.3 User Interface
- **Add/Edit Screen (`home_screen.dart`):** Add a dropdown or selector widget for "Category".
    - Options: "Personal", "Work", "Finance", "Social", "Entertainment", "Other".
- **Passwords List (`passwords_page.dart`):**
    - Add a "Filter" button or a horizontal category selector at the top.
    - When a category is selected, the list should only show matching credentials.
    - Display the category name (or an icon representing it) on the `CredentialCard` or tile.

## 4. Non-Functional Requirements
- **Performance:** Filtering should be instantaneous for typical dataset sizes (< 1000 entries).
- **Usability:** The category selector should be intuitive and easily accessible.
- **Data Integrity:** Ensure no data is lost during the migration process.

## 5. Technical Constraints
- Must use existing `sqflite` database.
- Must follow Material Design 3 guidelines for new UI components (dropdowns, chips).
