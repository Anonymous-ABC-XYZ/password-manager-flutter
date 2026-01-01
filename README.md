# Password Manager

A secure, feature-rich password manager built with Flutter for Linux desktop. Combines local encrypted storage with intelligent automation features including email alias generation and automatic OTP fetching from Gmail.

## Features

- **Secure Local Storage**: SQLite database with encrypted storage via Flutter Secure Storage.
- **Smart Password Generator**: Creates strong passwords (12-27 chars) with mixed characters.
- **Random Username Generator**: Generates unique usernames (Adjective + Noun + Number) and auto-copies to clipboard.
- **Email Alias Generation**: Integrates with DuckDuckGo Email Protection for disposable aliases.
- **Automatic OTP Fetching**: Fetches verification codes directly from Gmail using OAuth 2.0.
- **Fuzzy Search**: Intelligent website search using fuzzy matching.
- **Modern UI**: Clean Material Design interface with dark/light theme toggle.

## Installation

### Prerequisites

- Flutter SDK (3.8.0+)
- Linux desktop environment
- `xdg-utils`: `sudo apt install xdg-utils`

### Setup

1. Clone the repository.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run -d linux
   ```

## Configuration

### Google OAuth Setup (for OTP Fetching)

1. **Create OAuth Credentials** in [Google Cloud Console](https://console.cloud.google.com):
   - Type: **Desktop app**
   - Name: `Password Manager`
2. **Configure Redirect URI**: `http://localhost:8080`
3. **Enable Gmail API** in the Library.
4. **Configure OAuth Consent Screen**:
   - Scopes: `https://www.googleapis.com/auth/gmail.readonly`
   - Add your Gmail address as a Test User.

### DuckDuckGo Email Protection Setup (for Email Aliases)

1. Sign up at [duckduckgo.com/email](https://duckduckgo.com/email).
2. Inspect network traffic (F12) while generating a new address.
3. Copy the `Authorization` header value from the request to `quack.duckduckgo.com`.

## Usage

### First Launch

1. **Google Account**: Enter Client ID and Secret, then sign in via the browser.
2. **DuckDuckGo**: Enter your Authorization Key.

### Core Operations

- **Add Entry**: Fill in Website, Username, Email, and Password. Use the "Create" button for passwords and "Acquire" for email aliases.
- **Fetch OTP**: Click the email icon in the OTP field to scan recent unread emails for codes.
- **Search**: Enter a website name and click "Search" to find credentials using fuzzy matching.
- **Manage**: View all entries in the Passwords page; copy or delete as needed.

## Architecture & Security

- **Database**: SQLite for structured data.
- **Encryption**: FlutterSecureStorage (using system keychain) for sensitive data (tokens, secrets).
- **OAuth Flow**: Uses a local localhost:8080 server for secure token exchange.
- **OTP Detection**: Scans for patterns like "Code: 123456" or standalone 4-8 digit numbers.

## Troubleshooting

- **Google Sign-In Timeout**: Approve consent within 5 minutes.
- **Port 8080 Conflict**: Ensure no other service is using port 8080 or change it in `lib/gmail_service.dart`.
- **OTP Not Found**: Ensure the email is unread and arrived within the last 24 hours.
