import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional, Clean Design System for QuickSlot
/// Inspired by modern sports apps like Nike Training Club, Strava, and ClassPass
class AppTheme {
  // Primary Brand Colors - Clean & Professional
  static const _primaryBlue = Color(0xFF2D6BFF);      // Vibrant trustworthy blue
  static const _accentOrange = Color(0xFFFF6B35);     // Energetic orange
  static const _successGreen = Color(0xFF00D4AA);     // Fresh success green
  static const _errorRed = Color(0xFFFF3B30);         // Clear error red
  
  // Neutral Backgrounds - Dark Mode Optimized
  static const _darkBg = Color(0xFF0A0E27);           // Deep navy background
  static const _darkSurface = Color(0xFF141B34);      // Elevated surface
  static const _darkCard = Color(0xFF1E2846);         // Card background
  static const _darkBorder = Color(0xFF2A3555);       // Subtle borders
  
  // Text Colors
  static const _textPrimary = Color(0xFFFFFFFF);      // Pure white
  static const _textSecondary = Color(0xFFB0B8D4);    // Muted blue-gray
  static const _textTertiary = Color(0xFF6B7399);     // Even more muted
  
  // Sport-Specific Colors
  static const _badmintonGreen = Color(0xFF00D4AA);   // Badminton courts
  static const _footballOrange = Color(0xFFFF6B35);   // Football turf

  // Gradient Definitions
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF2D6BFF), Color(0xFF5B8CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C61)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const successGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF00E5BD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkBg,
    colorScheme: ColorScheme.dark(
      primary: _primaryBlue,
      secondary: _accentOrange,
      tertiary: _successGreen,
      error: _errorRed,
      surface: _darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _textPrimary,
      outline: _darkBorder,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: _textPrimary,
        letterSpacing: -1,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: _darkCard,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: _darkBorder,
          width: 1,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _darkBg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
      ),
      iconTheme: IconThemeData(color: _textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
        elevation: 0,
        shadowColor: _primaryBlue.withValues(alpha: 0.3),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _primaryBlue, width: 2),
      ),
    ),
    useMaterial3: true,
  );

  // Semantic Colors for App States
  static const Color available = _successGreen;
  static const Color booked = _errorRed;
  static const Color pending = Color(0xFFFFA726);
  static const Color badminton = _badmintonGreen;
  static const Color football = _footballOrange;
  
  // Background Colors
  static const Color background = _darkBg;
  static const Color surface = _darkSurface;
  static const Color cardBg = _darkCard;
  static const Color border = _darkBorder;
  
  // Text Colors
  static const Color textPrimary = _textPrimary;
  static const Color textSecondary = _textSecondary;
  static const Color textTertiary = _textTertiary;
  
  // Brand Colors
  static const Color primary = _primaryBlue;
  static const Color accent = _accentOrange;
  static const Color success = _successGreen;
  static const Color error = _errorRed;

  // Elevation & Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  // Gradient Decorations
  static BoxDecoration primaryGradientBox({double radius = 20}) => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: _primaryBlue.withValues(alpha: 0.3),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  static BoxDecoration accentGradientBox({double radius = 20}) => BoxDecoration(
    gradient: accentGradient,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: _accentOrange.withValues(alpha: 0.3),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  static BoxDecoration successGradientBox({double radius = 20}) => BoxDecoration(
    gradient: successGradient,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: _successGreen.withValues(alpha: 0.3),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // Glass Morphism Effect
  static BoxDecoration get glassMorphism => BoxDecoration(
    color: _darkSurface.withValues(alpha: 0.6),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.1),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 10,
      ),
    ],
  );
  
  // Neumorphism Card
  static BoxDecoration get neumorphicCard => BoxDecoration(
    color: _darkCard,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: _darkBorder),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 20,
        offset: const Offset(8, 8),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.02),
        blurRadius: 20,
        offset: const Offset(-8, -8),
      ),
    ],
  );
  
  // Sport-Specific Gradient
  static LinearGradient sportGradient(String sport) {
    if (sport.toLowerCase() == 'badminton') {
      return const LinearGradient(
        colors: [Color(0xFF00D4AA), Color(0xFF00E5BD)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFFFF6B35), Color(0xFFFF8C61)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }
  
  // Get sport color
  static Color sportColor(String sport) {
    return sport.toLowerCase() == 'badminton' ? badminton : football;
  }
}
