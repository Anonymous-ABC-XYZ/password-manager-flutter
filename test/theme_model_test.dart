import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/theme_model.dart';

void main() {
  group('ThemeModel', () {
    final themeData = {
      'name': 'Test Theme',
      'primary': '#00DFC3',
      'onPrimary': '#001E26',
      'primaryDark': '#019391',
      'backgroundLight': '#F0F9FF',
      'backgroundDark': '#01082D',
      'sidebarBg': '#041D56',
      'surfaceDark': '#041D56',
      'surfaceHover': '#0F2573',
      'inputBg': '#0B1A40',
      'inputBorder': '#266CA9',
      'textWhite': '#FFFFFF',
      'textMuted': '#89D6E8',
      'secondary': '#ADE1FB',
      'tertiary': '#45C2DB',
      'error': '#EF4444',
      'success': '#00DFC3',
      'otpIsland': '#019391',
    };

    test('should create ThemeModel from JSON', () {
      final model = ThemeModel.fromJson(themeData);
      expect(model.name, 'Test Theme');
      expect(model.primary.value, const Color(0xFF00DFC3).value);
    });

    test('should convert ThemeModel to JSON', () {
      final model = ThemeModel(
        name: 'Test Theme',
        primary: const Color(0xFF00DFC3),
        onPrimary: const Color(0xFF001E26),
        primaryDark: const Color(0xFF019391),
        backgroundLight: const Color(0xFFF0F9FF),
        backgroundDark: const Color(0xFF01082D),
        sidebarBg: const Color(0xFF041D56),
        surfaceDark: const Color(0xFF041D56),
        surfaceHover: const Color(0xFF0F2573),
        inputBg: const Color(0xFF0B1A40),
        inputBorder: const Color(0xFF266CA9),
        textWhite: const Color(0xFFFFFFFF),
        textMuted: const Color(0xFF89D6E8),
        secondary: const Color(0xFFADE1FB),
        tertiary: const Color(0xFF45C2DB),
        error: const Color(0xFFEF4444),
        success: const Color(0xFF00DFC3),
        otpIsland: const Color(0xFF019391),
      );

      final json = model.toJson();
      expect(json['name'], 'Test Theme');
      expect(json['primary'], '#00DFC3');
    });
  });
}
