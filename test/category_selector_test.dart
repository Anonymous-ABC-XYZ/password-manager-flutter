import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/category_selector.dart';

void main() {
  testWidgets('CategorySelector displays chips and selects one', (WidgetTester tester) async {
    String? selectedCategory;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategorySelector(
            onSelected: (category) {
              selectedCategory = category;
            },
          ),
        ),
      ),
    );

    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);

    await tester.tap(find.text('Work'));
    await tester.pump();

    expect(selectedCategory, 'Work');
  });
}
