import 'package:flutter/material.dart';
import 'bento_constants.dart';

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
      color: BentoColors.sidebarBg,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Logo / Profile Area
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [BentoColors.primary, BentoColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: BentoColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.person, color: BentoColors.backgroundDark), // Placeholder for profile image
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Vault',
                    style: BentoStyles.header.copyWith(
                      color: BentoColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Premium Plan',
                    style: BentoStyles.body.copyWith(
                      color: BentoColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Navigation Links
          Expanded(
            child: ListView(
              children: [
                _buildNavItem(0, Icons.lock, 'Vault'),
                _buildNavItem(1, Icons.list_alt, 'Credentials'), // Mapped to PasswordsPage
                _buildNavItem(2, Icons.settings, 'Settings'),
                // Placeholders from design
                _buildNavItem(3, Icons.send, 'Send', enabled: false),
                _buildNavItem(4, Icons.security, 'Security', enabled: false),
              ],
            ),
          ),

          // Bottom Actions
          const Divider(color: BentoColors.surfaceHover),
          const SizedBox(height: 16),
          _buildNavItem(-1, Icons.brightness_6, 'Toggle Theme', onTap: onThemeToggle),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {bool enabled = true, VoidCallback? onTap}) {
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
              color: isSelected ? BentoColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(50), // Fully rounded as per design
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: BentoColors.primary.withValues(alpha: 0.2),
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
                      ? BentoColors.onPrimary
                      : (enabled ? BentoColors.textMuted : BentoColors.surfaceHover),
                  size: 20,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: BentoStyles.body.copyWith(
                    color: isSelected
                        ? BentoColors.onPrimary
                        : (enabled ? BentoColors.textMuted : BentoColors.surfaceHover),
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
