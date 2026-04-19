import 'package:flutter/material.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_card.dart';

class ExpensesCategoryBreakdown extends StatelessWidget {
  final Map<String, double> categoryTotals;
  final double              total;

  const ExpensesCategoryBreakdown({
    super.key,
    required this.categoryTotals,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) return const SizedBox.shrink();

    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return MudCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MudSectionLabel('توزيع المصاريف'),
          ...sorted.map((entry) {
            final cat     = getCategoryById(entry.key);
            final color   = Color(cat.color);
            // Edge: total = 0 → show 0%
            final percent = total > 0 ? (entry.value / total).clamp(0.0, 1.0) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${cat.icon} ${cat.nameAr}', style: AppTextStyles.body),
                      Text(entry.value.fmt(), style: AppTextStyles.bodyBold.copyWith(color: color)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value:      percent,
                      minHeight:  5,
                      backgroundColor: AppColors.surface3,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
