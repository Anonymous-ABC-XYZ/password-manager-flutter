import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:password_manager/features/auth/gmail_service.dart';

class AuthProvider extends ChangeNotifier {
  final GmailService _gmailService;
  final FlutterSecureStorage _storage;

  bool _isAuthenticated = false;
  bool _isGuestMode = false;
  bool _isInitializing = true;
  String? _errorMessage;
  Timer? _refreshTimer;
  DateTime? _lastRefreshTime;
  DateTime? _initialLoginTime;

  // Session duration: 30 days
  static const Duration sessionDuration = Duration(days: 30);
  // Token refresh interval (background): 14 days
  static const Duration refreshInterval = Duration(days: 14);

  bool get isAuthenticated => _isAuthenticated;
  bool get isGuestMode => _isGuestMode;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  GmailService get gmailService => _gmailService;
  DateTime? get lastRefreshTime => _lastRefreshTime;
  DateTime? get initialLoginTime => _initialLoginTime;

  AuthProvider({GmailService? gmailService, FlutterSecureStorage? storage})
    : _gmailService = gmailService ?? GmailService(),
      _storage = storage ?? const FlutterSecureStorage() {
    _initialize();
  }

  /// Enable Guest Mode
  void enableGuestMode() {
    _isGuestMode = true;
    notifyListeners();
  }

  /// Initialize authentication state on app startup
  Future<void> _initialize() async {
    try {
      _isInitializing = true;
      _errorMessage = null;
      notifyListeners();

      // 1. Attempt Native Silent Sign-In (Mobile)
      if (kIsWeb == false &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        final success = await _gmailService.signInSilently();
        if (success) {
          _isAuthenticated = true;
          await _loadSessionMetadata();
          if (isSessionExpired) {
            await signOut(expired: true);
          } else {
            _scheduleTokenRefresh();
          }
          return;
        }
      }

      // 2. Attempt standard silent sign-in (Desktop fallback)
      final isSignedIn = await _gmailService.isSignedIn;

      if (isSignedIn) {
        // Load session metadata
        await _loadSessionMetadata();

        if (isSessionExpired) {
          debugPrint('AuthProvider: Session expired (30 days limit reached)');
          await signOut(expired: true);
        } else {
          final success = await _gmailService.signIn();
          _isAuthenticated = success;

          if (success) {
            // Schedule next refresh
            _scheduleTokenRefresh();
          }
        }
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize authentication: $e';
      _isAuthenticated = false;
      debugPrint('AuthProvider initialization error: $e');
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Check if the session is expired (30 days limit)
  bool get isSessionExpired {
    if (_initialLoginTime == null) return false;
    final now = DateTime.now();
    return now.difference(_initialLoginTime!) >= sessionDuration;
  }

  /// Authenticate with Google OAuth (Browser)
  Future<bool> authenticate(String clientId, String clientSecret) async {
    try {
      _errorMessage = null;
      notifyListeners();

      final success = await _gmailService.authenticate(clientId, clientSecret);
      _isAuthenticated = success;

      if (success) {
        // Save session metadata
        await _saveSessionMetadata(isNewLogin: true);
        // Schedule automatic refresh
        _scheduleTokenRefresh();
      }

      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Authentication failed: $e';
      _isAuthenticated = false;
      notifyListeners();
      debugPrint('AuthProvider authentication error: $e');
      return false;
    }
  }

  /// Authenticate with Native Google Sign-In (Mobile)
  Future<bool> authenticateNative() async {
    try {
      _errorMessage = null;
      notifyListeners();

      final success = await _gmailService.authenticateNative();
      _isAuthenticated = success;

      if (success) {
        await _saveSessionMetadata(isNewLogin: true);
        _scheduleTokenRefresh();
      }

      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Native authentication failed: $e';
      _isAuthenticated = false;
      notifyListeners();
      debugPrint('AuthProvider native authentication error: $e');
      return false;
    }
  }

  /// Sign out and clear all authentication data
  Future<void> signOut({bool expired = false}) async {
    try {
      await _gmailService.signOut();
      _cancelRefreshTimer();
      await _clearSessionMetadata();

      _isAuthenticated = false;
      _errorMessage = expired
          ? 'Access session has expired or been revoked'
          : null;
      _lastRefreshTime = null;
      _initialLoginTime = null;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Sign out failed: $e';
      notifyListeners();
      debugPrint('AuthProvider sign out error: $e');
    }
  }

  /// Manually trigger token refresh
  Future<bool> refreshToken() async {
    try {
      debugPrint('AuthProvider: Manually refreshing token...');

      if (!_isAuthenticated) {
        debugPrint('AuthProvider: Cannot refresh - not authenticated');
        return false;
      }

      if (isSessionExpired) {
        debugPrint('AuthProvider: Cannot refresh - session expired');
        await signOut(expired: true);
        return false;
      }

      _errorMessage = null;
      notifyListeners();

      // Use signIn() to reload and refresh credentials
      final success = await _gmailService.signIn();

      if (success) {
        await _saveSessionMetadata();
        _scheduleTokenRefresh();
        debugPrint('AuthProvider: Token refresh successful');
      } else {
        _errorMessage = 'Token refresh failed - may need to re-authenticate';
        _isAuthenticated = false;
        debugPrint('AuthProvider: Token refresh failed');
      }

      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Token refresh error: $e';
      _isAuthenticated = false;
      notifyListeners();
      debugPrint('AuthProvider: Token refresh error: $e');
      return false;
    }
  }

  /// Fetch OTP from Gmail
  Future<String?> fetchOTP() async {
    if (!_isAuthenticated) {
      _errorMessage = 'Not authenticated. Please sign in first.';
      notifyListeners();
      return null;
    }

    if (isSessionExpired) {
      _errorMessage = 'Access session has expired or been revoked';
      await signOut(expired: true);
      return null;
    }

    try {
      _errorMessage = null;
      notifyListeners();

      return await _gmailService.fetchOTPFromGmail();
    } catch (e) {
      _errorMessage = 'Failed to fetch OTP: $e';
      notifyListeners();
      debugPrint('AuthProvider: OTP fetch error: $e');
      return null;
    }
  }

  /// Schedule automatic token refresh
  void _scheduleTokenRefresh() {
    _cancelRefreshTimer();

    // Calculate time until next refresh
    final now = DateTime.now();
    final nextRefresh = (_lastRefreshTime ?? now).add(refreshInterval);
    final timeUntilRefresh = nextRefresh.difference(now);

    // If the next refresh is in the past, refresh now
    if (timeUntilRefresh.isNegative) {
      debugPrint('AuthProvider: Token refresh overdue, refreshing immediately');
      refreshToken();
      return;
    }

    debugPrint(
      'AuthProvider: Scheduling token refresh in ${timeUntilRefresh.inDays} days',
    );

    _refreshTimer = Timer(timeUntilRefresh, () {
      debugPrint('AuthProvider: Automatic token refresh triggered');
      refreshToken();
    });
  }

  /// Cancel the refresh timer
  void _cancelRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Save session metadata to storage
  Future<void> _saveSessionMetadata({bool isNewLogin = false}) async {
    final now = DateTime.now();
    _lastRefreshTime = now;

    if (isNewLogin) {
      _initialLoginTime = now;
      await _storage.write(
        key: 'google_initial_login_time',
        value: now.toIso8601String(),
      );
    }

    // Store in secure storage
    await _storage.write(
      key: 'token_last_refresh',
      value: now.toIso8601String(),
    );
  }

  /// Load session metadata from storage
  Future<void> _loadSessionMetadata() async {
    try {
      final lastRefreshStr = await _storage.read(key: 'token_last_refresh');
      final initialLoginStr = await _storage.read(
        key: 'google_initial_login_time',
      );

      if (lastRefreshStr != null) {
        _lastRefreshTime = DateTime.parse(lastRefreshStr);
        debugPrint('AuthProvider: Loaded last refresh time: $_lastRefreshTime');
      }

      if (initialLoginStr != null) {
        _initialLoginTime = DateTime.parse(initialLoginStr);
        debugPrint(
          'AuthProvider: Loaded initial login time: $_initialLoginTime',
        );
      } else if (_lastRefreshTime != null) {
        // Migration: if initial login time is missing but we have a refresh time,
        // use refresh time as initial login time for now.
        _initialLoginTime = _lastRefreshTime;
        await _saveSessionMetadata(isNewLogin: true);
      }
    } catch (e) {
      debugPrint('AuthProvider: Failed to load refresh metadata: $e');
    }
  }

  /// Clear session metadata from storage
  Future<void> _clearSessionMetadata() async {
    await _storage.delete(key: 'token_last_refresh');
    await _storage.delete(key: 'google_initial_login_time');
  }

  @override
  void dispose() {
    _cancelRefreshTimer();
    super.dispose();
  }
}
