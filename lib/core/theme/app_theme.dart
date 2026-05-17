import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

// ══════════════════════════════════════════════════════════
// AppTheme — Dark + Light themes
// Dark:  default — modern, easy on eyes at night
// Light: high contrast — better for elderly users (60+)
// ══════════════════════════════════════════════════════════

abstract final class AppTheme {

  // ── Dark Theme (default) ───────────────────────────────
  static ThemeData get dark => ThemeData(
    brightness:       Brightness.dark,
    fontFamily:       'Cairo',
    scaffoldBackgroundColor: const Color(0xFF0A0D12),
    colorScheme: ColorScheme.dark(
      primary:   AppColors.accent,
      secondary: AppColors.accentAlt,
      surface:   const Color(0xFF131720),
      error:     AppColors.error,
    ),
    inputDecorationTheme: _inputTheme(
      fillColor:  const Color(0xFF1A2030),
      textColor:  Colors.white,
      hintColor:  Colors.white38,
      borderColor: Colors.white12,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A0D12),
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    tabBarTheme: TabBarTheme(
      labelStyle:         AppTextStyles.bodyBold.copyWith(fontSize: 14),
      unselectedLabelStyle: AppTextStyles.body.copyWith(fontSize: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF1E2532), thickness: 1),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? AppColors.accentAlt : Colors.grey),
      trackColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected)
          ? AppColors.accentAlt.withValues(alpha: 0.4)
          : Colors.white12),
    ),
  );

  // ── Light Theme — high contrast for elderly ────────────
  static ThemeData get light => ThemeData(
    brightness:       Brightness.light,
    fontFamily:       'Cairo',
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    colorScheme: ColorScheme.light(
      primary:   AppColors.accent,
      secondary: AppColors.accentAlt,
      surface:   Colors.white,
      error:     AppColors.error,
    ),
    inputDecorationTheme: _inputTheme(
      fillColor:  Colors.white,
      textColor:  const Color(0xFF0D0D0D),
      hintColor:  Colors.black38,
      borderColor: Colors.black12,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation:       0.5,
      foregroundColor: Color(0xFF0D0D0D),
    ),
    tabBarTheme: TabBarTheme(
      labelStyle:         AppTextStyles.bodyBold.copyWith(fontSize: 14),
      unselectedLabelStyle: AppTextStyles.body.copyWith(fontSize: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0), thickness: 1),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? AppColors.accentAlt : Colors.grey),
      trackColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected)
          ? AppColors.accentAlt.withValues(alpha: 0.4)
          : Colors.black12),
    ),
  );

  static InputDecorationTheme _inputTheme({
    required Color fillColor,
    required Color textColor,
    required Color hintColor,
    required Color borderColor,
  }) => InputDecorationTheme(
    filled:      true,
    fillColor:   fillColor,
    hintStyle:   TextStyle(fontFamily: 'Cairo', color: hintColor, fontSize: 14),
    labelStyle:  TextStyle(fontFamily: 'Cairo', color: hintColor, fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(color: borderColor)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(color: borderColor)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(color: AppColors.accent, width: 1.5)),
  );
}
