import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Backgrounds ───────────────────────────────────────
  static const Color bg       = Color(0xFF080E1A);
  static const Color surface1 = Color(0xFF0F1724);
  static const Color surface2 = Color(0xFF152033);
  static const Color surface3 = Color(0xFF1A2840);
  static const Color surface4 = Color(0xFF1F3050);

  // ── Brand ─────────────────────────────────────────────
  static const Color accent      = Color(0xFF2563EB);
  static const Color accentAlt   = Color(0xFF0EA5E9);
  static const Color accentGreen = Color(0xFF06D6A0);

  // ── Semantic ──────────────────────────────────────────
  static const Color success  = Color(0xFF10B981);
  static const Color error    = Color(0xFFF43F5E);
  static const Color warning  = Color(0xFFF59E0B);
  static const Color info     = Color(0xFF0EA5E9);
  static const Color purple   = Color(0xFF8B5CF6);
  static const Color orange   = Color(0xFFF97316);

  // ── Gold (Streak) ─────────────────────────────────────
  static const Color gold      = Color(0xFFF59E0B);
  static const Color goldLight = Color(0xFFFCD34D);

  // ── Text ──────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF0F6FF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary  = Color(0xFF475569);
  static const Color textDisabled  = Color(0xFF334155);

  // ── Borders ───────────────────────────────────────────
  static const Color border       = Color(0x0FFFFFFF); // 6% white
  static const Color borderMid    = Color(0x1AFFFFFF); // 10% white
  static const Color borderStrong = Color(0x29FFFFFF); // 16% white

  // ── Gradients ─────────────────────────────────────────
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [accent, accentAlt],
  );

  static const LinearGradient primaryDeep = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [Color(0xFF1E3A5F), Color(0xFF0F2744)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [success, accentGreen],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );
}
