import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/insight.dart';
import '../providers/insights_notifier.dart';

// ══════════════════════════════════════════════════════════
// InsightCard — renders a single insight with type-aware styling
// ══════════════════════════════════════════════════════════

class InsightCard extends ConsumerWidget {
  final Insight insight;
  const InsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = _InsightStyle.from(insight.type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin:   const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color:        style.background,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: style.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon ──────────────────────────────────────
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color:        style.iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(style.icon,
                  style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),

            // ── Content ───────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.message,
                    style: AppTextStyles.body.copyWith(
                      color:  style.textColor,
                      height: 1.5,
                    ),
                  ),
                  if (insight.actionLabel != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        if (insight.actionRoute != null) {
                          context.go(insight.actionRoute!);
                        }
                      },
                      child: Text(
                        insight.actionLabel!,
                        style: AppTextStyles.caption.copyWith(
                          color:      style.actionColor,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: style.actionColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Dismiss button ─────────────────────────────
            GestureDetector(
              onTap: () => ref
                  .read(insightsNotifierProvider.notifier)
                  .dismiss(insight.id),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size:  16,
                  color: style.textColor.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// _InsightStyle — type-safe style mapping
// ══════════════════════════════════════════════════════════

class _InsightStyle {
  final Color  background, border, textColor, iconBackground, actionColor;
  final String icon;

  const _InsightStyle({
    required this.background,
    required this.border,
    required this.textColor,
    required this.iconBackground,
    required this.actionColor,
    required this.icon,
  });

  factory _InsightStyle.from(InsightType type) => switch (type) {
    InsightType.danger => _InsightStyle(
      background:     const Color(0xFF1C0A0A),
      border:         AppColors.error.withOpacity(0.25),
      textColor:      const Color(0xFFFFB3B3),
      iconBackground: AppColors.error.withOpacity(0.15),
      actionColor:    AppColors.error,
      icon:           '🔴',
    ),
    InsightType.warning => _InsightStyle(
      background:     const Color(0xFF1A1400),
      border:         AppColors.warning.withOpacity(0.25),
      textColor:      const Color(0xFFFFE0A0),
      iconBackground: AppColors.warning.withOpacity(0.15),
      actionColor:    AppColors.warning,
      icon:           '⚠️',
    ),
    InsightType.celebration => _InsightStyle(
      background:     const Color(0xFF1A1400),
      border:         AppColors.gold.withOpacity(0.25),
      textColor:      const Color(0xFFFFF3C4),
      iconBackground: AppColors.gold.withOpacity(0.12),
      actionColor:    AppColors.gold,
      icon:           '🎉',
    ),
    InsightType.motivation => _InsightStyle(
      background:     const Color(0xFF0A1020),
      border:         AppColors.accentAlt.withOpacity(0.25),
      textColor:      const Color(0xFFA5F3FC),
      iconBackground: AppColors.accentAlt.withOpacity(0.1),
      actionColor:    AppColors.accentAlt,
      icon:           '💡',
    ),
    InsightType.info => _InsightStyle(
      background:     AppColors.surface2,
      border:         AppColors.border,
      textColor:      AppColors.textSecondary,
      iconBackground: AppColors.surface3,
      actionColor:    AppColors.accent,
      icon:           'ℹ️',
    ),
  };
}
