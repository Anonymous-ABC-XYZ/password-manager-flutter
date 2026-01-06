import 'package:flutter/material.dart';
import 'package:password_manager/core/utils/bento_constants.dart';

class CategorySelector extends StatefulWidget {
  final Function(String) onSelected;
  final String? initialValue;

  const CategorySelector({
    super.key,
    required this.onSelected,
    this.initialValue,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  String? _selectedCategory;

  final List<String> _categories = [
    'Personal',
    'Work',
    'Finance',
    'Social',
    'Entertainment',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _categories.map((category) {
        final isSelected = _selectedCategory == category;
        return ChoiceChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = selected ? category : null;
              if (_selectedCategory != null) {
                widget.onSelected(_selectedCategory!);
              }
            });
          },
          selectedColor: BentoColors.of(context).primary,
          backgroundColor: BentoColors.of(context).inputBg,
          labelStyle: BentoStyles.body.copyWith(
            color: isSelected ? BentoColors.of(context).onPrimary : BentoColors.of(context).textMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? BentoColors.of(context).primary : BentoColors.of(context).inputBorder,
              width: 1,
            ),
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}
