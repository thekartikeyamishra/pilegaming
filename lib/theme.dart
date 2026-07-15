import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pile design tokens — "a dark room lit by one CRT."
/// Near-black, one neon-lime action color, magenta reserved for hype.
/// Gamer-native without cosplaying as an RGB keyboard.
///
/// void_   #0E1116  background
/// panel   #191D26  surfaces
/// line    #262C3A  hairlines
/// frost   #EDEFF5  primary text
/// dim     #8A93A6  secondary text
/// lime    #A8E834  action / progress / beaten
/// magenta #F050B4  hype / countdowns
/// amber   #F5C64F  money
/// red     #F0564C  shame / abandoned
class PlColors {
  static const void_ = Color(0xFF0E1116);
  static const panel = Color(0xFF191D26);
  static const line = Color(0xFF262C3A);
  static const frost = Color(0xFFEDEFF5);
  static const dim = Color(0xFF8A93A6);
  static const lime = Color(0xFFA8E834);
  static const magenta = Color(0xFFF050B4);
  static const amber = Color(0xFFF5C64F);
  static const red = Color(0xFFF0564C);

  static const glass = Color(0x99191D26);
  static const premium = Color(0xFFFFD700);
}

ThemeData pileTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: PlColors.void_,
    colorScheme: const ColorScheme.dark(
      primary: PlColors.lime,
      secondary: PlColors.magenta,
      surface: PlColors.panel,
      onSurface: PlColors.frost,
      error: PlColors.red,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  final body = GoogleFonts.interTextTheme(base.textTheme)
      .apply(bodyColor: PlColors.frost, displayColor: PlColors.frost);

  return base.copyWith(
    textTheme: body.copyWith(
      displayMedium: GoogleFonts.chakraPetch(
          fontSize: 34, fontWeight: FontWeight.w700, color: PlColors.frost, height: 1.1),
      headlineMedium: GoogleFonts.chakraPetch(
          fontSize: 25, fontWeight: FontWeight.w700, color: PlColors.frost),
      titleLarge: GoogleFonts.chakraPetch(
          fontSize: 20, fontWeight: FontWeight.w700, color: PlColors.frost),
      labelSmall: GoogleFonts.chakraPetch(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8,
          color: PlColors.dim),
      bodySmall: GoogleFonts.inter(fontSize: 13, color: PlColors.dim),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: PlColors.frost,
    ),
    cardTheme: CardThemeData(
      color: PlColors.panel,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: PlColors.line, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: PlColors.lime,
        foregroundColor: PlColors.void_,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle:
            GoogleFonts.chakraPetch(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PlColors.frost,
        side: const BorderSide(color: PlColors.line, width: 1.5),
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle:
            GoogleFonts.chakraPetch(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    dividerTheme: const DividerThemeData(color: PlColors.line, thickness: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: PlColors.panel,
      contentTextStyle: GoogleFonts.inter(color: PlColors.frost),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PlColors.panel,
      labelStyle: GoogleFonts.inter(color: PlColors.dim),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PlColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PlColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PlColors.lime),
      ),
    ),
  );
}
