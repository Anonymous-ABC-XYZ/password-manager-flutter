import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:password_manager/features/settings/theme_provider.dart';
import 'package:password_manager/features/settings/theme_service.dart';
import 'package:password_manager/features/settings/theme_model.dart';

class MockThemeService extends Mock implements ThemeService {}

void main() {
  late ThemeProvider themeProvider;
  late MockThemeService mockThemeService;

  setUp(() {
    mockThemeService = MockThemeService();
    // Default mock behaviors
    when(
      () => mockThemeService.getSelectedThemeName(),
    ).thenAnswer((_) async => 'Bento Default');
    when(() => mockThemeService.getCustomThemes()).thenAnswer((_) async => []);

    themeProvider = ThemeProvider(themeService: mockThemeService);
  });

  test('should load default theme on initialization', () async {
    await themeProvider.init();
    expect(themeProvider.currentTheme.name, 'Bento Default');
  });

  test('should switch theme and notify listeners', () async {
    when(
      () => mockThemeService.setSelectedThemeName('Catppuccin Mocha'),
    ).thenAnswer((_) async {});

    await themeProvider.init();
    bool notified = false;
    themeProvider.addListener(() {
      notified = true;
    });

    await themeProvider.setTheme(ThemeModel.catppuccinMocha);

    expect(themeProvider.currentTheme.name, 'Catppuccin Mocha');
    expect(notified, true);
    verify(
      () => mockThemeService.setSelectedThemeName('Catppuccin Mocha'),
    ).called(1);
  });
}
