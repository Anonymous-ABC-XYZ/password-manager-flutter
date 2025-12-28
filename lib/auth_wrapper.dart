import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';
import 'main.dart';
import 'providers/auth_provider.dart';

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
  late Future<String?> _authKeyFuture;

  @override
  void initState() {
    super.initState();
    _authKeyFuture = _storage.read(key: 'authkey');
  }

  void _refreshAuthKey() {
    setState(() {
      _authKeyFuture = _storage.read(key: 'authkey');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while initializing
        if (authProvider.isInitializing) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        // Check for DuckDuckGo auth key
        return FutureBuilder<String?>(
          future: _authKeyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                body: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }

            final hasDuckAuth = snapshot.data != null;
            final isFullyAuthenticated =
                hasDuckAuth && authProvider.isAuthenticated;

            if (isFullyAuthenticated) {
              return MyHomePage(
                toggleTheme: widget.toggleTheme,
                isDark: widget.isDark,
              );
            }

            return SplashScreen(
              onAuthComplete: (context) {
                _refreshAuthKey();
              },
            );
          },
        );
      },
    );
  }
}
