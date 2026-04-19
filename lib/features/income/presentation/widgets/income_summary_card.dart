import 'package:flutter/material.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_card.dart';
import '../../domain/entities/income.dart';

class IncomeSummaryCard extends StatelessWidget {
  final Income income;
  const IncomeSummaryCard({super.key, required this.income});

  @override
  Widget build(BuildContext context) => MudCard(
    child: Column(
      children: [
        _Row(label: '👨 الدخل الأساسي',  value: income.primary,   show: true),
        _Row(label: '👩 دخل الشريك',      value: income.secondary, show: income.hasPartner),
        _Row(label: '💼 دخل إضافي',       value: income.extra,     show: income.hasExtra),
        const Divider(color: AppColors.border, height: 20),
        // Total row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('إجمالي الدخل', style: AppTextStyles.subtitle),
            Text(
              // Edge: total = 0 → show dash
              income.hasIncome ? income.total.fmt() : '—',
              style: AppTextStyles.amount.copyWith(
                color: income.hasIncome ? AppColors.accentAlt : AppColors.textTertiary,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  final String label;
  final double value;
  final bool   show;

  const _Row({required this.label, required this.value, required this.show});

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(
            value > 0 ? value.fmt() : '—',
            style: AppTextStyles.bodyBold.copyWith(
              color: value > 0 ? AppColors.accentAlt : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
