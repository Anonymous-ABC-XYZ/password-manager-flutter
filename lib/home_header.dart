import 'package:flutter/material.dart';
import 'bento_constants.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onSearch;

  const HomeHeader({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 800;
            return Flex(
              direction: isDesktop ? Axis.horizontal : Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: isDesktop ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Entry',
                      style: BentoStyles.header.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: BentoColors.textWhite,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.folder_open, size: 16, color: BentoColors.textMuted),
                        const SizedBox(width: 8),
                        Text(
                          'Personal > Social Media',
                          style: BentoStyles.body.copyWith(color: BentoColors.textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!isDesktop) const SizedBox(height: 16),
                Container(
                  width: isDesktop ? 400 : double.infinity,
                  decoration: BoxDecoration(
                    color: BentoColors.surfaceDark,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: BentoColors.inputBorder),
                  ),
                  child: TextField(
                    style: BentoStyles.body.copyWith(color: BentoColors.textWhite),
                    decoration: InputDecoration(
                      hintText: 'Search 245 passwords...',
                      hintStyle: BentoStyles.body.copyWith(color: BentoColors.textMuted),
                      prefixIcon: const Icon(Icons.search, color: BentoColors.textMuted),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: BentoColors.surfaceHover,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: BentoColors.inputBorder),
                          ),
                          child: Text(
                            'CMD K',
                            style: BentoStyles.body.copyWith(fontSize: 10, color: BentoColors.textMuted, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(color: BentoColors.secondary),
                      ),
                    ),
                    onTap: onSearch,
                  ),
                ),
              ],
            );
          }
        ),
      ],
    );
  }
}
