import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/vault/widgets/category_filter_bar.dart';
import 'package:password_manager/features/settings/theme_model.dart';

void main() {
  testWidgets('CategoryFilterBar selects categories correctly', (WidgetTester tester) async {
    String? selectedCategory;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: [ThemeModel.bentoDefault.toBentoTheme()],
        ),
        home: Scaffold(
          body: CategoryFilterBar(
            selectedCategory: null,
            onSelected: (cat) => selectedCategory = cat,
          ),
        ),
      ),
    );

    // Initial state: All selected (which is null)
    expect(find.text('All'), findsOneWidget);
    
    // Select 'Work'
    await tester.tap(find.text('Work'));
    await tester.pump();
    expect(selectedCategory, 'Work');
  });
  
  testWidgets('CategoryFilterBar selecting "All" returns null', (WidgetTester tester) async {
      String? selectedCategory = 'Work'; // Start with something selected

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: [ThemeModel.bentoDefault.toBentoTheme()],
          ),
          home: Scaffold(
            body: CategoryFilterBar(
              selectedCategory: 'Work',
              onSelected: (cat) => selectedCategory = cat,
            ),
          ),
        ),
      );

      await tester.tap(find.text('All'));
      await tester.pump();
      expect(selectedCategory, null);
  });
}
