import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bento_constants.dart';

class IdentityTile extends StatelessWidget {
  final TextEditingController websiteController;
  final TextEditingController usernameController;
  final VoidCallback onSearchWebsite;
  final VoidCallback onSearchUsername;

  const IdentityTile({
    super.key,
    required this.websiteController,
    required this.usernameController,
    required this.onSearchWebsite,
    required this.onSearchUsername,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: BentoColors.surfaceDark,
        borderRadius: BentoStyles.borderRadius,
        border: Border.all(color: BentoColors.inputBorder.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.language, color: BentoColors.backgroundDark),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Identity',
                    style: BentoStyles.header.copyWith(
                      color: BentoColors.textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz, color: BentoColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Website Field
          _buildField(
            label: 'Website URL',
            controller: websiteController,
            iconActions: [
              _buildIconButton(Icons.open_in_new, 'Launch', () {
                // Launch URL logic placeholder
              }),
               _buildIconButton(Icons.search, 'Search', onSearchWebsite),
            ],
          ),
          const SizedBox(height: 16),

          // Username Field
          _buildField(
            label: 'Username',
            controller: usernameController,
            iconActions: [
              _buildIconButton(Icons.search, 'Search similar', onSearchUsername),
              _buildIconButton(Icons.content_copy, 'Copy', () {
                 Clipboard.setData(ClipboardData(text: usernameController.text));
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied Username')));
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required List<Widget> iconActions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: BentoStyles.body.copyWith(
              color: BentoColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: controller,
              style: BentoStyles.body.copyWith(color: BentoColors.textWhite),
              decoration: InputDecoration(
                filled: true,
                fillColor: BentoColors.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BentoStyles.inputBorderRadius,
                  borderSide: const BorderSide(color: BentoColors.inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BentoStyles.inputBorderRadius,
                  borderSide: const BorderSide(color: BentoColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BentoStyles.inputBorderRadius,
                  borderSide: const BorderSide(color: BentoColors.secondary),
                ),
                contentPadding: const EdgeInsets.fromLTRB(16, 16, 80, 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: iconActions,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        icon: Icon(icon, color: BentoColors.textMuted, size: 20),
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(8),
        splashRadius: 20,
        hoverColor: BentoColors.surfaceHover,
      ),
    );
  }
}
