import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BentoColors {
  // Deep Navy & Neon Teal Palette
  static const primary = Color(0xFF00DFC3); // Vibrant Cyan/Teal
  static const onPrimary = Color(0xFF001E26); // Dark text on vibrant teal
  static const primaryDark = Color(0xFF019391); // Deep Teal
  
  static const backgroundLight = Color(0xFFF0F9FF);
  static const backgroundDark = Color(0xFF01082D); // Deep Navy Base
  
  static const sidebarBg = Color(0xFF041D56); // Dark Navy Surface
  static const surfaceDark = Color(0xFF041D56); // Dark Blue Surface
  static const surfaceHover = Color(0xFF0F2573); // Lighter Navy Overlay
  
  static const inputBg = Color(0xFF0B1A40); // Muted bg for inputs
  static const inputBorder = Color(0xFF266CA9); // Mid Blue Border
  
  static const textWhite = Color(0xFFFFFFFF); // Pure White
  static const textMuted = Color(0xFF89D6E8); // Muted Cyan/Blue text
  
  static const secondary = Color(0xFFADE1FB); // Pale Blue/Sky
  static const tertiary = Color(0xFF45C2DB); // Bright Cyan
  static const error = Color(0xFFEF4444); // Red
  static const success = Color(0xFF00DFC3); // Teal
  
  static const otpIsland = Color(0xFF019391); // Deep Teal
}

class BentoStyles {
  static final borderRadius = BorderRadius.circular(32.0); // 2rem
  static final inputBorderRadius = BorderRadius.circular(16.0); // 1rem
  static final cardBorderRadius = BorderRadius.circular(16.0);

  // Hybrid Font Strategy
  static TextStyle get header => GoogleFonts.bricolageGrotesque(textStyle: const TextStyle(inherit: true));
  static TextStyle get body => GoogleFonts.plusJakartaSans(textStyle: const TextStyle(inherit: true));
  static TextStyle get mono => GoogleFonts.jetBrainsMono(textStyle: const TextStyle(inherit: true));
}
