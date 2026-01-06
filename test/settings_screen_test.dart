import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/settings/settings_screen.dart';
import 'package:password_manager/core/widgets/stitch_bottom_sheet.dart';
import 'package:password_manager/features/auth/auth_provider.dart';
import 'package:password_manager/features/settings/theme_provider.dart';
import 'package:password_manager/features/settings/theme_service.dart';
import 'package:password_manager/features/settings/theme_model.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

class MockThemeService extends Mock implements ThemeService {}

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockThemeService mockThemeService;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockThemeService = MockThemeService();

    // Stub theme service
    when(
      () => mockThemeService.getSelectedThemeName(),
    ).thenAnswer((_) async => 'Bento Default');
    when(() => mockThemeService.getCustomThemes()).thenAnswer((_) async => []);
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(themeService: mockThemeService),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: [ThemeModel.bentoDefault.toBentoTheme()]),
        home: const SettingsScreen(),
      ),
    );
  }

  testWidgets('SettingsScreen displays options list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('API Keys'), findsOneWidget);
  });

  testWidgets('Tapping Appearance opens StitchBottomSheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();

    expect(find.byType(StitchBottomSheet), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
  });
}
