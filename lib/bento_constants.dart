import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BentoColors {
  // Catppuccin Mocha Palette
  static const primary = Color(0xFFb4befe); // Lavender
  static const onPrimary = Color(0xFF1e1e2e); // Base (Dark text on pastel)
  static const primaryDark = Color(0xFF89b4fa); // Blue (Accents)
  
  static const backgroundLight = Color(0xFFeff1f5); // Latte Base
  static const backgroundDark = Color(0xFF1e1e2e); // Mocha Base
  
  static const sidebarBg = Color(0xFF181825); // Mocha Mantle
  static const surfaceDark = Color(0xFF313244); // Mocha Surface0
  static const surfaceHover = Color(0xFF45475a); // Mocha Surface1
  
  static const inputBg = Color(0xFF313244); // Surface0
  static const inputBorder = Color(0xFF45475a); // Surface1
  
  static const textWhite = Color(0xFFcdd6f4); // Text
  static const textMuted = Color(0xFFbac2de); // Subtext1
  
  static const secondary = Color(0xFF94e2d5); // Teal/Sage
  static const tertiary = Color(0xFFfab387); // Peach
  static const error = Color(0xFFf38ba8); // Red
  static const success = Color(0xFFa6e3a1); // Green
  
  static const otpIsland = Color(0xFF89dceb); // Sky
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