import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern vibrant color palette with depth
  static const _primaryPurple = Color(0xFF8B5CF6);
  static const _secondaryBlue = Color(0xFF3B82F6);
  static const _accentPink = Color(0xFFEC4899);
  static const _successGreen = Color(0xFF10B981);
  static const _warningOrange = Color(0xFFF59E0B);
  static const _errorRed = Color(0xFFEF4444);
  
  // Dark mode backgrounds with depth
  static const _bg = Color(0xFF0F172A);
  static const _surface = Color(0xFF1E293B);
  static const _card = Color(0xFF334155);
  
  // Gradient colors
  static const gradientStart = Color(0xFF8B5CF6);
  static const gradientMiddle = Color(0xFF6366F1);
  static const gradientEnd = Color(0xFF3B82F6);

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _bg,
    colorScheme: ColorScheme.dark(
      primary: _primaryPurple,
      secondary: _secondaryBlue,
      tertiary: _accentPink,
      error: _errorRed,
      surface: _surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    cardTheme: CardThemeData(
      color: _card,
      elevation: 8,
      shadowColor: _primaryPurple.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        side: BorderSide(
          color: _primaryPurple.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _bg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
        elevation: 8,
        shadowColor: _primaryPurple.withValues(alpha: 0.5),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
    ),
    useMaterial3: true,
  );

  static const Color available = _successGreen;
  static const Color booked = _errorRed;
  static const Color courtBlue = _secondaryBlue;
  static const Color highlight = _warningOrange;
  static const Color background = _bg;
  static const Color cardBg = _card;
  static const Color surface = _surface;
  static const Color primary = _primaryPurple;
  static const Color accent = _accentPink;
  
  // Gradient decoration for premium look
  static BoxDecoration get gradientContainer => BoxDecoration(
    gradient: const LinearGradient(
      colors: [gradientStart, gradientMiddle, gradientEnd],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: _primaryPurple.withValues(alpha: 0.3),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
  
  // Glass morphism effect
  static BoxDecoration get glassMorphism => BoxDecoration(
    color: _surface.withValues(alpha: 0.7),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.1),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );
}
