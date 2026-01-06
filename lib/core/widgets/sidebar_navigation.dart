import 'package:flutter/material.dart';
import 'package:password_manager/core/utils/bento_constants.dart';

class SidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onThemeToggle;

  const SidebarNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: BentoColors.of(context).sidebarBg,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Navigation Links
          Expanded(
            child: ListView(
              children: [
                _buildNavItem(context, 0, Icons.lock, 'Vault'),
                _buildNavItem(
                  context,
                  1,
                  Icons.list_alt,
                  'Credentials',
                ), // Mapped to PasswordsPage
                _buildNavItem(context, 2, Icons.settings, 'Settings'),
                // Placeholders from design
                _buildNavItem(context, 3, Icons.send, 'Send', enabled: false),
                _buildNavItem(
                  context,
                  4,
                  Icons.security,
                  'Security',
                  enabled: false,
                ),
              ],
            ),
          ),

          // Bottom Actions
          Divider(color: BentoColors.of(context).surfaceHover),
          const SizedBox(height: 16),
          _buildNavItem(
            context,
            -1,
            Icons.brightness_6,
            'Toggle Theme',
            onTap: onThemeToggle,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label, {
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    bool isSelected = selectedIndex == index && index >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? (onTap ?? () => onDestinationSelected(index)) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? BentoColors.of(context).primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(
                50,
              ), // Fully rounded as per design
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: BentoColors.of(
                          context,
                        ).primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? BentoColors.of(context).onPrimary
                      : (enabled
                            ? BentoColors.of(context).textMuted
                            : BentoColors.of(context).surfaceHover),
                  size: 20,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: BentoStyles.body.copyWith(
                    color: isSelected
                        ? BentoColors.of(context).onPrimary
                        : (enabled
                              ? BentoColors.of(context).textMuted
                              : BentoColors.of(context).surfaceHover),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
