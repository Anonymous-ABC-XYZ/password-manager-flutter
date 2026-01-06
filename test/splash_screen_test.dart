import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/auth/splash_screen.dart';
import 'package:password_manager/features/auth/auth_provider.dart';
import 'package:password_manager/features/settings/theme_provider.dart';
import 'package:password_manager/features/settings/theme_service.dart';
import 'package:password_manager/features/settings/theme_model.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';

import 'package:password_manager/core/widgets/stitch_bottom_sheet.dart';

// Create a mock for AuthProvider
class MockAuthProvider extends Mock implements AuthProvider {}

// Create a mock for ThemeService
class MockThemeService extends Mock implements ThemeService {}

void main() {
  late MockAuthProvider mockAuthProvider;
  late ThemeProvider themeProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    themeProvider = ThemeProvider(themeService: ThemeService()); 

    // Stub necessary methods for AuthProvider
    when(() => mockAuthProvider.isAuthenticated).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: [ThemeModel.bentoDefault.toBentoTheme()]),
        home: const SplashScreen(),
      ),
    );
  }

  testWidgets('SplashScreen displays branding and auth buttons', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify Header
    expect(find.text("Let's get you secured"), findsOneWidget);
    
    // Verify Buttons
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with DuckDuckGo'), findsOneWidget);
    
    // Verify Guest Option
    expect(find.text('Enter as Guest'), findsOneWidget);
  });

  testWidgets('Tapping Google button opens StitchBottomSheet', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final googleButton = find.text('Continue with Google');
    await tester.tap(googleButton);
    await tester.pumpAndSettle(); 

    // Verify StitchBottomSheet is used instead of AlertDialog
    expect(find.byType(StitchBottomSheet), findsOneWidget);
    expect(find.text('Configure Google OAuth'), findsOneWidget);
  });

  testWidgets('Tapping DuckDuckGo button opens StitchBottomSheet', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final duckButton = find.text('Continue with DuckDuckGo');
    await tester.tap(duckButton);
    await tester.pumpAndSettle();

    // Verify StitchBottomSheet is used
    expect(find.byType(StitchBottomSheet), findsOneWidget);
    expect(find.text('Configure DuckDuckGo'), findsOneWidget);
  });
}
