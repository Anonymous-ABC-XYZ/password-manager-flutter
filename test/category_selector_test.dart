import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/vault/widgets/category_selector.dart';
import 'package:password_manager/features/settings/theme_model.dart';

void main() {
  testWidgets('CategorySelector displays chips and selects one', (
    WidgetTester tester,
  ) async {
    String? selectedCategory;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [ThemeModel.bentoDefault.toBentoTheme()]),
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
