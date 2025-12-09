import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'gmail_service.dart';

class SplashScreen extends StatefulWidget {
  final Function(BuildContext, GmailService)? onAuthComplete;

  const SplashScreen({super.key, this.onAuthComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TextEditingController _duckAuthController = TextEditingController();
  final TextEditingController _clientIdController = TextEditingController();
  final TextEditingController _clientSecretController = TextEditingController();
  final GmailService _gmailService = GmailService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isGoogleSignedIn = false;
  bool _isDuckAuthSaved = false;
  bool _isLoading = false;
  bool _showClientIdInput = false;

  @override
  void initState() {
    super.initState();
    _checkExistingAuth();
  }

  Future<void> _checkExistingAuth() async {
    final duckAuth = await _storage.read(key: 'authkey');
    if (duckAuth != null) {
      setState(() {
        _isDuckAuthSaved = true;
        _duckAuthController.text = duckAuth;
      });
    }

    final clientId = await _storage.read(key: 'google_client_id');
    final clientSecret = await _storage.read(key: 'google_client_secret');

    if (clientId != null && clientSecret != null) {
      setState(() {
        _clientIdController.text = clientId;
        _clientSecretController.text = clientSecret;
        _showClientIdInput = false;
      });

      final isSignedIn = await _gmailService.isSignedIn;
      if (isSignedIn) {
        final signInSuccess = await _gmailService.signIn();
        if (signInSuccess) {
          setState(() {
            _isGoogleSignedIn = true;
          });
        }
      }
    } else {
      setState(() {
        _showClientIdInput = true;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final clientId = _clientIdController.text.trim();
    final clientSecret = _clientSecretController.text.trim();

    if (clientId.isEmpty || clientSecret.isEmpty) {
      setState(() {
        _showClientIdInput = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Please enter OAuth Client ID and Secret first',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await _gmailService.authenticate(clientId, clientSecret);

    setState(() {
      _isLoading = false;
      if (success) {
        _isGoogleSignedIn = true;
        _showClientIdInput = false;
      }
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Successfully signed in to Google!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Google Sign-In failed. Check your credentials and try again.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleDuckAuthSave() async {
    final authKey = _duckAuthController.text.trim();
    if (authKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid auth key'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    await _storage.write(key: 'authkey', value: authKey);
    setState(() {
      _isDuckAuthSaved = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('DuckDuckGo auth key saved'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  Future<void> _handleContinue() async {
    if (!_isGoogleSignedIn || !_isDuckAuthSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please complete both authentication steps'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (widget.onAuthComplete != null) {
      widget.onAuthComplete!(context, _gmailService);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.primaryContainer,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outlined, size: 80, color: theme.primary),
                const SizedBox(height: 24),
                Text(
                  'Password Manager',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 48),
                _buildGoogleSignInCard(theme),
                const SizedBox(height: 24),
                _buildDuckAuthCard(theme),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isGoogleSignedIn && _isDuckAuthSaved
                      ? _handleContinue
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: theme.onPrimary,
                    disabledBackgroundColor: theme.surfaceContainerHighest,
                    disabledForegroundColor: theme.onSurface.withOpacity(0.5),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _isGoogleSignedIn && _isDuckAuthSaved ? 2 : 0,
                  ),
                  child: Text(
                    'Continue to App',
                    style: GoogleFonts.bricolageGrotesque(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInCard(ColorScheme theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.email, color: theme.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                'Google Account',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isGoogleSignedIn)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: theme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Signed in successfully',
                      style: GoogleFonts.bricolageGrotesque(
                        color: theme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (!_showClientIdInput) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () async {
                      setState(() {
                        _isGoogleSignedIn = false;
                        _showClientIdInput = true;
                      });
                      await _gmailService.signOut();
                    },
                    icon: Icon(
                      Icons.settings,
                      size: 16,
                      color: theme.onSurface.withOpacity(0.7),
                    ),
                    label: Text(
                      'Reconfigure credentials',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 12,
                        color: theme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign in to fetch OTP codes from Gmail',
                  style: GoogleFonts.bricolageGrotesque(
                    color: theme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                if (_showClientIdInput) ...[
                  TextField(
                    controller: _clientIdController,
                    style: GoogleFonts.bricolageGrotesque(
                      color: theme.onSecondary,
                    ),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.primary, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.badge, color: theme.onSecondary),
                      hintText: 'OAuth Client ID',
                      hintStyle: GoogleFonts.bricolageGrotesque(
                        color: theme.onSurface.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: theme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _clientSecretController,
                    obscureText: true,
                    style: GoogleFonts.bricolageGrotesque(
                      color: theme.onSecondary,
                    ),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.primary, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.vpn_key, color: theme.onSecondary),
                      hintText: 'OAuth Client Secret',
                      hintStyle: GoogleFonts.bricolageGrotesque(
                        color: theme.onSurface.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: theme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.login),
                  label: Text(
                    _isLoading ? 'Signing in...' : 'Sign in with Google',
                    style: GoogleFonts.bricolageGrotesque(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: theme.onPrimary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDuckAuthCard(ColorScheme theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: theme.secondary, size: 28),
              const SizedBox(width: 12),
              Text(
                'DuckDuckGo Email',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isDuckAuthSaved)
            Row(
              children: [
                Icon(Icons.check_circle, color: theme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Auth key configured',
                  style: GoogleFonts.bricolageGrotesque(
                    color: theme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your DuckDuckGo authorization key',
                  style: GoogleFonts.bricolageGrotesque(
                    color: theme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _duckAuthController,
                  obscureText: true,
                  style: GoogleFonts.bricolageGrotesque(
                    color: theme.onSecondary,
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.primary, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.key, color: theme.onSecondary),
                    hintText: 'Authorization Key',
                    hintStyle: GoogleFonts.bricolageGrotesque(
                      color: theme.onSurface.withOpacity(0.5),
                      fontSize: 15,
                    ),
                    filled: true,
                    fillColor: theme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _handleDuckAuthSave,
                  icon: const Icon(Icons.save),
                  label: Text(
                    'Save Auth Key',
                    style: GoogleFonts.bricolageGrotesque(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.secondary,
                    foregroundColor: theme.onSecondary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _duckAuthController.dispose();
    _clientIdController.dispose();
    _clientSecretController.dispose();
    super.dispose();
  }
}
