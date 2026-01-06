import 'package:flutter/material.dart';
import 'package:password_manager/core/utils/bento_constants.dart';

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
              crossAxisAlignment: isDesktop
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Entry',
                      style: BentoStyles.header.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: BentoColors.of(context).textWhite,
                        letterSpacing: -0.5,
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
                        Text(
                          'Personal > Social Media',
                          style: BentoStyles.body.copyWith(
                            color: BentoColors.of(context).textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!isDesktop) const SizedBox(height: 16),
                Container(
                  width: isDesktop ? 400 : double.infinity,
                  decoration: BoxDecoration(
                    color: BentoColors.of(context).surfaceDark,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: BentoColors.of(context).inputBorder,
                    ),
                  ),
                  child: TextField(
                    style: BentoStyles.body.copyWith(
                      color: BentoColors.of(context).textWhite,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search 245 passwords...',
                      hintStyle: BentoStyles.body.copyWith(
                        color: BentoColors.of(context).textMuted,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: BentoColors.of(context).textMuted,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: BentoColors.of(context).surfaceHover,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: BentoColors.of(context).inputBorder,
                            ),
                          ),
                          child: Text(
                            'CMD K',
                            style: BentoStyles.body.copyWith(
                              fontSize: 10,
                              color: BentoColors.of(context).textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
                    onTap: onSearch,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
