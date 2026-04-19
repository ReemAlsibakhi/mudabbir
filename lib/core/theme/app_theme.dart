import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3:              true,
    brightness:                Brightness.dark,
    scaffoldBackgroundColor:   AppColors.bg,
    fontFamily:                'Cairo',

    // ── RTL: Arabic text alignment ────────────────────
    // Flutter respects Directionality for most widgets,
    // but we also set these explicitly for safety
    colorScheme:               _colorScheme,
    appBarTheme:               _appBar,
    cardTheme:                 _card,
    inputDecorationTheme:      _input,
    elevatedButtonTheme:       _button,
    textTheme:                 _textTheme,
    dividerTheme:              const DividerThemeData(color: AppColors.border, space: 1),
    snackBarTheme:             _snackBar,
    bottomSheetTheme:          _bottomSheet,
    dialogTheme:               _dialog,
    checkboxTheme:             _checkbox,
    listTileTheme:             _listTile,
  );

  static const _colorScheme = ColorScheme.dark(
    primary:                    AppColors.accent,
    secondary:                  AppColors.accentAlt,
    surface:                    AppColors.surface1,
    error:                      AppColors.error,
    onPrimary:                  Colors.white,
    onSurface:                  AppColors.textPrimary,
    surfaceContainerHighest:    AppColors.surface2,
  );

  static const _appBar = AppBarTheme(
    backgroundColor:            AppColors.surface1,
    surfaceTintColor:           Colors.transparent,
    elevation:                  0,
    scrolledUnderElevation:     0,
    centerTitle:                true,           // centered in RTL ✅
    titleTextStyle:             AppTextStyles.title,
    systemOverlayStyle:         SystemUiOverlayStyle(
      statusBarColor:           Colors.transparent,
      statusBarIconBrightness:  Brightness.light,
    ),
  );

  static CardTheme get _card => CardTheme(
    color:     AppColors.surface1,
    elevation: 0,
    shape:     RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.border),
    ),
    margin: EdgeInsets.zero,
  );

  static InputDecorationTheme get _input => InputDecorationTheme(
    filled:          true,
    fillColor:       AppColors.surface2,
    labelStyle:      AppTextStyles.body.copyWith(color: AppColors.textSecondary),
    hintStyle:       AppTextStyles.body.copyWith(color: AppColors.textTertiary),
    // RTL: label floats correctly with these borders
    border:          _inputBorder(AppColors.border),
    enabledBorder:   _inputBorder(AppColors.border),
    focusedBorder:   _inputBorder(AppColors.accent, width: 1.5),
    errorBorder:     _inputBorder(AppColors.error),
    disabledBorder:  _inputBorder(AppColors.textDisabled),
    contentPadding:  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    errorStyle:      AppTextStyles.caption.copyWith(color: AppColors.error),
    // Align label to right in RTL
    alignLabelWithHint: true,
  );

  static OutlineInputBorder _inputBorder(Color c, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   BorderSide(color: c, width: width),
      );

  static ElevatedButtonThemeData get _button => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor:   AppColors.accent,
      foregroundColor:   Colors.white,
      elevation:         0,
      padding:           const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      shape:             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle:         AppTextStyles.button,
      minimumSize:       const Size(double.infinity, 50),
    ),
  );

  // RTL-aware text theme — all styles inherit direction from Directionality
  static const _textTheme = TextTheme(
    displayLarge:   AppTextStyles.display,
    headlineLarge:  AppTextStyles.headline1,
    headlineMedium: AppTextStyles.headline2,
    titleLarge:     AppTextStyles.title,
    titleMedium:    AppTextStyles.subtitle,
    bodyLarge:      AppTextStyles.bodyBold,
    bodyMedium:     AppTextStyles.body,
    labelSmall:     AppTextStyles.label,
  );

  static SnackBarThemeData get _snackBar => SnackBarThemeData(
    backgroundColor:  AppColors.surface3,
    contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
    shape:            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    behavior:         SnackBarBehavior.floating,
  );

  static BottomSheetThemeData get _bottomSheet => const BottomSheetThemeData(
    backgroundColor:  AppColors.surface2,
    shape:            RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    dragHandleColor:  AppColors.textTertiary,
    showDragHandle:   true,
  );

  static DialogTheme get _dialog => DialogTheme(
    backgroundColor:  AppColors.surface2,
    shape:            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    titleTextStyle:   AppTextStyles.title,
    contentTextStyle: AppTextStyles.body,
  );

  static CheckboxThemeData get _checkbox => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? AppColors.accent : AppColors.surface3),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );

  // RTL list tiles — icon on right, text on left (Arabic reading order)
  static const ListTileThemeData _listTile = ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16),
  );
}
