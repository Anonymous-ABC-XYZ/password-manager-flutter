import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/settings/theme_service.dart';
import 'package:password_manager/features/settings/theme_model.dart';
import 'package:flutter/material.dart';

void main() {
  late ThemeService themeService;
  late File tempFile;

  setUp(() {
    tempFile = File('test_themes.json');
    themeService = ThemeService(customFile: tempFile);
  });

  tearDown(() {
    if (tempFile.existsSync()) {
      tempFile.deleteSync();
    }
  });

  test('should return default theme name when file does not exist', () async {
    final name = await themeService.getSelectedThemeName();
    expect(name, 'Bento Default');
  });

  test('should save and load selected theme name', () async {
    await themeService.setSelectedThemeName('Custom Theme');
    final name = await themeService.getSelectedThemeName();
    expect(name, 'Custom Theme');
  });

  test('should add and load custom themes', () async {
    final theme = ThemeModel(
      name: 'My Custom Theme',
      primary: const Color(0xFF112233),
      onPrimary: Colors.white,
      primaryDark: Colors.black,
      backgroundLight: Colors.white,
      backgroundDark: Colors.black,
      sidebarBg: Colors.black,
      surfaceDark: Colors.black,
      surfaceHover: Colors.grey,
      inputBg: Colors.black,
      inputBorder: Colors.grey,
      textWhite: Colors.white,
      textMuted: Colors.grey,
      secondary: Colors.blue,
      tertiary: Colors.cyan,
      error: Colors.red,
      success: Colors.green,
      otpIsland: Colors.teal,
    );

    await themeService.addCustomTheme(theme);
    final themes = await themeService.getCustomThemes();

    expect(themes.length, 1);
    expect(themes[0].name, 'My Custom Theme');
    expect(themes[0].primary.value, const Color(0xFF112233).value);
  });
}
