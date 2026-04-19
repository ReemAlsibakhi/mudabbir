import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const String _font = 'Cairo';

  static const TextStyle display = TextStyle(
    fontFamily: _font, fontSize: 32,
    fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -1.5,
  );
  static const TextStyle headline1 = TextStyle(
    fontFamily: _font, fontSize: 24,
    fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5,
  );
  static const TextStyle headline2 = TextStyle(
    fontFamily: _font, fontSize: 20,
    fontWeight: FontWeight.w800, color: AppColors.textPrimary,
  );
  static const TextStyle title = TextStyle(
    fontFamily: _font, fontSize: 17,
    fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static const TextStyle subtitle = TextStyle(
    fontFamily: _font, fontSize: 15,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontFamily: _font, fontSize: 13,
    fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.7,
  );
  static const TextStyle bodyBold = TextStyle(
    fontFamily: _font, fontSize: 13,
    fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: _font, fontSize: 11,
    fontWeight: FontWeight.w400, color: AppColors.textTertiary,
  );
  static const TextStyle label = TextStyle(
    fontFamily: _font, fontSize: 10,
    fontWeight: FontWeight.w700, color: AppColors.textTertiary,
    letterSpacing: 0.8,
  );
  static const TextStyle amount = TextStyle(
    fontFamily: _font, fontSize: 22,
    fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -1.0,
  );
  static const TextStyle button = TextStyle(
    fontFamily: _font, fontSize: 15,
    fontWeight: FontWeight.w700, color: Colors.white,
  );
}
