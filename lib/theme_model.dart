import 'package:flutter/material.dart';
import 'bento_constants.dart';

class ThemeModel {
  final String name;
  final Color primary;
  final Color onPrimary;
  final Color primaryDark;
  final Color backgroundLight;
  final Color backgroundDark;
  final Color sidebarBg;
  final Color surfaceDark;
  final Color surfaceHover;
  final Color inputBg;
  final Color inputBorder;
  final Color textWhite;
  final Color textMuted;
  final Color secondary;
  final Color tertiary;
  final Color error;
  final Color success;
  final Color otpIsland;

  ThemeModel({
    required this.name,
    required this.primary,
    required this.onPrimary,
    required this.primaryDark,
    required this.backgroundLight,
    required this.backgroundDark,
    required this.sidebarBg,
    required this.surfaceDark,
    required this.surfaceHover,
    required this.inputBg,
    required this.inputBorder,
    required this.textWhite,
    required this.textMuted,
    required this.secondary,
    required this.tertiary,
    required this.error,
    required this.success,
    required this.otpIsland,
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      name: json['name'] as String,
      primary: _colorFromHex(json['primary'] as String),
      onPrimary: _colorFromHex(json['onPrimary'] as String),
      primaryDark: _colorFromHex(json['primaryDark'] as String),
      backgroundLight: _colorFromHex(json['backgroundLight'] as String),
      backgroundDark: _colorFromHex(json['backgroundDark'] as String),
      sidebarBg: _colorFromHex(json['sidebarBg'] as String),
      surfaceDark: _colorFromHex(json['surfaceDark'] as String),
      surfaceHover: _colorFromHex(json['surfaceHover'] as String),
      inputBg: _colorFromHex(json['inputBg'] as String),
      inputBorder: _colorFromHex(json['inputBorder'] as String),
      textWhite: _colorFromHex(json['textWhite'] as String),
      textMuted: _colorFromHex(json['textMuted'] as String),
      secondary: _colorFromHex(json['secondary'] as String),
      tertiary: _colorFromHex(json['tertiary'] as String),
      error: _colorFromHex(json['error'] as String),
      success: _colorFromHex(json['success'] as String),
      otpIsland: _colorFromHex(json['otpIsland'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'primary': _colorToHex(primary),
      'onPrimary': _colorToHex(onPrimary),
      'primaryDark': _colorToHex(primaryDark),
      'backgroundLight': _colorToHex(backgroundLight),
      'backgroundDark': _colorToHex(backgroundDark),
      'sidebarBg': _colorToHex(sidebarBg),
      'surfaceDark': _colorToHex(surfaceDark),
      'surfaceHover': _colorToHex(surfaceHover),
      'inputBg': _colorToHex(inputBg),
      'inputBorder': _colorToHex(inputBorder),
      'textWhite': _colorToHex(textWhite),
      'textMuted': _colorToHex(textMuted),
      'secondary': _colorToHex(secondary),
      'tertiary': _colorToHex(tertiary),
      'error': _colorToHex(error),
      'success': _colorToHex(success),
      'otpIsland': _colorToHex(otpIsland),
    };
  }

  static Color _colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  BentoTheme toBentoTheme() {
    return BentoTheme(
      primary: primary,
      onPrimary: onPrimary,
      primaryDark: primaryDark,
      backgroundLight: backgroundLight,
      backgroundDark: backgroundDark,
      sidebarBg: sidebarBg,
      surfaceDark: surfaceDark,
      surfaceHover: surfaceHover,
      inputBg: inputBg,
      inputBorder: inputBorder,
      textWhite: textWhite,
      textMuted: textMuted,
      secondary: secondary,
      tertiary: tertiary,
      error: error,
      success: success,
      otpIsland: otpIsland,
    );
  }

  static final bentoDefault = ThemeModel(
    name: 'Bento Default',
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

  static final catppuccinMocha = ThemeModel(
    name: 'Catppuccin Mocha',
    primary: const Color(0xFF89B4FA), // Blue
    onPrimary: const Color(0xFF11111B), // Crust
    primaryDark: const Color(0xFF74C7EC), // Sapphire
    backgroundLight: const Color(0xFF1E1E2E), // Base
    backgroundDark: const Color(0xFF11111B), // Crust
    sidebarBg: const Color(0xFF181825), // Mantle
    surfaceDark: const Color(0xFF181825), // Mantle
    surfaceHover: const Color(0xFF313244), // Surface0
    inputBg: const Color(0xFF1E1E2E), // Base
    inputBorder: const Color(0xFF585B70), // Surface2
    textWhite: const Color(0xFFCDD6F4), // Text
    textMuted: const Color(0xFFBAC2DE), // Subtext1
    secondary: const Color(0xFFF5C2E7), // Pink
    tertiary: const Color(0xFF94E2D5), // Teal
    error: const Color(0xFFF38BA8), // Red
    success: const Color(0xFFA6E3A1), // Green
    otpIsland: const Color(0xFFFAB387), // Peach
  );

  static final rosePine = ThemeModel(
    name: 'Rose Pine',
    primary: const Color(0xFFebbcba), // Rose
    onPrimary: const Color(0xFF191724), // Base
    primaryDark: const Color(0xFF31748f), // Pine
    backgroundLight: const Color(0xFFfaf4ed), // Surface
    backgroundDark: const Color(0xFF191724), // Base
    sidebarBg: const Color(0xFF1f1d2e), // Surface
    surfaceDark: const Color(0xFF1f1d2e), // Surface
    surfaceHover: const Color(0xFF26233a), // Overlay
    inputBg: const Color(0xFF26233a), // Overlay
    inputBorder: const Color(0xFF6e6a86), // Muted
    textWhite: const Color(0xFFe0def4), // Text
    textMuted: const Color(0xFF908caa), // Subtle
    secondary: const Color(0xFFc4a7e7), // Iris
    tertiary: const Color(0xFF9ccfd8), // Foam
    error: const Color(0xFFeb6f92), // Love
    success: const Color(0xFF31748f), // Pine
    otpIsland: const Color(0xFFf6c177), // Gold
  );
}
