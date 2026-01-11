import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:password_manager/core/utils/bento_constants.dart';
import 'package:password_manager/features/settings/theme_provider.dart';
import 'package:password_manager/features/settings/theme_model.dart';
import 'package:password_manager/features/auth/auth_provider.dart';
import 'package:password_manager/core/widgets/stitch_bottom_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _authController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _obscureAuthKey = true;

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
      });
    }
  }

  Future<void> _saveAuthKey() async {
    final key = _authController.text.trim();
    await _storage.write(key: 'authkey', value: key);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auth Key saved successfully')),
      );
      Navigator.pop(context); // Close sheet
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

        final newTheme = ThemeModel.fromJson(json);
        await themeProvider.addTheme(newTheme);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Theme "${newTheme.name}" uploaded successfully!'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error uploading theme: $e')));
        }
      }
    }
  }

  void _showAppearanceSheet() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    StitchBottomSheet.show(
      context: context,
      title: 'Theme',
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: themeProvider.availableThemes.length,
              itemBuilder: (context, index) {
                final theme = themeProvider.availableThemes[index];
                // We use Consumer to update the UI inside the sheet when theme changes
                return Consumer<ThemeProvider>(
                  builder: (context, provider, _) {
                    final isSelected = theme.name == provider.currentTheme.name;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: InkWell(
                        onTap: () => provider.setTheme(theme),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: BentoColors.of(context).inputBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? BentoColors.of(context).primary
                                  : BentoColors.of(context).inputBorder,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.backgroundDark,
                                  border: Border.all(
                                    color: BentoColors.of(context).inputBorder,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  theme.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: BentoStyles.body.copyWith(
                                    color: isSelected
                                        ? BentoColors.of(context).textWhite
                                        : BentoColors.of(context).textMuted,
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _uploadTheme,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Custom Theme'),
            style: OutlinedButton.styleFrom(
              foregroundColor: BentoColors.of(context).textWhite,
              side: BorderSide(color: BentoColors.of(context).inputBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAuthKeySheet() {
    StitchBottomSheet.show(
      context: context,
      title: 'DuckDuckGo API Key',
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              TextField(
                controller: _authController,
                obscureText: _obscureAuthKey,
                style: BentoStyles.mono.copyWith(
                  color: BentoColors.of(context).textWhite,
                ),
                decoration: InputDecoration(
                  labelText: 'Authorization Key',
                  labelStyle: BentoStyles.body.copyWith(
                    color: BentoColors.of(context).textMuted,
                  ),
                  filled: true,
                  fillColor: BentoColors.of(context).inputBg,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureAuthKey ? Icons.visibility : Icons.visibility_off,
                      color: BentoColors.of(context).textMuted,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureAuthKey = !_obscureAuthKey;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: BentoColors.of(context).inputBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: BentoColors.of(context).inputBorder,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAuthKey,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BentoColors.of(context).primary,
                    foregroundColor: BentoColors.of(context).onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save Key'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BentoColors.of(context).backgroundDark,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              'Settings',
              style: BentoStyles.header.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: BentoColors.of(context).textWhite,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 32),

            _buildSettingTile(
              context,
              icon: Icons.palette_outlined,
              title: 'Appearance',
              subtitle: 'Themes and colors',
              onTap: _showAppearanceSheet,
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              context,
              icon: Icons.shield_outlined,
              title: 'API Keys',
              subtitle: 'DuckDuckGo configuration',
              onTap: _showAuthKeySheet,
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              context,
              icon: Icons.account_circle_outlined,
              title: 'Google Account',
              subtitle: context.watch<AuthProvider>().isAuthenticated
                  ? 'Authenticated'
                  : 'Not authenticated',
              onTap: () {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                if (defaultTargetPlatform == TargetPlatform.android ||
                    defaultTargetPlatform == TargetPlatform.iOS) {
                  authProvider.authenticateNative();
                } else {
                  // Show current browser config or just inform
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Browser authentication is handled at startup.',
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            // Placeholder for future settings
            _buildSettingTile(
              context,
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Version 1.0.0',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: BentoColors.of(context).surfaceDark,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: BentoColors.of(context).surfaceHover,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: BentoColors.of(context).primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: BentoStyles.body.copyWith(
                        color: BentoColors.of(context).textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: BentoStyles.body.copyWith(
                        color: BentoColors.of(context).textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: BentoColors.of(context).textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
