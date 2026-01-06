import 'package:flutter/material.dart';
import 'package:password_manager/core/utils/bento_constants.dart';

class CategoryFilterBar extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onSelected;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Personal', 'Work', 'Finance', 'Social', 'Entertainment', 'Other'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = (category == 'All' && selectedCategory == null) || category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (category == 'All') {
                  onSelected(null);
                } else {
                  onSelected(selected ? category : null);
                }
              },
              selectedColor: BentoColors.of(context).primary,
              backgroundColor: BentoColors.of(context).inputBg,
              labelStyle: BentoStyles.body.copyWith(
                color: isSelected ? BentoColors.of(context).onPrimary : BentoColors.of(context).textMuted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Slightly more rounded for filter style
                side: BorderSide(
                  color: isSelected ? BentoColors.of(context).primary : BentoColors.of(context).inputBorder,
                  width: 1,
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}
