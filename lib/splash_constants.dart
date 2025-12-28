import 'package:flutter/material.dart';

class SplashColors {
  // Catppuccin Mocha Palette (Synced with BentoColors)
  static const primary = Color(0xFFb4befe); // Lavender
  static const primaryDark = Color(0xFF89b4fa); // Blue
  
  static const backgroundLight = Color(0xFFeff1f5);
  static const backgroundDark = Color(0xFF1e1e2e); // Mocha Base
  
  static const surfaceDark = Color(0xFF313244); // Mocha Surface0
  static const surfaceHover = Color(0xFF45475a); // Mocha Surface1
  
  static const textMuted = Color(0xFFbac2de); // Subtext1
  static const textWhite = Color(0xFFcdd6f4); // Text
  
  static const secondary = Color(0xFF94e2d5); // Teal/Sage
  static const onPrimary = Color(0xFF1e1e2e); // Dark text on pastel primary
}

class SplashStyles {
  static final borderRadius = BorderRadius.circular(32.0); // 2rem
  static final cardBorderRadius = BorderRadius.circular(16.0); // 1rem
  static final boxShadow = [
    BoxShadow(
      color: Color.fromRGBO(180, 190, 254, 0.3), // Lavender glow
      blurRadius: 20,
      offset: const Offset(0, 0),
    ),
  ];
}