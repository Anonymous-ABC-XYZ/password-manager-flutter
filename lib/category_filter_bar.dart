import 'package:flutter/material.dart';
import 'bento_constants.dart';

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
              selectedColor: BentoColors.primary,
              backgroundColor: BentoColors.inputBg,
              labelStyle: BentoStyles.body.copyWith(
                color: isSelected ? BentoColors.onPrimary : BentoColors.textMuted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Slightly more rounded for filter style
                side: BorderSide(
                  color: isSelected ? BentoColors.primary : BentoColors.inputBorder,
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
