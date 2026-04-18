import 'package:flutter/material.dart';

// ═══════════════════════════════════════
// MUDABBIR — ثيم التطبيق
// ═══════════════════════════════════════

class AppColors {
  // Background
  static const Color bg        = Color(0xFF080E1A);
  static const Color surface1  = Color(0xFF0F1724);
  static const Color surface2  = Color(0xFF152033);
  static const Color surface3  = Color(0xFF1A2840);
  static const Color surface4  = Color(0xFF1F3050);

  // Accent
  static const Color accent    = Color(0xFF2563EB);
  static const Color accent2   = Color(0xFF0EA5E9);
  static const Color accent3   = Color(0xFF06D6A0);

  // Status
  static const Color green     = Color(0xFF10B981);
  static const Color red       = Color(0xFFF43F5E);
  static const Color gold      = Color(0xFFF59E0B);
  static const Color purple    = Color(0xFF8B5CF6);
  static const Color orange    = Color(0xFFF97316);

  // Text
  static const Color textPrimary   = Color(0xFFF0F6FF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary  = Color(0xFF475569);

  // Border
  static const Color border    = Color(0x14FFFFFF);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accent2],
  );
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green, accent3],
  );
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Cairo',

    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.accent2,
      surface: AppColors.surface1,
      error: AppColors.red,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface1,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),

    cardTheme: CardTheme(
      color: AppColors.surface1,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo'),
      hintStyle: const TextStyle(color: AppColors.textTertiary, fontFamily: 'Cairo'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),

    textTheme: const TextTheme(
      displayLarge:  TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: AppColors.textPrimary),
      headlineLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      headlineMedium:TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      titleLarge:    TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      titleMedium:   TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyLarge:     TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400, color: AppColors.textPrimary),
      bodyMedium:    TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400, color: AppColors.textSecondary),
      labelSmall:    TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: AppColors.textTertiary),
    ),
  );
}
