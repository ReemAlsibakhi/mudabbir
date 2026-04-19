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
import '../providers/reports_provider.dart';

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
        title:    'لا توجد بيانات لهذا الشهر',
        subtitle: 'ابدأ بإدخال دخلك ومصاريفك',
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
              icon: '📥', label: 'الدخل',
              value: report.totalIncome.fmt(), sub: 'هذا الشهر',
              valueColor: AppColors.accentAlt,
            ),
            MudStatCard(
              icon: '📤', label: 'المصروف',
              value: report.totalExpenses.fmt(), sub: 'ثابت + متغير',
              valueColor: AppColors.error,
            ),
            MudStatCard(
              icon: report.isDeficit ? '⚠️' : '💾',
              label: report.isDeficit ? 'العجز' : 'الفائض',
              value: report.balance.abs().fmt(),
              sub: report.isDeficit ? 'تجاوزت الميزانية' : 'قابل للادخار',
              valueColor: report.isDeficit ? AppColors.error : AppColors.success,
            ),
            MudStatCard(
              icon: '📊', label: 'نسبة الادخار',
              value: '${report.savingRate.toStringAsFixed(1)}%',
              sub: report.savingRate >= 20 ? 'ممتاز 🌟'
                 : report.savingRate >= 10 ? 'جيد 👍' : 'يحتاج تحسين',
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
                    Text('شخصيتكم هذا الشهر', style: AppTextStyles.caption),
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

        // ── Category Breakdown ────────────────────────
        if (catMap.isNotEmpty)
          MudCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MudSectionLabel('تفصيل المصاريف'),
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
              ? '⚠️ عجز مالي بمقدار ${report.balance.abs().fmt()}. راجعوا المصاريف وقللوا البنود غير الضرورية فوراً.'
              : report.savingRate < 10
              ? '💡 نسبة الادخار ${report.savingRate.toStringAsFixed(1)}%. الهدف 20% = ${(report.totalIncome * 0.2).fmt()} شهرياً.'
              : '✨ وضع ممتاز! تدخرون ${report.balance.fmt()} هذا الشهر. واصلوا!',
        ),
      ],
    );
  }
}
