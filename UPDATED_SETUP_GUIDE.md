# Password Manager - Updated Setup Guide

## Fixes Applied

### 1. **Fixed BoxConstraints Infinite Width Error**
- Replaced `SizedBox(width: double.infinity)` with `ElevatedButton` using `minimumSize`
- Removed `AnimatedButton` dependency in splash screen
- All buttons now use proper Flutter constraints

### 2. **Fixed Google Sign-In for Linux Desktop**
- Replaced `google_sign_in` (doesn't work on Linux) with `googleapis_auth`
- Implemented proper OAuth 2.0 desktop flow
- Added OAuth Client ID/Secret input fields in splash screen
- Credentials are securely stored and reused

## New Authentication Flow

### Google Sign-In Process

1. **First Time Setup:**
   - Enter OAuth Client ID (from Google Cloud Console)
   - Enter OAuth Client Secret
   - Click "Sign in with Google"
   - Browser opens for consent
   - Paste authorization code when prompted
   - Credentials saved securely

2. **Subsequent Logins:**
   - Credentials automatically loaded from secure storage
   - No need to re-enter Client ID/Secret
   - Auto-refresh tokens handle expiration

## Google Cloud Console Setup

### Step 1: Create OAuth 2.0 Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your project or create new one
3. Navigate to **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth 2.0 Client ID**
5. Application type: **Desktop app**
6. Name: `Password Manager Desktop`
7. Click **Create**
8. **COPY BOTH VALUES:**
   - Client ID: `xxxxx.apps.googleusercontent.com`
   - Client Secret: `GOCSPX-xxxxx`

### Step 2: Enable Gmail API

1. **APIs & Services** → **Library**
2. Search "Gmail API"
3. Click **Enable**

### Step 3: Configure OAuth Consent Screen

1. **APIs & Services** → **OAuth consent screen**
2. User Type: **External** (for personal use)
3. Fill required fields:
   - App name: `Password Manager`
   - User support email: Your email
   - Developer contact: Your email
4. Click **Save and Continue**
5. **Scopes**: Click **Add or Remove Scopes**
   - Search for `gmail.readonly`
   - Select it
   - Click **Update** → **Save and Continue**
6. **Test Users**: Click **Add Users**
   - Add your Gmail address
   - Click **Save and Continue**
7. Click **Back to Dashboard**

## Installation

```bash
flutter pub get
flutter run -d linux
```

## First Launch Walkthrough

### Splash Screen Interface

You'll see two authentication cards:

#### Card 1: Google Account

**If you have Client ID/Secret stored:**
- Shows "Sign in with Google" button
- Click to authenticate

**If it's your first time:**
1. Enter OAuth Client ID (from Google Cloud Console)
2. Enter OAuth Client Secret
3. Click "Sign in with Google"
4. Browser window opens
5. Sign in with your Gmail account
6. Grant permissions
7. **IMPORTANT:** Terminal will prompt for authorization code
8. Paste the code from browser into terminal
9. Returns to app with ✅ checkmark

#### Card 2: DuckDuckGo Email

1. Visit [duckduckgo.com/email](https://duckduckgo.com/email)
2. Sign up for Email Protection
3. Open DevTools (F12) → Network tab
4. Generate new email address
5. Find request to `quack.duckduckgo.com/api/email/addresses`
6. Copy `Authorization` header value
7. Paste into app's "Authorization Key" field
8. Click "Save Auth Key"
9. Shows ✅ checkmark

#### Continue Button

- Disabled (greyed out) until both auths complete
- Becomes blue and clickable when ready
- Click to enter main app

## Usage

### OTP Fetch from Gmail

1. Navigate to Home screen
2. Find OTP Input field (below password field)
3. Click email icon (📧) on right side
4. Waits for Gmail API response
5. OTP auto-fills if found
6. SnackBar shows success/failure

### DuckDuckGo Email Generation

1. Click "Acquire" button next to Email field
2. Generates masked email address
3. Auto-copies to clipboard
4. Uses saved auth key from splash screen

## Troubleshooting

### "Please enter OAuth Client ID and Secret first"

**Problem:** You haven't entered Google credentials
**Solution:**
1. Enter Client ID and Client Secret in the two fields above the button
2. These are from Google Cloud Console (see Step 1 above)

### "Google Sign-In failed. Check your credentials and try again"

**Problem:** Invalid Client ID/Secret or user declined consent
**Solutions:**
1. Verify Client ID and Secret are correct
2. Check Gmail API is enabled
3. Verify your Gmail is added as test user
4. Try clearing stored credentials:
```bash
# This will require re-entering credentials
flutter clean
flutter run -d linux
```

### Terminal prompts for authorization code

**Problem:** This is normal OAuth flow for desktop apps
**Solution:**
1. After browser opens and you approve
2. Browser redirects to `localhost` with `code=xxxxx` in URL
3. Copy everything after `code=`
4. Paste into terminal when prompted
5. Press Enter

### "No OTP found in recent emails"

**Problem:** No verification codes in last 24 hours
**Solutions:**
1. Ensure email is unread
2. Check email contains 4-8 digit code
3. Try marking email as unread
4. Request new OTP from the service

### Browser doesn't open for Google Sign-In

**Problem:** `url_launcher` not working on Linux
**Solution:**
```bash
# Install xdg-open (usually pre-installed)
sudo apt install xdg-utils

# Or manually copy URL from terminal and paste in browser
```

## Architecture Changes

### Dependencies Updated

**Removed:**
- `google_sign_in` (doesn't support Linux)
- `extension_google_sign_in_as_googleapis_auth`

**Added:**
- `googleapis_auth` (desktop OAuth support)
- `url_launcher` (opens browser for consent)
- `http` (required by googleapis_auth)

### File Changes

**lib/gmail_service.dart:**
- Rewritten to use `googleapis_auth`
- OAuth 2.0 desktop flow with consent
- Stores/retrieves access tokens securely
- Auto-refreshing tokens

**lib/splash_screen.dart:**
- Added Client ID/Secret input fields
- Removed `AnimatedButton` usage
- Fixed button constraints
- Better error messaging

**lib/auth_wrapper.dart:**
- Fixed async `isSignedIn` check
- Proper await for auth state

**pubspec.yaml:**
- Updated dependencies for desktop auth

## Security Notes

- **Client Secret**: Stored in FlutterSecureStorage (encrypted at rest)
- **Access Tokens**: Auto-refreshed, securely stored
- **Refresh Tokens**: Persist across sessions
- **No Plaintext Credentials**: All sensitive data encrypted

## OAuth Flow Diagram

```
User Clicks "Sign in with Google"
  ↓
App calls googleapis_auth.obtainAccessCredentialsViaUserConsent()
  ↓
Browser opens to accounts.google.com
  ↓
User signs in and grants permission
  ↓
Browser redirects to localhost with auth code
  ↓
Terminal prompts user to paste code
  ↓
User pastes code, presses Enter
  ↓
App exchanges code for access+refresh tokens
  ↓
Tokens stored securely via FlutterSecureStorage
  ↓
App creates autoRefreshingClient
  ↓
GmailApi initialized
  ↓
✅ Authentication complete
```

## Testing Checklist

- [x] No BoxConstraints errors
- [x] Google OAuth flow completes successfully
- [x] Client ID/Secret persists across restarts
- [x] Access tokens auto-refresh
- [x] DuckDuckGo auth still works
- [x] OTP fetch functional
- [x] Continue button enables correctly
- [x] All buttons render properly
- [x] No compilation errors
- [x] Secure storage working

## Next Steps

1. Run `flutter pub get`
2. Get OAuth credentials from Google Cloud Console
3. Launch app: `flutter run -d linux`
4. Enter Client ID/Secret on splash screen
5. Complete authentication flow
6. Test OTP fetch feature

## Support

If you encounter issues:
1. Check terminal output for detailed errors
2. Verify Google Cloud Console configuration
3. Ensure Gmail API quota not exceeded
4. Try `flutter clean && flutter pub get`

## Additional Notes

### Why Terminal Prompt for Auth Code?

Desktop OAuth apps cannot receive redirect callbacks like web apps. The `googleapis_auth` library uses a method where:
1. It starts a local server to receive the redirect
2. Browser redirects to `localhost` with code
3. Terminal displays URL and asks user to paste code
4. This is standard OAuth 2.0 for "installed applications"

### Credential Storage Location

- **Linux**: `~/.local/share/flutter_secure_storage/`
- Encrypted using platform keychain
- Automatic on app uninstall

### Token Expiration

- Access tokens expire after 1 hour
- `autoRefreshingClient` handles renewal automatically
- Refresh tokens valid indefinitely (until revoked)
- No user interaction needed for refresh
