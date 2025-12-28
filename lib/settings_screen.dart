import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'bento_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _authController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _obscureAuthKey = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthKey();
  }

  Future<void> _loadAuthKey() async {
    final key = await _storage.read(key: 'authkey');
    if (mounted) {
      setState(() {
        _authController.text = key ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAuthKey() async {
    final key = _authController.text.trim();
    if (key.isNotEmpty) {
      await _storage.write(key: 'authkey', value: key);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Auth Key saved successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: BentoColors.primary));
    }

    return Scaffold(
      backgroundColor: BentoColors.backgroundDark,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs
            Row(
              children: [
                Text('Settings', style: BentoStyles.body.copyWith(color: BentoColors.textMuted, fontSize: 14)),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 16, color: BentoColors.textMuted),
                const SizedBox(width: 8),
                Text('Encryption & Auth', style: BentoStyles.body.copyWith(color: BentoColors.textWhite, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              'Encryption & Auth',
              style: BentoStyles.header.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: BentoColors.textWhite,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Manage your Master Auth Key and advanced security preferences. Keep this key safe; it's the lifeline to your data.",
              style: BentoStyles.body.copyWith(color: BentoColors.textMuted, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),

            // Master Auth Key Card
            Container(
              decoration: BoxDecoration(
                color: BentoColors.surfaceDark,
                borderRadius: BentoStyles.borderRadius,
                border: Border.all(color: BentoColors.inputBorder.withValues(alpha: 0.5)),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: BentoColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.shield, color: BentoColors.primary, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'DuckDuckGo Key',
                                  style: BentoStyles.header.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: BentoColors.textWhite,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'This key is used to generate private email aliases via DuckDuckGo.',
                              style: BentoStyles.body.copyWith(color: BentoColors.textMuted, fontSize: 14, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Auth Key Input
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextField(
                        controller: _authController,
                        obscureText: _obscureAuthKey,
                        onSubmitted: (_) => _saveAuthKey(),
                        style: BentoStyles.mono.copyWith(
                          color: BentoColors.textWhite,
                          letterSpacing: 1.0,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: BentoColors.inputBg,
                          prefixIcon: const Icon(Icons.key, color: BentoColors.textMuted),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: BentoColors.inputBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: BentoColors.inputBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: BentoColors.primary),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _obscureAuthKey ? Icons.visibility_off : Icons.visibility,
                                color: BentoColors.textMuted,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureAuthKey = !_obscureAuthKey;
                                });
                              },
                            ),
                            const SizedBox(width: 4),
                            ElevatedButton.icon(
                              onPressed: () {
                                _saveAuthKey(); 
                                Clipboard.setData(ClipboardData(text: _authController.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copied to clipboard')),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text('Copy'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: BentoColors.primary,
                                foregroundColor: BentoColors.onPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                textStyle: BentoStyles.body.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Save Action
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _saveAuthKey,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Key'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BentoColors.secondary,
                        foregroundColor: BentoColors.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: BentoStyles.body.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}