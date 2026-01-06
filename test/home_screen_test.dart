import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/vault/home_screen.dart';
import 'package:password_manager/features/auth/auth_provider.dart';
import 'package:password_manager/providers/theme_provider.dart';
import 'package:password_manager/theme_service.dart';
import 'package:password_manager/theme_model.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockAuthProvider mockAuthProvider;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    when(() => mockAuthProvider.isAuthenticated).thenReturn(false); 
    // Even if not authenticated, HomeScreen should render (Guest Mode context)
    // Though OTP island might behave differently, basic UI should be there.
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider(themeService: ThemeService())),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: [ThemeModel.bentoDefault.toBentoTheme()]),
        home: const HomeScreen(),
      ),
    );
  }

  testWidgets('HomeScreen renders key input fields', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify main input sections
    expect(find.text('Add Entry'), findsOneWidget); // FAB
    
    // We expect TextFields for Website, Username, Email, Password, OTP
    expect(find.byType(TextField), findsAtLeastNWidgets(4));
  });

  testWidgets('Input fields have Stitch styling', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Target the Website URL field specifically
    final websiteFieldFinder = find.ancestor(
      of: find.text('Website URL'),
      matching: find.byType(Column),
    ).first;
    
    final textFieldFinder = find.descendant(
      of: websiteFieldFinder,
      matching: find.byType(TextField),
    );

    final textField = tester.widget<TextField>(textFieldFinder);
    final decoration = textField.decoration as InputDecoration;

    // We check for the NEW expected style.
    expect(decoration.filled, isTrue);
    expect(decoration.fillColor, ThemeModel.bentoDefault.inputBg);
  });
}
