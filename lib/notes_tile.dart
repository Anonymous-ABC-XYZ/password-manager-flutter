import 'package:flutter/material.dart';
import 'bento_constants.dart';

class NotesTile extends StatelessWidget {
  const NotesTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      constraints: const BoxConstraints(minHeight: 160),
      decoration: BoxDecoration(
        color: BentoColors.of(context).surfaceDark,
        borderRadius: BentoStyles.borderRadius,
        border: Border.all(color: BentoColors.of(context).inputBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: BentoColors.of(context).textMuted),
              const SizedBox(width: 12),
              Text(
                'Notes',
                style: BentoStyles.header.copyWith(
                  color: BentoColors.of(context).textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add secure notes about this account...',
              hintStyle: BentoStyles.body.copyWith(color: BentoColors.of(context).textMuted, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: BentoStyles.body.copyWith(color: BentoColors.of(context).textWhite, fontSize: 14, height: 1.5),
            onChanged: (value) {
              // TODO: Implement notes saving
            },
          ),
        ],
      ),
    );
  }
}
