import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'splash_constants.dart';
import 'bento_constants.dart';

class SplashScreen extends StatefulWidget {
  final Function(BuildContext)? onAuthComplete;

  const SplashScreen({super.key, this.onAuthComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TextEditingController _duckAuthController = TextEditingController();
  final TextEditingController _clientIdController = TextEditingController();
  final TextEditingController _clientSecretController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isGoogleSignedIn = false;
  bool _isDuckAuthSaved = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingAuth();
  }

  Future<void> _checkExistingAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

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
      _clientIdController.text = clientId;
      _clientSecretController.text = clientSecret;

      if (authProvider.isAuthenticated) {
        setState(() {
          _isGoogleSignedIn = true;
        });
      }
    }
    
    if (_isGoogleSignedIn && _isDuckAuthSaved) {
       // Ideally wait a moment or show a "Proceeding..." state
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final clientId = _clientIdController.text.trim();
    final clientSecret = _clientSecretController.text.trim();

    if (clientId.isEmpty || clientSecret.isEmpty) {
      _showGoogleConfigDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await authProvider.authenticate(clientId, clientSecret);

    setState(() {
      _isLoading = false;
      if (success) {
        _isGoogleSignedIn = true;
      }
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully signed in to Google!'), backgroundColor: SplashColors.primary),
      );
      _checkCompletion();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign-In failed.'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleDuckAuthSave() async {
    final authKey = _duckAuthController.text.trim();
    if (authKey.isEmpty) return;

    await _storage.write(key: 'authkey', value: authKey);
    setState(() {
      _isDuckAuthSaved = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('DuckDuckGo auth key saved'), backgroundColor: SplashColors.primary),
      );
      Navigator.of(context).pop(); // Close dialog
      _checkCompletion();
    }
  }

  void _checkCompletion() {
    if (_isGoogleSignedIn && _isDuckAuthSaved) {
       if (widget.onAuthComplete != null) {
          widget.onAuthComplete!(context);
       }
    }
  }

  void _showGoogleConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SplashColors.surfaceDark,
        title: Text('Configure Google OAuth', style: BentoStyles.header.copyWith(color: SplashColors.textWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _clientIdController,
              style: BentoStyles.body.copyWith(color: SplashColors.textWhite),
              decoration: InputDecoration(
                labelText: 'Client ID',
                labelStyle: BentoStyles.body.copyWith(color: SplashColors.textMuted),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: SplashColors.textMuted)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: SplashColors.primary)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _clientSecretController,
              obscureText: true,
              style: BentoStyles.body.copyWith(color: SplashColors.textWhite),
              decoration: InputDecoration(
                labelText: 'Client Secret',
                labelStyle: BentoStyles.body.copyWith(color: SplashColors.textMuted),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: SplashColors.textMuted)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: SplashColors.primary)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: BentoStyles.body.copyWith(color: SplashColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleGoogleSignIn();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SplashColors.primary,
              foregroundColor: SplashColors.onPrimary,
            ),
            child: Text('Sign In', style: BentoStyles.body.copyWith(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDuckConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SplashColors.surfaceDark,
        title: Text('Configure DuckDuckGo', style: BentoStyles.header.copyWith(color: SplashColors.textWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _duckAuthController,
              obscureText: true,
              style: BentoStyles.body.copyWith(color: SplashColors.textWhite),
              decoration: InputDecoration(
                labelText: 'Authorization Key',
                labelStyle: BentoStyles.body.copyWith(color: SplashColors.textMuted),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: SplashColors.textMuted)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: SplashColors.primary)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: BentoStyles.body.copyWith(color: SplashColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: _handleDuckAuthSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: SplashColors.primary,
              foregroundColor: SplashColors.onPrimary,
            ),
            child: Text('Save', style: BentoStyles.body.copyWith(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashColors.backgroundDark,
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                color: SplashColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(blurRadius: 120, color: SplashColors.primary)],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                color: SplashColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(blurRadius: 100, color: SplashColors.primary)],
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),

                  // Main Card
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: SplashColors.surfaceDark,
                      borderRadius: SplashStyles.borderRadius,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (context.watch<AuthProvider>().errorMessage != null)
                          Container(
                            margin: const EdgeInsets.bottom(24),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    context.watch<AuthProvider>().errorMessage!,
                                    style: BentoStyles.body.copyWith(color: Colors.redAccent, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          "Let's get you secured",
                          textAlign: TextAlign.center,
                          style: BentoStyles.header.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Your digital safe house is ready. Choose your preferred secure method to create your encrypted vault.",
                          textAlign: TextAlign.center,
                          style: BentoStyles.body.copyWith(
                            color: SplashColors.textMuted,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Auth Options
                        _buildAuthCard(
                          icon: Icons.g_mobiledata, // Placeholder for Google Logo
                          title: 'Continue with Google',
                          subtitle: 'Fast and secure access',
                          color: const Color(0xFF4285F4),
                          isChecked: _isGoogleSignedIn,
                          onTap: _isGoogleSignedIn ? null : (_clientIdController.text.isEmpty ? _showGoogleConfigDialog : _handleGoogleSignIn),
                        ),
                        const SizedBox(height: 16),
                        _buildAuthCard(
                          icon: Icons.shield,
                          title: 'Continue with DuckDuckGo',
                          subtitle: 'Privacy-focused protection',
                          color: const Color(0xFFDE5833),
                          isChecked: _isDuckAuthSaved,
                          onTap: _showDuckConfigDialog,
                        ),
                        
                        const SizedBox(height: 24),
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white10)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('OR', style: TextStyle(color: Colors.white30, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            Expanded(child: Divider(color: Colors.white10)),
                          ],
                        ),
                         const SizedBox(height: 24),
                         
                         TextButton.icon(
                           onPressed: () {
                             if (_isGoogleSignedIn && _isDuckAuthSaved) {
                               _checkCompletion();
                             } else {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Please complete setup first.')),
                               );
                             }
                           },
                           icon: const Icon(Icons.password, color: SplashColors.textMuted),
                           label: Text(
                             'Enter App',
                             style: BentoStyles.body.copyWith(color: SplashColors.textWhite),
                           ),
                         ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text(
                    'Terms of Service • Privacy Policy',
                    style: TextStyle(color: Colors.white30, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: SplashColors.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isChecked,
    VoidCallback? onTap,
  }) {
    return Material(
      color: SplashColors.surfaceHover,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        hoverColor: SplashColors.surfaceHover.withValues(alpha: 0.8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(isChecked ? Icons.check : icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: BentoStyles.body.copyWith(
                        color: SplashColors.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: BentoStyles.body.copyWith(
                        color: SplashColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}