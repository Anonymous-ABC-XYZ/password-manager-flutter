import 'package:flutter/material.dart';

class SplashColors {
  // Deep Navy & Neon Teal Palette (Synced with BentoColors)
  static const primary = Color(0xFF00DFC3); // Vibrant Cyan/Teal
  static const primaryDark = Color(0xFF019391); // Deep Teal
  
  static const backgroundLight = Color(0xFFF0F9FF);
  static const backgroundDark = Color(0xFF01082D); // Deep Navy Base
  
  static const surfaceDark = Color(0xFF041D56); // Dark Blue Surface
  static const surfaceHover = Color(0xFF0F2573); // Lighter Navy Overlay
  
  static const textMuted = Color(0xFF89D6E8); // Muted Cyan/Blue text
  static const textWhite = Color(0xFFFFFFFF); // Pure White
  
  static const secondary = Color(0xFFADE1FB); // Pale Blue/Sky
  static const onPrimary = Color(0xFF001E26); // Dark text on vibrant teal
}

class SplashStyles {
  static final borderRadius = BorderRadius.circular(32.0); // 2rem
  static final cardBorderRadius = BorderRadius.circular(16.0); // 1rem
  static final boxShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 223, 195, 0.25), // Teal glow
      blurRadius: 20,
      offset: const Offset(0, 0),
    ),
  ];
}
