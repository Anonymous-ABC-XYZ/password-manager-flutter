import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bento_constants.dart';

class CredentialCard extends StatefulWidget {
  final String website;
  final String username;
  final String email;
  final String password;
  final String? category;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const CredentialCard({
    super.key,
    required this.website,
    required this.username,
    required this.email,
    required this.password,
    this.category,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<CredentialCard> createState() => _CredentialCardState();
}

class _CredentialCardState extends State<CredentialCard> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BentoColors.surfaceDark,
        borderRadius: BentoStyles.borderRadius,
        border: Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                         child: Text(
                           widget.website.isNotEmpty ? widget.website[0].toUpperCase() : '?',
                           style: const TextStyle(
                             color: BentoColors.backgroundDark,
                             fontSize: 24,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.website,
                            style: BentoStyles.header.copyWith(
                              color: BentoColors.textWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.category ?? 'Uncategorized', 
                            style: BentoStyles.body.copyWith(
                              color: widget.category != null ? BentoColors.primary : BentoColors.textMuted, 
                              fontSize: 12,
                              fontWeight: widget.category != null ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: BentoColors.textMuted),
                color: BentoColors.surfaceHover,
                onSelected: (value) {
                  if (value == 'delete') {
                    widget.onDelete();
                  } else if (value == 'edit') {
                    widget.onEdit();
                  }
                },
                itemBuilder: (context) => [
                   PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, color: BentoColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Edit', style: BentoStyles.body.copyWith(color: BentoColors.textWhite)),
                      ],
                    ),
                  ),
                   PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: BentoColors.error, size: 20),
                        const SizedBox(width: 8),
                        Text('Delete', style: BentoStyles.body.copyWith(color: BentoColors.textWhite)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Fields
          _buildFieldRow('Username', widget.username),
          const SizedBox(height: 12),
          _buildFieldRow('Email', widget.email),
          const SizedBox(height: 12),
          _buildPasswordField(widget.password),
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BentoColors.surfaceHover.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: BentoStyles.body.copyWith(
              color: BentoColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: BentoStyles.body.copyWith(
                    color: BentoColors.textWhite,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.content_copy, size: 18, color: BentoColors.textMuted),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied $label')),
                  );
                },
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                splashRadius: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

   Widget _buildPasswordField(String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BentoColors.surfaceHover.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PASSWORD',
            style: BentoStyles.body.copyWith(
              color: BentoColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _obscurePassword ? '•' * 12 : value,
                  style: BentoStyles.mono.copyWith(
                    color: BentoColors.textWhite,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off, 
                      size: 18, 
                      color: BentoColors.textMuted
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(right: 8),
                    splashRadius: 20,
                  ),
                  IconButton(
                    icon: const Icon(Icons.content_copy, size: 18, color: BentoColors.textMuted),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied Password')),
                      );
                    },
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    splashRadius: 20,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
