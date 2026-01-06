import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class BentoTheme extends ThemeExtension<BentoTheme> {
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

  const BentoTheme({
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

  @override
  BentoTheme copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryDark,
    Color? backgroundLight,
    Color? backgroundDark,
    Color? sidebarBg,
    Color? surfaceDark,
    Color? surfaceHover,
    Color? inputBg,
    Color? inputBorder,
    Color? textWhite,
    Color? textMuted,
    Color? secondary,
    Color? tertiary,
    Color? error,
    Color? success,
    Color? otpIsland,
  }) {
    return BentoTheme(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryDark: primaryDark ?? this.primaryDark,
      backgroundLight: backgroundLight ?? this.backgroundLight,
      backgroundDark: backgroundDark ?? this.backgroundDark,
      sidebarBg: sidebarBg ?? this.sidebarBg,
      surfaceDark: surfaceDark ?? this.surfaceDark,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      inputBg: inputBg ?? this.inputBg,
      inputBorder: inputBorder ?? this.inputBorder,
      textWhite: textWhite ?? this.textWhite,
      textMuted: textMuted ?? this.textMuted,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      error: error ?? this.error,
      success: success ?? this.success,
      otpIsland: otpIsland ?? this.otpIsland,
    );
  }

  @override
  BentoTheme lerp(ThemeExtension<BentoTheme>? other, double t) {
    if (other is! BentoTheme) return this;
    return BentoTheme(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      backgroundLight: Color.lerp(backgroundLight, other.backgroundLight, t)!,
      backgroundDark: Color.lerp(backgroundDark, other.backgroundDark, t)!,
      sidebarBg: Color.lerp(sidebarBg, other.sidebarBg, t)!,
      surfaceDark: Color.lerp(surfaceDark, other.surfaceDark, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      inputBg: Color.lerp(inputBg, other.inputBg, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      textWhite: Color.lerp(textWhite, other.textWhite, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      otpIsland: Color.lerp(otpIsland, other.otpIsland, t)!,
    );
  }
}

class BentoColors {
  static BentoTheme of(BuildContext context) {
    return Theme.of(context).extension<BentoTheme>()!;
  }

  // Fallback static values for non-context access if needed (optional)
  static const backgroundDark = Color(0xFF0F172A); // Slate 900
  static const primary = Color(0xFF6366F1); // Indigo 500
  static const onPrimary = Color(0xFFFFFFFF);
  static const textWhite = Color(0xFFF8FAFC); // Slate 50
  static const textMuted = Color(0xFF94A3B8); // Slate 400
  static const surfaceDark = Color(0xFF1E293B); // Slate 800
  static const surfaceHover = Color(0xFF334155); // Slate 700
  static const inputBg = Color(0xFF0F172A); // Slate 900
  static const inputBorder = Color(0xFF334155); // Slate 700
  static const secondary = Color(0xFF818CF8); // Indigo 400
  static const error = Color(0xFFEF4444); // Red 500
}

class SplashStyles {
  static final borderRadius = BorderRadius.circular(24.0);
  static final cardBorderRadius = BorderRadius.circular(16.0);
  static final boxShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];
}

class BentoStyles {
  static final borderRadius = BorderRadius.circular(24.0);
  static final inputBorderRadius = BorderRadius.circular(12.0);
  static final cardBorderRadius = BorderRadius.circular(16.0);

  // Hybrid Font Strategy - Optimized for Stitch (Mobile-First)
  static TextStyle get header => GoogleFonts.outfit(
    textStyle: const TextStyle(inherit: true, fontWeight: FontWeight.bold),
  );
  static TextStyle get body =>
      GoogleFonts.inter(textStyle: const TextStyle(inherit: true));
  static TextStyle get mono =>
      GoogleFonts.jetBrainsMono(textStyle: const TextStyle(inherit: true));
}
