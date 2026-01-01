import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bento_constants.dart';
import 'category_selector.dart';

class IdentityTile extends StatelessWidget {
  final TextEditingController websiteController;
  final TextEditingController usernameController;
  final VoidCallback onSearchWebsite;
  final VoidCallback onSearchUsername;
  final Function(String) onCategorySelected;
  final String? initialCategory;

  const IdentityTile({
    super.key,
    required this.websiteController,
    required this.usernameController,
    required this.onSearchWebsite,
    required this.onSearchUsername,
    required this.onCategorySelected,
    this.initialCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: BentoColors.of(context).surfaceDark,
        borderRadius: BentoStyles.borderRadius,
        border: Border.all(color: BentoColors.of(context).inputBorder.withValues(alpha: 0.5)),
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
                    child: Icon(Icons.language, color: BentoColors.of(context).backgroundDark),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Identity',
                    style: BentoStyles.header.copyWith(
                      color: BentoColors.of(context).textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_horiz, color: BentoColors.of(context).textMuted),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Website Field
          _buildField(
            context: context,
            label: 'Website URL',
            controller: websiteController,
            iconActions: [
              _buildIconButton(context, Icons.open_in_new, 'Launch', () {
                // Launch URL logic placeholder
              }),
               _buildIconButton(context, Icons.search, 'Search', onSearchWebsite),
            ],
          ),
          const SizedBox(height: 16),

          // Username Field
          _buildField(
            context: context,
            label: 'Username',
            controller: usernameController,
            iconActions: [
              _buildIconButton(context, Icons.search, 'Search similar', onSearchUsername),
              _buildIconButton(context, Icons.autorenew, 'Generate', () {
                 final adjectives = ['Happy', 'Swift', 'Bright', 'Cool', 'Lazy', 'Dark', 'Red', 'Blue', 'Green', 'Wise', 'Fast', 'Slow', 'Brave', 'Calm', 'Silent', 'Mighty'];
                 final nouns = ['Tiger', 'Eagle', 'Panda', 'Fox', 'Wolf', 'Bear', 'Shark', 'Lion', 'Hawk', 'Falcon', 'Owl', 'Cat', 'Dog', 'Moon', 'Star', 'River'];
                 final random = Random();
                 final adj = adjectives[random.nextInt(adjectives.length)];
                 final noun = nouns[random.nextInt(nouns.length)];
                 final number = random.nextInt(9000) + 1000;
                 
                 final username = '$adj$noun$number';
                 usernameController.text = username;

                 Clipboard.setData(ClipboardData(text: username));
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generated and copied Username')));
              }),
            ],
          ),
          const SizedBox(height: 24),

          // Category Selector
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'Category',
              style: BentoStyles.body.copyWith(
                color: BentoColors.of(context).textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          CategorySelector(
            onSelected: onCategorySelected,
            initialValue: initialCategory,
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required BuildContext context,
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
              color: BentoColors.of(context).textMuted,
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
              style: BentoStyles.body.copyWith(color: BentoColors.of(context).textWhite),
              decoration: InputDecoration(
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BentoStyles.inputBorderRadius,
                  borderSide: BorderSide(color: BentoColors.of(context).secondary),
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

  Widget _buildIconButton(BuildContext context, IconData icon, String tooltip, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        icon: Icon(icon, color: BentoColors.of(context).textMuted, size: 20),
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(8),
        splashRadius: 20,
        hoverColor: BentoColors.of(context).surfaceHover,
      ),
    );
  }
}
