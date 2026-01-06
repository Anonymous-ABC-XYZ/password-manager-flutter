# Technology Stack

## Core
- **Language:** Dart
- **Framework:** Flutter (Mobile & Desktop - Linux)
- **Architecture:** MVC-inspired separation with Providers for state and Services for external APIs.

## Data & Security
- **Local Database:** SQLite (via `sqflite` and `sqflite_common_ffi` for desktop support).
- **Encryption:** `sqlcipher_flutter_libs` for database-level encryption and `flutter_secure_storage` for persisting sensitive keys (OAuth tokens, API keys) via the system keychain.

## Networking & Integrations
- **HTTP Client:** `dio` for robust API requests.
- **Google OAuth/Gmail:** `googleapis` and `oauth2` for secure access to Gmail unread messages for OTP fetching.
- **DuckDuckGo Integration:** Custom implementation via `dio` to interact with DuckDuckGo Email Protection services.

## UI & State
- **State Management:** `provider` for global application state (authentication, settings).
- **UI Framework:** Material Design 3 with custom "Stitch" aesthetic (Catppuccin Mocha palette) and Glassmorphism effects.
- **Typography:** `google_fonts`.
- **Utilities:** `fuzzywuzzy` for intelligent credential searching.
- **File Management:** `path_provider` for accessing platform-agnostic file system paths.
