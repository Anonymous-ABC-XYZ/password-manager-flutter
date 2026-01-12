import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_manager/features/vault/credential_model.dart';
import 'package:password_manager/core/dbinit.dart';
import 'package:password_manager/core/utils/bento_constants.dart';
import 'package:password_manager/features/vault/home_screen.dart';

class CredentialFocusCard extends StatefulWidget {
  final Credential credential;
  final VoidCallback onDeleteSuccess;

  const CredentialFocusCard({
    super.key,
    required this.credential,
    required this.onDeleteSuccess,
  });

  @override
  State<CredentialFocusCard> createState() => _CredentialFocusCardState();
}

class _CredentialFocusCardState extends State<CredentialFocusCard> {
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
      widget.onDeleteSuccess();
      if (mounted) {
        Navigator.pop(context); // Close the focus card
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
      widget.onDeleteSuccess(); // Reuse refresh logic
      if (mounted) {
        Navigator.pop(context); // Close the focus card
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0xFF1E1E2E);
    const sapphireColor = Color(0xFF74C7EC);
    const mauveColor = Color(0xFFCBA6F7);
    const textColor = Color(0xFFCDD6F4);
    const surfaceColor = Color(0xFF313244);
    final errorColor = BentoColors.of(context).error;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: sapphireColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sapphireColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield,
                      color: sapphireColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.credential.website,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildField(
                label: 'Username',
                value: widget.credential.username,
                accentColor: sapphireColor,
                textColor: textColor,
                surfaceColor: surfaceColor,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Email',
                value: widget.credential.email,
                accentColor: sapphireColor,
                textColor: textColor,
                surfaceColor: surfaceColor,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Password',
                value: widget.credential.password,
                isPassword: true,
                accentColor: mauveColor,
                textColor: textColor,
                surfaceColor: surfaceColor,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _editCredential,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: sapphireColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: sapphireColor.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _deleteCredential,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: errorColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: errorColor.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String value,
    required Color accentColor,
    required Color textColor,
    required Color surfaceColor,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: accentColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isPassword && _obscurePassword ? '••••••••••••' : value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isPassword)
                IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: textColor.withOpacity(0.7),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(Icons.copy, color: accentColor, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Copied $label')));
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
