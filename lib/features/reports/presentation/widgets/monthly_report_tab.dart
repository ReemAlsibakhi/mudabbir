import '../../../../core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_card.dart';
import '../../../../shared/ui/widgets/mud_empty_view.dart';
import '../../../../shared/ui/widgets/mud_insight_box.dart';
import '../../../../shared/ui/widgets/mud_progress_bar.dart';
import '../../../../shared/ui/widgets/mud_stat_card.dart';
import '../../../expenses/presentation/providers/expenses_notifier.dart';
import '../../../expenses/presentation/providers/expenses_state.dart';
import '../providers/reports_provider.dart';
import '../../../onboarding/domain/entities/onboarding_profile.dart';
import '../../domain/entities/monthly_report.dart';

class MonthlyReportTab extends ConsumerWidget {
  final String monthKey;
  const MonthlyReportTab({super.key, required this.monthKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report   = ref.watch(monthlyReportProvider(monthKey));
    final expState = ref.watch(expensesNotifierProvider(monthKey));
    final catMap   = expState is ExpensesLoaded
        ? expState.categoryTotals : <String, double>{};

    if (!report.hasData) {
      return const MudEmptyView(
        icon:     '📊',
        title:    AppStrings.noDataMonth,
        subtitle: AppStrings.noDataMonthBody,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [

        // ── Stats grid ────────────────────────────────
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics:        const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.5,
          children: [
            MudStatCard(
              icon: '📥', label: AppStrings.reportIncome,
              value: report.totalIncome.fmt(), sub: AppStrings.reportThisMonth,
              valueColor: AppColors.accentAlt,
            ),
            MudStatCard(
              icon: '📤', label: AppStrings.reportExpense,
              value: report.totalExpenses.fmt(), sub: AppStrings.reportFixedVar,
              valueColor: AppColors.error,
            ),
            MudStatCard(
              icon: report.isDeficit ? '⚠️' : '💾',
              label: report.isDeficit ? AppStrings.reportDeficit : AppStrings.reportBalance,
              value: report.balance.abs().fmt(),
              sub: report.isDeficit ? AppStrings.reportOverBudget : AppStrings.reportSavable,
              valueColor: report.isDeficit ? AppColors.error : AppColors.success,
            ),
            MudStatCard(
              icon: '📊', label: AppStrings.reportSavingRate,
              value: '${report.savingRate.toStringAsFixed(1)}%',
              sub: report.savingRate >= 20 ? AppStrings.ratingExcellent
                 : report.savingRate >= 10 ? AppStrings.ratingGood : AppStrings.ratingImprove,
              valueColor: AppColors.warning,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Persona ───────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.accent.withOpacity(0.12),
              AppColors.accentGreen.withOpacity(0.06),
            ]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accent.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Text(report.personaIcon, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.reportPersona, style: AppTextStyles.caption),
                    Text(report.personaName,
                      style: AppTextStyles.subtitle.copyWith(color: AppColors.accentAlt)),
                    const SizedBox(height: 3),
                    Text(report.personaDesc, style: AppTextStyles.body),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ✅ COUPLE INSIGHT — shown for married/family stage only
        _CoupleInsight(report: report),

        const SizedBox(height: 12),

        // ── Category Breakdown ────────────────────────
        if (catMap.isNotEmpty)
          MudCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MudSectionLabel(AppStrings.reportBreakdown),
                ...(catMap.entries
                    .where((e) => e.value > 0)
                    .toList()
                  ..sort((a, b) => b.value.compareTo(a.value)))
                  .take(8)
                  .map((e) {
                    final cat   = getCategoryById(e.key);
                    final color = Color(cat.color);
                    final pct   = report.totalVariable > 0
                        ? e.value / report.totalVariable : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${cat.icon} ${cat.nameAr}', style: AppTextStyles.body),
                              Text(e.value.fmt(),
                                style: AppTextStyles.bodyBold.copyWith(color: color)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          MudProgressBar(value: pct, color: color),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),

        // ── Insight ───────────────────────────────────
        MudInsightBox(
          type: report.isDeficit ? InsightType.warning
              : report.savingRate >= 20 ? InsightType.success
              : InsightType.info,
          text: report.isDeficit
              ? '${AppStrings.reportDeficitPre}${report.balance.abs().fmt()}${AppStrings.reportDeficitSuf2}'
              : report.savingRate < 10
              ? '${AppStrings.reportLowSavePre}${report.savingRate.toStringAsFixed(1)}${AppStrings.reportLowSaveMid}${(report.totalIncome * 0.2).fmt()}${AppStrings.reportLowSaveSuf}'
              : '${AppStrings.reportExcellentPre}${report.balance.fmt()}${AppStrings.reportExcellentSuf}',
        ),
      ],
    );
  }
}

// ✅ Couple insight — only shows for married/family with both incomes
class _CoupleInsight extends ConsumerWidget {
  final MonthlyReport report;
  const _CoupleInsight({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only relevant for married or family life stage
    final stage = report.lifeStage;
    if (stage == null) return const SizedBox.shrink();
    if (stage != LifeStage.married && stage != LifeStage.family)
      return const SizedBox.shrink();
    if (report.totalIncome <= 0) return const SizedBox.shrink();

    final savingRate = report.savingRate;
    final isGood     = savingRate >= 15;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.accent.withOpacity(0.07),
          AppColors.accentAlt.withOpacity(0.04),
        ]),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: (isGood ? AppColors.success : AppColors.warning)
              .withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.coupleBothIncome,
            style: AppTextStyles.bodyBold),
          const SizedBox(height: 6),
          Text(
            isGood
                ? '${AppStrings.coupleInsightPre}'
                  '${report.totalIncome.fmt()}'
                  '${AppStrings.coupleInsightMid}'
                  '${savingRate.toStringAsFixed(1)}'
                  '${AppStrings.coupleInsightSuf}'
                : AppStrings.coupleLowSaving,
            style: AppTextStyles.body.copyWith(
              color: isGood ? AppColors.success : AppColors.warning,
              fontSize: 13,
              height: 1.5),
          ),
          const SizedBox(height: 8),
          // "Share report" hint
          Row(
            children: [
              const Icon(Icons.share_outlined,
                size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Text(AppStrings.coupleExportHint,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }
}
