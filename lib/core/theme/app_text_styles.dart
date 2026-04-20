import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const String _f = 'Cairo';

  // ── Display ────────────────────────────────────────────
  // الأرقام الكبيرة مثل الرصيد
  static const TextStyle display = TextStyle(
    fontFamily: _f, fontSize: 40,
    fontWeight: FontWeight.w900, color: AppColors.textPrimary,
    letterSpacing: -2.0, height: 1.0,
  );

  // ── Headlines ──────────────────────────────────────────
  static const TextStyle headline1 = TextStyle(
    fontFamily: _f, fontSize: 26,
    fontWeight: FontWeight.w900, color: AppColors.textPrimary,
    letterSpacing: -0.8, height: 1.2,
  );
  static const TextStyle headline2 = TextStyle(
    fontFamily: _f, fontSize: 22,
    fontWeight: FontWeight.w800, color: AppColors.textPrimary,
    letterSpacing: -0.4,
  );

  // ── Titles ─────────────────────────────────────────────
  static const TextStyle title = TextStyle(
    fontFamily: _f, fontSize: 18,
    fontWeight: FontWeight.w700, color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );
  static const TextStyle subtitle = TextStyle(
    fontFamily: _f, fontSize: 16,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );

  // ── Body ───────────────────────────────────────────────
  static const TextStyle body = TextStyle(
    fontFamily: _f, fontSize: 14,       // ← 14 instead of 13
    fontWeight: FontWeight.w400, color: AppColors.textSecondary,
    height: 1.7,
  );
  static const TextStyle bodyBold = TextStyle(
    fontFamily: _f, fontSize: 14,
    fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );

  // ── Small ──────────────────────────────────────────────
  static const TextStyle caption = TextStyle(
    fontFamily: _f, fontSize: 12,       // ← 12 instead of 11
    fontWeight: FontWeight.w400, color: AppColors.textTertiary,
    height: 1.5,
  );
  static const TextStyle label = TextStyle(
    fontFamily: _f, fontSize: 11,       // ← 11 instead of 10
    fontWeight: FontWeight.w700, color: AppColors.textTertiary,
    letterSpacing: 0.6,
  );

  // ── Amount ─────────────────────────────────────────────
  static const TextStyle amount = TextStyle(
    fontFamily: _f, fontSize: 36,
    fontWeight: FontWeight.w900, color: AppColors.textPrimary,
    letterSpacing: -1.5, height: 1.0,
  );
  static const TextStyle amountSmall = TextStyle(
    fontFamily: _f, fontSize: 24,
    fontWeight: FontWeight.w900, color: AppColors.textPrimary,
    letterSpacing: -0.8,
  );

  // ── Button ─────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontFamily: _f, fontSize: 15,
    fontWeight: FontWeight.w700, color: Colors.white,
    letterSpacing: 0.1,
  );
}
