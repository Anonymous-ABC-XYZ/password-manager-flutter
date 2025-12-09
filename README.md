# Password Manager

A secure, feature-rich password manager built with Flutter for Linux desktop. Combines local encrypted storage with intelligent automation features including email alias generation and automatic OTP fetching from Gmail.

## Features

### Core Password Management
- **Secure Local Storage**: SQLite database with encrypted storage via Flutter Secure Storage
- **Smart Password Generator**: Creates strong passwords with customizable length (12-27 characters)
  - Mix of uppercase, lowercase, numbers, and special characters
  - Automatic clipboard copy on generation
- **Fuzzy Search**: Intelligent website search using fuzzy matching algorithm
- **Complete CRUD Operations**: Add, view, search, and delete password entries
- **Multi-field Support**: Store website, username, email, and password for each entry

### Email Alias Generation
- **DuckDuckGo Email Protection Integration**: Generate disposable email aliases on-demand
- **One-Click Generation**: Instantly create masked email addresses (@duck.com)
- **Automatic Clipboard Copy**: Generated aliases automatically copied for easy pasting
- **Privacy Protection**: Keep your real email private when signing up for services

### Automatic OTP Fetching
- **Gmail API Integration**: Fetch verification codes directly from your inbox
- **Smart OTP Detection**: Recognizes multiple OTP patterns (4-8 digits)
- **Recent Email Search**: Scans unread emails from the last 24 hours
- **Auto-fill Support**: Detected OTPs automatically populate the input field
- **Pattern Recognition**: Identifies codes from various services using keyword matching

### Security Features
- **OAuth 2.0 Authentication**: Secure Google account integration with automatic token refresh
- **Encrypted Credential Storage**: All sensitive data stored using FlutterSecureStorage
- **Automatic Token Management**: Refresh tokens handled transparently
- **No Plaintext Secrets**: Client secrets and auth tokens encrypted at rest
- **Beautiful OAuth Flow**: Professional browser-based consent with localhost callback server

### User Interface
- **Modern Material Design**: Clean, intuitive interface with custom color schemes
- **Dark/Light Theme Toggle**: Built-in theme switching
- **Responsive Layout**: Adaptive UI with navigation rail
- **Visual Feedback**: Loading states, snackbars, and progress indicators
- **Custom Typography**: Google Fonts integration (Bricolage Grotesque)

## Screenshots

### Main Interface
- **Home Screen**: Add new credentials with password generator, email alias generator, and OTP fetcher
- **Passwords Page**: View and manage all stored credentials in a card-based layout
- **Settings Screen**: Configure app preferences

### Authentication Flow
- Splash screen with Google OAuth and DuckDuckGo Email Protection setup
- Automatic authentication state management
- Beautiful browser success page on OAuth completion

## Installation

### Prerequisites

- Flutter SDK (3.8.0+)
- Linux desktop environment
- `xdg-utils` for browser launching:
  ```bash
  sudo apt install xdg-utils
  ```

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.4.2              # Local database
  flutter_secure_storage: ^9.2.4  # Encrypted storage
  googleapis: ^13.2.0          # Gmail API
  oauth2: ^2.0.2               # OAuth authentication
  url_launcher: ^6.3.1         # Browser integration
  dio: ^5.8.0+1                # HTTP client
  fuzzywuzzy: ^1.2.0          # Fuzzy search
  google_fonts: ^6.2.1         # Typography
  provider: ^6.1.5             # State management
```

### Setup

1. Clone the repository
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

1. **Create OAuth Credentials**:
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Navigate to **APIs & Services** → **Credentials**
   - Click **Create Credentials** → **OAuth 2.0 Client ID**
   - Application type: **Desktop app**
   - Name: `Password Manager`
   - Click **Create**

2. **Configure Redirect URI**:
   - Edit your OAuth 2.0 Client ID
   - Add authorized redirect URI: `http://localhost:8080`
   - Click **Save**
   - Copy Client ID and Client Secret

3. **Enable Gmail API**:
   - Go to **APIs & Services** → **Library**
   - Search for "Gmail API"
   - Click **Enable**

4. **Configure OAuth Consent Screen**:
   - Go to **APIs & Services** → **OAuth consent screen**
   - User Type: **External**
   - Fill required fields (App name, support email, developer contact)
   - **Scopes**: Add `https://www.googleapis.com/auth/gmail.readonly`
   - **Test Users**: Add your Gmail address
   - Click **Save and Continue**

### DuckDuckGo Email Protection Setup (for Email Aliases)

1. Visit [duckduckgo.com/email](https://duckduckgo.com/email)
2. Sign up for Email Protection
3. Open browser DevTools (F12) → Network tab
4. Generate a new email address on the DuckDuckGo page
5. Find the request to `quack.duckduckgo.com/api/email/addresses`
6. Copy the `Authorization` header value
7. Paste into the app during first-time setup

## First Launch

### Splash Screen Authentication

On first launch, you'll see two authentication cards:

**1. Google Account**
- Enter OAuth Client ID
- Enter OAuth Client Secret
- Click "Sign in with Google"
- Browser opens automatically
- Sign in and approve permissions
- Browser shows "Authentication Successful!" page
- Return to app (auto-detected)

**2. DuckDuckGo Email**
- Enter Authorization Key (from setup above)
- Click "Save Auth Key"

Once both authentications are complete, the "Continue" button activates and you can proceed to the main app.

### Subsequent Launches

- Credentials automatically loaded from secure storage
- No re-authentication required
- Tokens auto-refresh when expired
- Seamless app access

## Usage

### Adding a Password Entry

1. Navigate to **Home** screen
2. Fill in the fields:
   - **Website**: Name of the service (e.g., "GitHub")
   - **Username**: Your username
   - **Email**: Your email address
   - **Password**: Your password

3. Use automation features:
   - **Password Generator**: Click "Create" button to generate strong password
   - **Email Alias Generator**: Click "Acquire" button to get DuckDuckGo alias
   - **OTP Fetcher**: Click email icon in OTP field to fetch from Gmail

4. Click **Add** button to save

### Searching for Credentials

1. Enter website name in the "Website" field
2. Click "Search" button
3. Fuzzy matching finds the closest match
4. Dialog displays credentials with copy buttons

### Fetching OTP Codes

1. Request an OTP from any service
2. Wait for email to arrive in Gmail
3. In the app, click the email icon (📧) in the OTP input field
4. App scans recent unread emails
5. OTP automatically fills if found
6. Snackbar shows success/failure message

### Generating Email Aliases

1. Click "Acquire" button next to Email field
2. Masked email address generated instantly
3. Address automatically copied to clipboard
4. Use the alias when signing up for services
5. Emails forward to your real inbox

### Viewing Saved Passwords

1. Navigate to **Passwords** page (second icon in navigation rail)
2. All entries displayed in card format
3. Each card shows website, username, email, and password
4. Click copy icon to copy any field to clipboard
5. Click delete icon to remove entry

### Theme Toggle

Click the theme button at the bottom of the navigation rail to switch between light and dark modes.

## Architecture

### Database Schema

```sql
CREATE TABLE demo (
  Website TEXT PRIMARY KEY,
  Username TEXT,
  Email TEXT,
  Password TEXT
)
```

### Security Architecture

- **FlutterSecureStorage**: Platform-specific encrypted storage
  - Linux: `~/.local/share/flutter_secure_storage/`
  - Uses system keychain for encryption
- **OAuth Tokens**: Stored encrypted with automatic refresh
- **Auth Keys**: Never stored in plaintext
- **Local Callback Server**: Temporary HTTP server on localhost:8080 for OAuth flow

### OAuth Flow

```
User enters credentials → Browser opens for consent → User approves →
Redirect to localhost:8080 → App captures auth code →
Exchange for access/refresh tokens → Tokens stored encrypted →
Gmail API initialized → OTP fetching enabled
```

### OTP Detection Patterns

The app recognizes various OTP formats:
- "Your code is 123456"
- "OTP: 123456"
- "Verification code: 123456"
- Standalone 4-8 digit numbers

## Troubleshooting

### Google Sign-In Issues

**"Authentication timeout"**
- Approve consent within 5 minutes
- Or modify timeout in `lib/gmail_service.dart`:
  ```dart
  const Duration(minutes: 10) // Increase from 5
  ```

**"Invalid redirect_uri"**
- Ensure `http://localhost:8080` is added to authorized redirect URIs in Google Cloud Console
- Double-check there are no typos

**"Gmail API has not been used"**
- Enable Gmail API in Google Cloud Console
- Go to: `console.developers.google.com/apis/api/gmail.googleapis.com`

### Port Conflicts

**"Port 8080 already in use"**
```bash
# Find process using port
sudo lsof -i :8080

# Kill process
sudo kill -9 <PID>
```

Or change port in code:
```dart
// lib/gmail_service.dart
final server = await HttpServer.bind('localhost', 8081);
```
Remember to update redirect URI in Google Cloud Console.

### Browser Launch Issues

**"Failed to launch browser"**
```bash
# Install xdg-utils
sudo apt install xdg-utils
```

### OTP Not Found

**"No OTP found in recent emails"**
- Ensure email is unread
- Check email arrived within last 24 hours
- Verify email contains 4-8 digit code
- Mark email as unread and retry

### Email Alias Generation Fails

**"Could not fetch the email"**
- Check internet connection
- Verify Authorization Key is correct
- Get new Authorization Key from DuckDuckGo (they may expire)

## Technical Details

### Password Generation Algorithm

- Random length between 12-27 characters
- Minimum: 5 letters, 4 numbers, 3 special characters
- Character pools:
  - Letters: a-z (with random capitalization)
  - Numbers: 0-9
  - Special chars: ! @ # < % ^ &
- Shuffled for randomness

### Fuzzy Search

Uses the `fuzzywuzzy` package with `extractOne()` to find the best match from stored websites, allowing typos and partial matches.

### Token Management

- Access tokens expire after 1 hour
- Refresh tokens valid indefinitely (until revoked)
- `oauth2` package handles automatic renewal
- No user interaction needed for token refresh

## File Structure

```
lib/
├── main.dart                 # App entry point
├── auth_wrapper.dart         # Authentication state management
├── splash_screen.dart        # First-time setup screen
├── home_screen.dart          # Main password entry screen
├── passwords_page.dart       # Password list view
├── settings_screen.dart      # App settings
├── gmail_service.dart        # Gmail API integration
├── otp_input_field.dart      # OTP fetch widget
├── dbinit.dart              # Database initialization
├── alert_button.dart         # Reusable alert button
├── boxes.dart               # Password display widget
├── front_page_entries.dart  # Input field widgets
├── color-schemes.dart       # Theme definitions
└── outlined_text_field.dart # Custom text field
```

## Security Best Practices

1. **Never commit credentials**: OAuth secrets stored locally, not in version control
2. **Use test users**: Keep app in testing mode unless verified
3. **Revoke access**: Users can revoke access via Google Account settings
4. **Local-only storage**: Database never synced to cloud
5. **Encrypted at rest**: All sensitive data encrypted by FlutterSecureStorage

## Limitations

- **Linux only**: Currently supports Linux desktop (can be adapted for other platforms)
- **Gmail only**: OTP fetching requires Gmail (could be extended to other providers)
- **Test users**: Google OAuth limited to test users unless app verified
- **Local only**: No cloud sync or backup (future enhancement)
- **Single account**: One Google account and one DuckDuckGo account per installation

## Future Enhancements

- [ ] Cross-platform support (Windows, macOS, Android, iOS)
- [ ] Cloud backup/sync with end-to-end encryption
- [ ] Multi-account support
- [ ] Browser extension
- [ ] Password strength indicator
- [ ] Breach detection
- [ ] Import/export functionality
- [ ] Two-factor authentication (TOTP)
- [ ] Biometric authentication
- [ ] Auto-fill integration

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on Linux desktop
5. Submit a pull request

## License

This project is provided as-is for educational purposes.

## Acknowledgments

- **Flutter**: Cross-platform framework
- **Google APIs**: Gmail integration
- **DuckDuckGo**: Email Protection service
- **Material Design**: UI/UX principles
- **SQLite**: Local database engine

## Support

For issues and questions:
1. Check terminal output for detailed error messages
2. Verify Google Cloud Console configuration
3. Ensure all dependencies are installed
4. Try `flutter clean && flutter pub get`

## Changelog

### Current Version
- ✅ OAuth 2.0 with automatic callback server
- ✅ Beautiful browser success page
- ✅ Automatic OTP detection from Gmail
- ✅ DuckDuckGo email alias generation
- ✅ Secure encrypted storage
- ✅ Fuzzy search functionality
- ✅ Strong password generator
- ✅ Dark/light theme toggle
- ✅ Material Design 3 UI

---

**Built with ❤️ using Flutter**
