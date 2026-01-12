import 'package:flutter/material.dart';
import 'package:password_manager/core/utils/bento_constants.dart';

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Text(
                    'My Credentials',
                    style: BentoStyles.header.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: BentoColors.of(context).textWhite,
                      letterSpacing: -1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count passwords stored',
                  style: BentoStyles.body.copyWith(
                    color: BentoColors.of(context).textMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: BentoColors.of(context).surfaceDark,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => onSearchChanged(),
                      style: BentoStyles.body.copyWith(
                        color: BentoColors.of(context).textWhite,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search logins...',
                        hintStyle: BentoStyles.body.copyWith(
                          color: BentoColors.of(context).textMuted,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: BentoColors.of(context).textMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: BentoColors.of(context).surfaceDark,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sort,
                    color: BentoColors.of(context).textWhite,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
