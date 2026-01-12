import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_manager/features/vault/credential_model.dart';
import 'package:password_manager/core/utils/bento_constants.dart';
import 'package:password_manager/core/dbinit.dart';
import 'package:password_manager/features/vault/home_screen.dart';

class CredentialDetailScreen extends StatefulWidget {
  final Credential credential;

  const CredentialDetailScreen({super.key, required this.credential});

  @override
  State<CredentialDetailScreen> createState() => _CredentialDetailScreenState();
}

class _CredentialDetailScreenState extends State<CredentialDetailScreen> {
  bool _obscurePassword = true;

  Future<void> _deleteCredential() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: BentoColors.of(context).surfaceDark,
            title: Text(
              'Delete Credential',
              style: TextStyle(color: BentoColors.of(context).textWhite),
            ),
            content: Text(
              'Are you sure you want to delete the credentials for ${widget.credential.website}?',
              style: TextStyle(color: BentoColors.of(context).textMuted),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: BentoColors.of(context).textMuted),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: BentoColors.of(context).error),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final db = await InitDB().dB;
      await db.delete(
        'demo',
        where: 'Website = ?',
        whereArgs: [widget.credential.website],
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _editCredential() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => HomeScreen(initialCredential: widget.credential),
      ),
    );

    if (result == true) {
      if (mounted) {
        Navigator.pop(context, true); // Refresh PasswordsPage
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BentoColors.of(context).backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: BentoColors.of(context).textWhite,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.credential.website,
          style: BentoStyles.header.copyWith(
            color: BentoColors.of(context).textWhite,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: BentoColors.of(context).primary,
            ),
            onPressed: _editCredential,
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: BentoColors.of(context).error,
            ),
            onPressed: _deleteCredential,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Icon / Hero
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: BentoColors.of(context).primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: BentoColors.of(context).primary.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.language, // Placeholder for favicon
                size: 40,
                color: BentoColors.of(context).primary,
              ),
            ),
            const SizedBox(height: 32),

            // Details Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: BentoColors.of(context).surfaceDark,
                borderRadius: BentoStyles.borderRadius,
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    label: 'Username',
                    value: widget.credential.username,
                    icon: Icons.person_outline,
                  ),
                  const Divider(height: 32, color: Colors.white10),
                  _buildDetailRow(
                    context,
                    label: 'Email',
                    value: widget.credential.email,
                    icon: Icons.email_outlined,
                  ),
                  const Divider(height: 32, color: Colors.white10),
                  _buildDetailRow(
                    context,
                    label: 'Password',
                    value: widget.credential.password,
                    isPassword: true,
                    icon: Icons.lock_outline,
                  ),
                  if (widget.credential.category != null) ...[
                    const Divider(height: 32, color: Colors.white10),
                    _buildDetailRow(
                      context,
                      label: 'Category',
                      value: widget.credential.category!,
                      icon: Icons.folder_open,
                      allowCopy: false,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    bool isPassword = false,
    bool allowCopy = true,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: BentoColors.of(context).surfaceHover,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: BentoColors.of(context).textMuted, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: BentoStyles.body.copyWith(
                  color: BentoColors.of(context).textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isPassword && _obscurePassword ? '••••••••••••' : value,
                style: BentoStyles.body.copyWith(
                  color: BentoColors.of(context).textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (isPassword)
          IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: BentoColors.of(context).textMuted,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        if (allowCopy)
          IconButton(
            icon: Icon(
              Icons.copy,
              color: BentoColors.of(context).textMuted,
              size: 20,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Copied $label')));
            },
          ),
      ],
    );
  }
}
