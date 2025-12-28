import 'package:flutter/material.dart';
import 'bento_constants.dart';

class CredentialsHeader extends StatelessWidget {
  final int count;
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;

  const CredentialsHeader({
    super.key,
    required this.count,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Search Row
        LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 800;
            return Flex(
              direction: isDesktop ? Axis.horizontal : Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: isDesktop ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Credentials',
                      style: BentoStyles.header.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: BentoColors.textWhite,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count passwords stored',
                      style: BentoStyles.body.copyWith(color: BentoColors.textMuted, fontSize: 14),
                    ),
                  ],
                ),
                if (!isDesktop) const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: isDesktop ? 320 : 250,
                      decoration: BoxDecoration(
                        color: BentoColors.surfaceDark,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) => onSearchChanged(),
                        style: BentoStyles.body.copyWith(color: BentoColors.textWhite),
                        decoration: InputDecoration(
                          hintText: 'Search logins...',
                          hintStyle: BentoStyles.body.copyWith(color: BentoColors.textMuted),
                          prefixIcon: const Icon(Icons.search, color: BentoColors.textMuted),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 48, 
                      height: 48,
                      decoration: BoxDecoration(
                        color: BentoColors.surfaceDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.sort, color: BentoColors.textWhite),
                    ),
                  ],
                ),
              ],
            );
          }
        ),
        const SizedBox(height: 24),
        
        // Filter Chips (Visual Placeholders)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildChip('All', true),
              _buildChip('Social', false),
              _buildChip('Finance', false),
              _buildChip('Shopping', false),
              _buildChip('Work', false),
              _buildChip('Entertainment', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? BentoColors.primary : BentoColors.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isActive ? BentoColors.primary : BentoColors.surfaceHover),
        ),
        child: Text(
          label,
          style: BentoStyles.body.copyWith(
            color: isActive ? BentoColors.onPrimary : BentoColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
