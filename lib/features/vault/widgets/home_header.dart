import 'package:flutter/material.dart';
import 'package:password_manager/core/utils/bento_constants.dart';

class HomeHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSearch;
  final int count;

  const HomeHeader({
    super.key,
    required this.title,
    required this.onSearch,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Text(
                title,
                style: BentoStyles.header.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: BentoColors.of(context).textWhite,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.folder_open,
                  size: 16,
                  color: BentoColors.of(context).textMuted,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: BentoColors.of(context).surfaceDark,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: BentoColors.of(context).inputBorder),
          ),
          child: TextField(
            style: BentoStyles.body.copyWith(
              color: BentoColors.of(context).textWhite,
            ),
            decoration: InputDecoration(
              hintText: 'Search $count passwords...',
              hintStyle: BentoStyles.body.copyWith(
                color: BentoColors.of(context).textMuted,
              ),
              suffixIcon: IconButton(
                onPressed: onSearch,
                icon: Icon(Icons.search),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: BentoColors.of(context).secondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
