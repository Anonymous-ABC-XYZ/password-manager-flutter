import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'splash_screen.dart';
import 'main.dart';
import 'gmail_service.dart';

class AuthWrapper extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;

  const AuthWrapper({
    super.key,
    required this.toggleTheme,
    required this.isDark,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final GmailService _gmailService = GmailService();

  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final duckAuth = await _storage.read(key: 'authkey');
    final hasGoogleAuth = await _gmailService.isSignedIn;

    if (duckAuth != null && hasGoogleAuth) {
      final signInSuccess = await _gmailService.signIn();
      setState(() {
        _isAuthenticated = signInSuccess;
        _isCheckingAuth = false;
      });
    } else {
      setState(() {
        _isAuthenticated = false;
        _isCheckingAuth = false;
      });
    }
  }

  Future<void> _handleAuthComplete() async {
    setState(() {
      _isAuthenticated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (_isAuthenticated) {
      return MyHomePage(
        toggleTheme: widget.toggleTheme,
        isDark: widget.isDark,
        gmailService: _gmailService,
      );
    }

    return SplashScreen(
      onAuthComplete: (context, gmailService) {
        _handleAuthComplete();
      },
    );
  }
}
