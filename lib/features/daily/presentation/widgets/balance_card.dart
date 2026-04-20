import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../expenses/presentation/providers/expenses_notifier.dart';
import '../../../expenses/presentation/providers/expenses_state.dart';
import '../../../income/presentation/providers/income_state.dart';
import '../../../income/presentation/providers/income_notifier.dart';
import '../../../onboarding/data/repositories/onboarding_repository_impl.dart';

class BalanceCard extends ConsumerWidget {
  final DateTime month;
  const BalanceCard({super.key, required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthKey  = month.monthKey;
    final income    = ref.watch(incomeNotifierProvider(monthKey));
    final expenses  = ref.watch(expensesNotifierProvider(monthKey));
    final profile   = ref.watch(onboardingRepoProvider).getSaved();
    final currency  = 'ريال';

    final totalIncome   = income is IncomeLoaded ? income.income.total : 0.0;
    final totalExpenses = expenses is ExpensesLoaded ? expenses.total : 0.0;
    final balance       = totalIncome - totalExpenses;
    final savingRate    = totalIncome > 0
        ? (balance / totalIncome * 100).clamp(-100.0, 100.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppColors.primaryDeep,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          // Background circles
          Positioned(
            top: -35, right: -35,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentAlt.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -25, left: -25,
            child: Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGreen.withOpacity(0.05),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المتاح هذا الشهر',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.6)),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ريال ',
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.textSecondary.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      balance > 0 ? balance.fmt() : '—',
                      style: const TextStyle(
                        fontFamily: 'Cairo', fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -1.5, height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _SavingRateChip(rate: savingRate),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatChip(
                      label: 'الدخل',
                      value: totalIncome > 0 ? totalIncome.fmt() : '—',
                      color: AppColors.accentAlt,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'المصروف',
                      value: totalExpenses > 0 ? totalExpenses.fmt() : '—',
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'الادخار',
                      value: totalIncome > 0 ? '${savingRate.toStringAsFixed(1)}%' : '—',
                      color: AppColors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingRateChip extends StatelessWidget {
  final double rate;
  const _SavingRateChip({required this.rate});

  @override
  Widget build(BuildContext context) {
    final isGood = rate >= 20;
    final color  = isGood ? AppColors.accentGreen : AppColors.warning;
    return Row(
      children: [
        Text(
          isGood ? '↑' : '→',
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 4),
        Text(
          isGood
              ? '${rate.toStringAsFixed(1)}% نسبة ادخار ممتازة'
              : rate >= 10 ? 'نسبة ادخار جيدة ${rate.toStringAsFixed(1)}%'
              : 'ادخر أكثر لتحسين نسبتك',
          style: TextStyle(
            fontFamily: 'Cairo', fontSize: 11,
            color: color.withOpacity(0.85), fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color  color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(11),
        border:       Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // start = RIGHT in RTL
        children: [
          Text(label,
            style: const TextStyle(
              fontFamily: 'Cairo', fontSize: 10,
              color: Color(0xFF94A3B8))),
          const SizedBox(height: 3),
          Text(value,
            style: TextStyle(
              fontFamily: 'Cairo', fontSize: 14,
              fontWeight: FontWeight.w800, color: color,
              letterSpacing: -0.3)),
        ],
      ),
    ),
  );
}
