import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════
// AppColors — brand + semantic colors (theme-neutral)
//
// For background/surface colors that change with theme,
// use context.colors.bg, context.colors.surface1 etc.
// ══════════════════════════════════════════════════════════

abstract final class AppColors {
  // ── Brand (same in all themes) ─────────────────────────
  static const Color accent      = Color(0xFF2563EB);
  static const Color accentAlt   = Color(0xFF0EA5E9);
  static const Color accentGreen = Color(0xFF06D6A0);

  // ── Semantic (same in all themes) ─────────────────────
  static const Color success  = Color(0xFF10B981);
  static const Color error    = Color(0xFFF43F5E);
  static const Color warning  = Color(0xFFF59E0B);
  static const Color info     = Color(0xFF0EA5E9);
  static const Color purple   = Color(0xFF8B5CF6);
  static const Color orange   = Color(0xFFF97316);

  // ── Gold (Streak) ─────────────────────────────────────
  static const Color gold      = Color(0xFFF59E0B);
  static const Color goldLight = Color(0xFFFCD34D);;

  // ── Gradients ─────────────────────────────────────────
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
    begin:  Alignment.centerRight,
    end:    Alignment.centerLeft,
  );
  static const LinearGradient gold2 = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFCD34D)],
    begin:  Alignment.centerRight,
    end:    Alignment.centerLeft,
  );

  // ── Dark palette (default) ────────────────────────────
  static const Color _darkBg       = Color(0xFF080E1A);
  static const Color _darkSurface1 = Color(0xFF0F1724);
  static const Color _darkSurface2 = Color(0xFF152033);
  static const Color _darkSurface3 = Color(0xFF1A2840);
  static const Color _darkText1    = Color(0xFFF0F6FF);
  static const Color _darkText2    = Color(0xFF94A3B8);
  static const Color _darkText3    = Color(0xFF475569);
  static const Color _darkBorder   = Color(0x0FFFFFFF);

  // ── Light palette ─────────────────────────────────────
  static const Color _lightBg       = Color(0xFFF0F4F8);
  static const Color _lightSurface1 = Color(0xFFFFFFFF);
  static const Color _lightSurface2 = Color(0xFFF5F7FA);
  static const Color _lightSurface3 = Color(0xFFE8EDF3);
  static const Color _lightText1    = Color(0xFF0D1117);
  static const Color _lightText2    = Color(0xFF4A5568);
  static const Color _lightText3    = Color(0xFF718096);
  static const Color _lightBorder   = Color(0xFFE2E8F0);

  // ── Static fallbacks (dark) — for const contexts ──────
  static const Color bg            = _darkBg;
  static const Color surface1      = _darkSurface1;
  static const Color surface2      = _darkSurface2;
  static const Color surface3      = _darkSurface3;
  static const Color surface4      = Color(0xFF1F3050);
  static const Color textPrimary   = _darkText1;
  static const Color textSecondary = _darkText2;
  static const Color textTertiary  = _darkText3;
  static const Color textDisabled  = Color(0xFF334155);
  static const Color border        = _darkBorder;
  static const Color borderMid     = Color(0x1AFFFFFF);
  static const Color borderStrong  = Color(0x29FFFFFF);

  // ── Theme-aware getters (requires BuildContext) ────────
  static Color bgOf      (BuildContext c) => _d(c, _darkBg,       _lightBg);
  static Color surface1Of(BuildContext c) => _d(c, _darkSurface1, _lightSurface1);
  static Color surface2Of(BuildContext c) => _d(c, _darkSurface2, _lightSurface2);
  static Color surface3Of(BuildContext c) => _d(c, _darkSurface3, _lightSurface3);
  static Color text1Of   (BuildContext c) => _d(c, _darkText1,    _lightText1);
  static Color text2Of   (BuildContext c) => _d(c, _darkText2,    _lightText2);
  static Color text3Of   (BuildContext c) => _d(c, _darkText3,    _lightText3);
  static Color borderOf  (BuildContext c) => _d(c, _darkBorder,   _lightBorder);

  static Color _d(BuildContext c, Color dark, Color light) =>
      Theme.of(c).brightness == Brightness.dark ? dark : light;
}
