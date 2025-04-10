import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF2D3250),
      secondary: Color(0xFF424769),
      tertiary: Color(0xFFF6B17A),
      surface: Color(0xFF7077A1).withOpacity(0.1),
      background: Color(0xFFF6F6F6),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3250),
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2D3250),
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: Color(0xFF2D3250),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFFF6B17A),
      secondary: Color(0xFF7077A1),
      tertiary: Color(0xFF2D3250),
      surface: Color(0xFF424769).withOpacity(0.1),
      background: Color(0xFF121212),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: Colors.black87.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}