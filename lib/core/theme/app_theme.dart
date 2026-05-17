import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {

  static ThemeData get dark => _build(
    brightness:  Brightness.dark,
    scaffold:    const Color(0xFF080E1A),
    surface:     const Color(0xFF0F1724),
    card:        const Color(0xFF152033),
    text1:       const Color(0xFFF0F6FF),
    text2:       const Color(0xFF94A3B8),
    border:      const Color(0x0FFFFFFF),
    fillColor:   const Color(0xFF1A2840),
    hintColor:   Colors.white38,
  );

  static ThemeData get light => _build(
    brightness:  Brightness.light,
    scaffold:    const Color(0xFFF0F4F8),
    surface:     Colors.white,
    card:        const Color(0xFFF5F7FA),
    text1:       const Color(0xFF0D1117),
    text2:       const Color(0xFF4A5568),
    border:      const Color(0xFFE2E8F0),
    fillColor:   Colors.white,
    hintColor:   Colors.black38,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color scaffold,
    required Color surface,
    required Color card,
    required Color text1,
    required Color text2,
    required Color border,
    required Color fillColor,
    required Color hintColor,
  }) => ThemeData(
    brightness:              brightness,
    fontFamily:              'Cairo',
    scaffoldBackgroundColor: scaffold,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary:    AppColors.accent,
      secondary:  AppColors.accentAlt,
      surface:    surface,
      error:      AppColors.error,
      onPrimary:  Colors.white,
      onSecondary: Colors.white,
      onSurface:  text1,
      onError:    Colors.white,
    ),
    cardColor:  card,
    cardTheme:  CardTheme(
      color:       card,
      elevation:   0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:         BorderSide(color: border, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:    true,
      fillColor: fillColor,
      hintStyle: TextStyle(
        fontFamily: 'Cairo', color: hintColor, fontSize: 14),
      labelStyle: TextStyle(
        fontFamily: 'Cairo', color: hintColor, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide:   BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide:   BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide:   const BorderSide(color: AppColors.accent, width: 1.5)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scaffold,
      elevation:       0,
      foregroundColor: text1,
    ),
    dividerTheme: DividerThemeData(color: border, thickness: 1),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? AppColors.accentAlt : Colors.grey),
      trackColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected)
          ? AppColors.accentAlt.withValues(alpha: 0.4)
          : (brightness == Brightness.dark ? Colors.white12 : Colors.black12)),
    ),
    textTheme: TextTheme(
      bodyLarge:   AppTextStyles.body.copyWith(color: text1),
      bodyMedium:  AppTextStyles.body.copyWith(color: text2),
      titleLarge:  AppTextStyles.title.copyWith(color: text1),
      titleMedium: AppTextStyles.subtitle.copyWith(color: text1),
    ),
  );
}
