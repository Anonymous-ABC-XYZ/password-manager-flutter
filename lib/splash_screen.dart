import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'bento_constants.dart';
import 'stitch_bottom_sheet.dart';

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
      _showGoogleConfigSheet();
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
        SnackBar(content: const Text('Successfully signed in to Google!'), backgroundColor: BentoColors.of(context).primary),
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
        SnackBar(content: const Text('DuckDuckGo auth key saved'), backgroundColor: BentoColors.of(context).primary),
      );
      Navigator.of(context).pop(); // Close sheet
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

  void _showGoogleConfigSheet() {
    StitchBottomSheet.show(
      context: context,
      title: 'Configure Google OAuth',
      child: Column(
        children: [
          TextField(
            controller: _clientIdController,
            style: BentoStyles.body.copyWith(color: BentoColors.of(context).textWhite),
            decoration: InputDecoration(
              labelText: 'Client ID',
              labelStyle: BentoStyles.body.copyWith(color: BentoColors.of(context).textMuted),
              filled: true,
              fillColor: BentoColors.of(context).inputBg,
              border: OutlineInputBorder(
                borderRadius: BentoStyles.inputBorderRadius,
                borderSide: BorderSide(color: BentoColors.of(context).inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BentoStyles.inputBorderRadius,
                borderSide: BorderSide(color: BentoColors.of(context).inputBorder),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _clientSecretController,
            obscureText: true,
            style: BentoStyles.body.copyWith(color: BentoColors.of(context).textWhite),
            decoration: InputDecoration(
              labelText: 'Client Secret',
              labelStyle: BentoStyles.body.copyWith(color: BentoColors.of(context).textMuted),
              filled: true,
              fillColor: BentoColors.of(context).inputBg,
              border: OutlineInputBorder(
                borderRadius: BentoStyles.inputBorderRadius,
                borderSide: BorderSide(color: BentoColors.of(context).inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BentoStyles.inputBorderRadius,
                borderSide: BorderSide(color: BentoColors.of(context).inputBorder),
              ),
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            _handleGoogleSignIn();
          },
          style: FilledButton.styleFrom(
            backgroundColor: BentoColors.of(context).primary,
            foregroundColor: BentoColors.of(context).onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Sign In'),
        ),
      ],
    );
  }

  void _showDuckConfigSheet() {
    StitchBottomSheet.show(
      context: context,
      title: 'Configure DuckDuckGo',
      child: Column(
        children: [
          TextField(
            controller: _duckAuthController,
            obscureText: true,
            style: BentoStyles.body.copyWith(color: BentoColors.of(context).textWhite),
            decoration: InputDecoration(
              labelText: 'Authorization Key',
              labelStyle: BentoStyles.body.copyWith(color: BentoColors.of(context).textMuted),
              filled: true,
              fillColor: BentoColors.of(context).inputBg,
              border: OutlineInputBorder(
                borderRadius: BentoStyles.inputBorderRadius,
                borderSide: BorderSide(color: BentoColors.of(context).inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BentoStyles.inputBorderRadius,
                borderSide: BorderSide(color: BentoColors.of(context).inputBorder),
              ),
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: _handleDuckAuthSave,
          style: FilledButton.styleFrom(
            backgroundColor: BentoColors.of(context).primary,
            foregroundColor: BentoColors.of(context).onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BentoColors.of(context).backgroundDark,
      body: Stack(
        children: [
          // Background Blobs (Stitch Aesthetic)
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    BentoColors.of(context).primary.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    BentoColors.of(context).secondary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (context.watch<AuthProvider>().errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
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
                    
                  const Spacer(),
                  
                  // Branding
                  Icon(
                    Icons.lock_person_rounded,
                    size: 64,
                    color: BentoColors.of(context).primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Let's get you secured",
                    textAlign: TextAlign.center,
                    style: BentoStyles.header.copyWith(
                      fontSize: 36,
                      height: 1.1,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Your digital safe house is ready. Choose your secure method to enter.",
                    textAlign: TextAlign.center,
                    style: BentoStyles.body.copyWith(
                      color: BentoColors.of(context).textMuted,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  
                  const Spacer(),

                  // Auth Options (Full Bleed / Stretched)
                  _buildAuthButton(
                    context,
                    icon: Icons.g_mobiledata, 
                    title: 'Continue with Google',
                    color: const Color(0xFF4285F4),
                    isChecked: _isGoogleSignedIn,
                    onTap: _isGoogleSignedIn ? null : (_clientIdController.text.isEmpty ? _showGoogleConfigSheet : _handleGoogleSignIn),
                  ),
                  const SizedBox(height: 16),
                  _buildAuthButton(
                    context,
                    icon: Icons.shield,
                    title: 'Continue with DuckDuckGo',
                    color: const Color(0xFFDE5833),
                    isChecked: _isDuckAuthSaved,
                    onTap: _showDuckConfigSheet,
                  ),
                  
                  const SizedBox(height: 32),
                  
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
                     icon: Icon(Icons.login, color: BentoColors.of(context).textMuted),
                     label: Text(
                       'Enter App',
                       style: BentoStyles.body.copyWith(color: BentoColors.of(context).textWhite),
                     ),
                   ),
                   
                   const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(child: CircularProgressIndicator(color: BentoColors.of(context).primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required bool isChecked,
    VoidCallback? onTap,
  }) {
    final bento = BentoColors.of(context);
    
    return Material(
      color: bento.surfaceHover,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
             border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
             borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(isChecked ? Icons.check_circle : icon, color: isChecked ? bento.success : color, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: BentoStyles.body.copyWith(
                    color: bento.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!isChecked)
                Icon(Icons.arrow_forward, color: bento.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
