# GEMINI.md

## Project Overview

**Password Manager** is a Flutter-based desktop application (optimized for Linux) designed to securely store and manage credentials. It combines local encrypted storage with cloud-based features like automatic OTP fetching from Gmail and disposable email alias generation via DuckDuckGo.

### Key Features
*   **Secure Storage**: Credentials are stored locally in an SQLite database, with sensitive keys secured using `flutter_secure_storage` (leveraging the system keychain).
*   **Smart Password Generator**: Generates strong, customizable passwords.
*   **Username Generator**: Generates random usernames (Adjective + Noun + Number).
*   **Email Privacy**: Generates disposable `@duck.com` email aliases.
*   **OTP Integration**: Fetches 2FA codes directly from Gmail using OAuth 2.0.
*   **Fuzzy Search**: Quickly find credentials using approximate string matching.
*   **Theming**: Support for Light and Dark modes.

### Tech Stack
*   **Framework**: Flutter (Dart)
*   **Database**: `sqflite` (SQLite) with `sqlcipher_flutter_libs` for encryption support (via FFI on desktop).
*   **State Management**: `provider`
*   **Networking**: `dio` (HTTP requests), `googleapis` (Gmail API)
*   **Security**: `flutter_secure_storage`, `googleapis_auth` (OAuth 2.0)
*   **UI**: Material Design 3, `animated_button`, `google_fonts`

## Architecture

The application follows a standard Flutter architecture with a separation of concerns:

*   **UI Layer**:
    *   **Screens**: `splash_screen.dart` (Auth), `home_screen.dart` (Add Entry), `passwords_page.dart` (List/Manage), `settings_screen.dart` (Config).
    *   **Components**: Reusable widgets like `alert_button.dart`, `boxes.dart`, `otp_input_field.dart`, `outlined_text_field.dart`.
    *   **Navigation**: `NavigationRail` used in `main.dart` for top-level navigation.
*   **Business Logic & State**:
    *   **Providers**: `AuthProvider` (`lib/providers/auth_provider.dart`) manages Google OAuth state.
    *   **Services**: `GmailService` (in `lib/gmail_service.dart`) handles API interactions.
*   **Data Layer**:
    *   **Database**: `dbinit.dart` initializes the SQLite database.
    *   **Storage**: `flutter_secure_storage` persists OAuth tokens and API keys.

## Build and Run

### Prerequisites
*   **Flutter SDK**: ^3.8.0
*   **Linux Dependencies**: `xdg-utils` (for opening browser during OAuth).
    ```bash
    sudo apt install xdg-utils
    ```

### Key Commands

*   **Install Dependencies**:
    ```bash
    flutter pub get
    ```

*   **Run (Linux)**:
    ```bash
    flutter run -d linux
    ```

*   **Run (Debug Profile)**:
    ```bash
    flutter run -d linux --profile
    ```

*   **Clean Build**:
    ```bash
    flutter clean
    ```

## Configuration

The application requires external API keys for full functionality. These are entered via the **Splash Screen** on first launch.

### 1. Google OAuth (for OTP Fetching)
*   **Required**: OAuth 2.0 Client ID and Client Secret.
*   **Setup**: Create a "Desktop app" credential in Google Cloud Console. Enable "Gmail API".
*   **Scope**: `https://www.googleapis.com/auth/gmail.readonly`.

### 2. DuckDuckGo (for Email Aliases)
*   **Required**: Authorization Key.
*   **Setup**: Obtain via network inspection on [duckduckgo.com/email](https://duckduckgo.com/email) (look for the `Authorization` header).

## Key Files and Directories

| File/Directory | Description |
| :--- | :--- |
| `lib/main.dart` | Entry point. Sets up the app, database FFI, providers, and main navigation scaffold. |
| `lib/splash_screen.dart` | Handles initial authentication (Google & DuckDuckGo) before granting app access. |
| `lib/home_screen.dart` | The primary "Add Entry" screen. Handles input, password generation, and saving to DB. |
| `lib/passwords_page.dart` | Displays the list of saved credentials. Allows deletion and copying. |
| `lib/auth_wrapper.dart` | Decides whether to show the Splash Screen or the Main App based on auth state. |
| `lib/dbinit.dart` | Database initialization logic. |
| `lib/providers/auth_provider.dart` | Manages authentication state and Google Sign-In logic. |
| `pubspec.yaml` | Project dependencies and configuration. |
| `linux/` | Linux-specific runner configuration (CMake, C++ runner). |

## Development Conventions

*   **State Management**: Use `Provider` for global state (like Auth) and `StatefulWidget` for local UI state.
*   **Asynchronous Operations**: Use `FutureBuilder` or `async`/`await` pattern for DB and network calls.
*   **UI Components**: Prefer creating small, reusable widgets (e.g., `Boxes`, `FrontPageEntries`) to keep screens clean.
*   **Platform Specifics**: Check `Platform.isLinux` (etc.) when using FFI or platform-specific features.
*   **Code Style**: Follow standard Dart formatting (`dart format .`).
