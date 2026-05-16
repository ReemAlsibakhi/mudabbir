import 'package:flutter/material.dart';
import 'app_colors.dart';

// ══════════════════════════════════════════════════════════
// AppTextStyles — single source of truth for all font sizes
//
// SCALE SYSTEM:
//   Font sizes are BASE values at scale = 1.0 (medium)
//   The app applies a global textScaler set by the user in Settings.
//   No widget needs to change — Flutter scales all Text() automatically.
//
// BASE SIZES chosen for Arabic readability:
//   display     44  — large balance numbers
//   headline1   30  — screen titles
//   headline2   26  — section headers
//   title       20  — card titles, AppBar
//   subtitle    18  — secondary headers
//   body        16  — main reading text   ← was 14, Arabic needs more
//   bodyBold    16  — emphasized body
//   caption     14  — supporting text     ← was 12
//   label       13  — badges, tags        ← was 11
//   amount      42  — balance display
//   amountSmall 28  — secondary amounts
//   button      17  — button labels
// ══════════════════════════════════════════════════════════

abstract final class AppTextStyles {
  static const String _f = 'Cairo';

  // ── Display ───────────────────────────────────────────
  static const TextStyle display = TextStyle(
    fontFamily:   _f,
    fontSize:     44,
    fontWeight:   FontWeight.w900,
    color:        AppColors.textPrimary,
    letterSpacing: -2.0,
    height:       1.0,
  );

  // ── Headlines ─────────────────────────────────────────
  static const TextStyle headline1 = TextStyle(
    fontFamily:   _f,
    fontSize:     30,
    fontWeight:   FontWeight.w900,
    color:        AppColors.textPrimary,
    letterSpacing: -0.8,
    height:       1.2,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily:   _f,
    fontSize:     26,
    fontWeight:   FontWeight.w800,
    color:        AppColors.textPrimary,
    letterSpacing: -0.4,
    height:       1.3,
  );

  // ── Titles ────────────────────────────────────────────
  static const TextStyle title = TextStyle(
    fontFamily:   _f,
    fontSize:     20,
    fontWeight:   FontWeight.w700,
    color:        AppColors.textPrimary,
    letterSpacing: -0.2,
    height:       1.3,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily:   _f,
    fontSize:     18,
    fontWeight:   FontWeight.w600,
    color:        AppColors.textPrimary,
    height:       1.4,
  );

  // ── Body ──────────────────────────────────────────────
  static const TextStyle body = TextStyle(
    fontFamily:   _f,
    fontSize:     16,
    fontWeight:   FontWeight.w400,
    color:        AppColors.textSecondary,
    height:       1.7,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily:   _f,
    fontSize:     16,
    fontWeight:   FontWeight.w700,
    color:        AppColors.textPrimary,
    height:       1.5,
  );

  // ── Caption / Supporting ──────────────────────────────
  static const TextStyle caption = TextStyle(
    fontFamily:   _f,
    fontSize:     14,
    fontWeight:   FontWeight.w400,
    color:        AppColors.textTertiary,
    height:       1.6,
  );

  static const TextStyle label = TextStyle(
    fontFamily:   _f,
    fontSize:     13,
    fontWeight:   FontWeight.w700,
    color:        AppColors.textTertiary,
    letterSpacing: 0.4,
  );

  // ── Amount ────────────────────────────────────────────
  static const TextStyle amount = TextStyle(
    fontFamily:   _f,
    fontSize:     42,
    fontWeight:   FontWeight.w900,
    color:        AppColors.textPrimary,
    letterSpacing: -1.5,
    height:       1.0,
  );

  static const TextStyle amountSmall = TextStyle(
    fontFamily:   _f,
    fontSize:     28,
    fontWeight:   FontWeight.w900,
    color:        AppColors.textPrimary,
    letterSpacing: -0.8,
    height:       1.1,
  );

  // ── Button ────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontFamily:   _f,
    fontSize:     17,
    fontWeight:   FontWeight.w700,
    color:        Colors.white,
    letterSpacing: 0.1,
  );
}
