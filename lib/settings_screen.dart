import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'bento_constants.dart';
import 'providers/theme_provider.dart';
import 'theme_model.dart';

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

  Future<void> _uploadTheme() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      try {
        final file = result.files.single;
        final content = utf8.decode(file.bytes!);
        final json = jsonDecode(content) as Map<String, dynamic>;

        // Basic validation
        final requiredKeys = ['name', 'primary', 'onPrimary', 'backgroundDark', 'surfaceDark', 'textWhite', 'textMuted'];
        final missingKeys = requiredKeys.where((key) => !json.containsKey(key)).toList();

        if (missingKeys.isNotEmpty) {
          throw Exception('Invalid theme file. Missing required keys: ${missingKeys.join(', ')}');
        }
        
        final newTheme = ThemeModel.fromJson(json);
        await themeProvider.addTheme(newTheme);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Theme "${newTheme.name}" uploaded successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading theme: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: BentoColors.of(context).primary));
    }

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: BentoColors.of(context).backgroundDark,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs
            Row(
              children: [
                Text('Settings', style: BentoStyles.body.copyWith(color: BentoColors.of(context).textMuted, fontSize: 14)),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, size: 16, color: BentoColors.of(context).textMuted),
                const SizedBox(width: 8),
                Text('Appearance & Auth', style: BentoStyles.body.copyWith(color: BentoColors.of(context).textWhite, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              'Appearance & Auth',
              style: BentoStyles.header.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: BentoColors.of(context).textWhite,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Manage your themes, Master Auth Key and advanced security preferences. Keep this key safe; it's the lifeline to your data.",
              style: BentoStyles.body.copyWith(color: BentoColors.of(context).textMuted, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),

            // Appearance Card
            Container(
              decoration: BoxDecoration(
                color: BentoColors.of(context).surfaceDark,
                borderRadius: BentoStyles.borderRadius,
                border: Border.all(color: BentoColors.of(context).inputBorder.withValues(alpha: 0.5)),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: BentoColors.of(context).primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.color_lens, color: BentoColors.of(context).primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Appearance',
                        style: BentoStyles.header.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: BentoColors.of(context).textWhite,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ...themeProvider.availableThemes.map((theme) {
                    return RadioListTile<String>(
                      title: Text(theme.name, style: TextStyle(color: BentoColors.of(context).textWhite)),
                      value: theme.name,
                      groupValue: themeProvider.currentTheme.name,
                      onChanged: (value) {
                        if (value != null) {
                          themeProvider.setTheme(theme);
                        }
                      },
                      activeColor: BentoColors.of(context).primary,
                      toggleable: false, // Ensures a selection is always made.
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.trailing, // Puts radio button on the right
                      secondary: Container( // Visual indicator for selected theme
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: theme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: BentoColors.of(context).primary, width: 2),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _uploadTheme,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Theme'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BentoColors.of(context).secondary,
                      foregroundColor: BentoColors.of(context).onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: BentoStyles.body.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Master Auth Key Card
            Container(
              decoration: BoxDecoration(
                color: BentoColors.of(context).surfaceDark,
                borderRadius: BentoStyles.borderRadius,
                border: Border.all(color: BentoColors.of(context).inputBorder.withValues(alpha: 0.5)),
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
                                    color: BentoColors.of(context).primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.shield, color: BentoColors.of(context).primary, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'DuckDuckGo Key',
                                  style: BentoStyles.header.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: BentoColors.of(context).textWhite,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'This key is used to generate private email aliases via DuckDuckGo.',
                              style: BentoStyles.body.copyWith(color: BentoColors.of(context).textMuted, fontSize: 14, height: 1.5),
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
                          color: BentoColors.of(context).textWhite,
                          letterSpacing: 1.0,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: BentoColors.of(context).inputBg,
                          prefixIcon: Icon(Icons.key, color: BentoColors.of(context).textMuted),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: BentoColors.of(context).inputBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: BentoColors.of(context).inputBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: BentoColors.of(context).primary),
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
                                color: BentoColors.of(context).textMuted,
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
                                backgroundColor: BentoColors.of(context).primary,
                                foregroundColor: BentoColors.of(context).onPrimary,
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
                        backgroundColor: BentoColors.of(context).secondary,
                        foregroundColor: BentoColors.of(context).onPrimary,
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