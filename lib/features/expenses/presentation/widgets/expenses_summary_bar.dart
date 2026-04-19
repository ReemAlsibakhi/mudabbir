import 'package:flutter/material.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ExpensesSummaryBar extends StatelessWidget {
  final double totalFixed;
  final double totalVariable;
  const ExpensesSummaryBar({
    super.key, required this.totalFixed, required this.totalVariable,
  });

  @override
  Widget build(BuildContext context) {
    final total = totalFixed + totalVariable;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surface2,
      child: Row(
        children: [
          _Item(label: 'ثابت',    value: totalFixed,    color: AppColors.accentAlt),
          const SizedBox(width: 8),
          const Text('+', style: TextStyle(color: AppColors.textTertiary)),
          const SizedBox(width: 8),
          _Item(label: 'متغير',   value: totalVariable, color: AppColors.orange),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('الإجمالي', style: AppTextStyles.caption),
              Text(
                total > 0 ? total.fmt() : '—',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final double value;
  final Color  color;
  const _Item({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.caption),
      Text(value > 0 ? value.fmt() : '—',
        style: AppTextStyles.body.copyWith(color: color, fontWeight: FontWeight.w700)),
    ],
  );
}
