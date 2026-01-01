import 'package:flutter/material.dart';

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
}
