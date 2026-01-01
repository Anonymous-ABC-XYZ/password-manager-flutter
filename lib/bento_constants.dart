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
  static const backgroundDark = Color(0xFF01082D);
  static const primary = Color(0xFF00DFC3);
  static const onPrimary = Color(0xFF001E26);
  static const textWhite = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF89D6E8);
  static const surfaceDark = Color(0xFF041D56);
  static const surfaceHover = Color(0xFF0F2573);
  static const inputBg = Color(0xFF0B1A40);
  static const inputBorder = Color(0xFF266CA9);
  static const secondary = Color(0xFFADE1FB);
  static const error = Color(0xFFEF4444);
}

class SplashStyles {
  static final borderRadius = BorderRadius.circular(32.0); // 2rem
  static final cardBorderRadius = BorderRadius.circular(16.0); // 1rem
  static final boxShadow = [
    BoxShadow(
      color: const Color.fromRGBO(0, 223, 195, 0.25), // Teal glow
      blurRadius: 20,
      offset: const Offset(0, 0),
    ),
  ];
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
