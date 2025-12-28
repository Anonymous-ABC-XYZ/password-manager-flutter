import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../gmail_service.dart';

class AuthProvider extends ChangeNotifier {
  final GmailService _gmailService = GmailService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  bool _isInitializing = true;
  String? _errorMessage;
  Timer? _refreshTimer;
  DateTime? _lastRefreshTime;

  // Refresh interval: 2 weeks
  static const Duration refreshInterval = Duration(days: 14);

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  GmailService get gmailService => _gmailService;
  DateTime? get lastRefreshTime => _lastRefreshTime;

  AuthProvider() {
    _initialize();
  }

  /// Initialize authentication state on app startup
  Future<void> _initialize() async {
    try {
      _isInitializing = true;
      _errorMessage = null;
      notifyListeners();

      // Attempt silent sign-in with stored credentials
      final isSignedIn = await _gmailService.isSignedIn;

      if (isSignedIn) {
        final success = await _gmailService.signIn();
        _isAuthenticated = success;

        if (success) {
          // Load last refresh time from storage
          await _loadRefreshMetadata();
          // Schedule next refresh
          _scheduleTokenRefresh();
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

  /// Authenticate with Google OAuth
  Future<bool> authenticate(String clientId, String clientSecret) async {
    try {
      _errorMessage = null;
      notifyListeners();

      final success = await _gmailService.authenticate(clientId, clientSecret);
      _isAuthenticated = success;

      if (success) {
        // Save refresh metadata
        await _saveRefreshMetadata();
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

  /// Sign out and clear all authentication data
  Future<void> signOut() async {
    try {
      await _gmailService.signOut();
      _cancelRefreshTimer();
      await _clearRefreshMetadata();

      _isAuthenticated = false;
      _errorMessage = null;
      _lastRefreshTime = null;

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
      _errorMessage = null;
      notifyListeners();

      // Use signIn() to reload and refresh credentials
      final success = await _gmailService.signIn();

      if (success) {
        await _saveRefreshMetadata();
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

    debugPrint('AuthProvider: Scheduling token refresh in ${timeUntilRefresh.inDays} days');

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

  /// Save refresh metadata to storage
  Future<void> _saveRefreshMetadata() async {
    final now = DateTime.now();
    _lastRefreshTime = now;

    // Store in secure storage
    await _storage.write(
      key: 'token_last_refresh',
      value: now.toIso8601String(),
    );
  }

  /// Load refresh metadata from storage
  Future<void> _loadRefreshMetadata() async {
    try {
      final lastRefreshStr = await _storage.read(
        key: 'token_last_refresh',
      );

      if (lastRefreshStr != null) {
        _lastRefreshTime = DateTime.parse(lastRefreshStr);
        debugPrint('AuthProvider: Loaded last refresh time: $_lastRefreshTime');
      }
    } catch (e) {
      debugPrint('AuthProvider: Failed to load refresh metadata: $e');
    }
  }

  /// Clear refresh metadata from storage
  Future<void> _clearRefreshMetadata() async {
    await _storage.delete(key: 'token_last_refresh');
  }

  @override
  void dispose() {
    _cancelRefreshTimer();
    super.dispose();
  }
}
