import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeuTheme {
  static const double _depth = 4.0;
  static const double _intensity = 0.2;
  static const double _blurIntensity = 5.0;

  static BoxDecoration getNeumorphicDecoration({
    required BuildContext context,
    bool isPressed = false,
    double radius = 16.0,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final baseColor = color ?? theme.scaffoldBackgroundColor;
    final isLightTheme = theme.brightness == Brightness.light;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: baseColor,
      boxShadow: isPressed
          ? [
              BoxShadow(
                color: isLightTheme
                    ? Colors.black.withOpacity(_intensity)
                    : Colors.black.withOpacity(_intensity * 2),
                offset: const Offset(_depth / 2, _depth / 2),
                blurRadius: _blurIntensity,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: isLightTheme
                    ? Colors.white.withOpacity(_intensity)
                    : Colors.white.withOpacity(_intensity / 4),
                offset: const Offset(-_depth / 2, -_depth / 2),
                blurRadius: _blurIntensity,
                spreadRadius: 1,
              ),
            ]
          : [
              BoxShadow(
                color: isLightTheme
                    ? Colors.white.withOpacity(_intensity)
                    : Colors.white.withOpacity(_intensity / 4),
                offset: const Offset(-_depth, -_depth),
                blurRadius: _blurIntensity,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: isLightTheme
                    ? Colors.black.withOpacity(_intensity)
                    : Colors.black.withOpacity(_intensity * 2),
                offset: const Offset(_depth, _depth),
                blurRadius: _blurIntensity,
                spreadRadius: 1,
              ),
            ],
    );
  }

  static ColorScheme getLightColorScheme() {
    return const ColorScheme.light(
      primary: Color(0xFF2D3250),
      secondary: Color(0xFF424769),
      tertiary: Color(0xFFF6B17A),
      background: Color(0xFFF0F0F3),
      surface: Color(0xFFF0F0F3),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Color(0xFF2D3250),
      onSurface: Color(0xFF2D3250),
    );
  }

  static ColorScheme getDarkColorScheme() {
    return const ColorScheme.dark(
      primary: Color(0xFFF6B17A),
      secondary: Color(0xFF7077A1),
      tertiary: Color(0xFF2D3250),
      background: Color(0xFF13131A),
      surface: Color(0xFF13131A),
      onPrimary: Color(0xFF2D3250),
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
    );
  }

  static ThemeData getLightTheme() {
    final baseTheme = ThemeData.light();
    return baseTheme.copyWith(
      colorScheme: getLightColorScheme(),
      scaffoldBackgroundColor: const Color(0xFFF0F0F3),
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme).apply(
        bodyColor: const Color(0xFF2D3250),
        displayColor: const Color(0xFF2D3250),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData getDarkTheme() {
    final baseTheme = ThemeData.dark();
    return baseTheme.copyWith(
      colorScheme: getDarkColorScheme(),
      scaffoldBackgroundColor: const Color(0xFF13131A),
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      useMaterial3: true,
    );
  }
}