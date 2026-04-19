import 'package:flutter/material.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_card.dart';
import '../../../../shared/ui/widgets/mud_progress_bar.dart';

class GoalsSummary extends StatelessWidget {
  final double totalSaved;
  final double totalTarget;
  final int    activeCount;
  final int    doneCount;

  const GoalsSummary({
    super.key,
    required this.totalSaved,
    required this.totalTarget,
    required this.activeCount,
    required this.doneCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalTarget > 0 ? totalSaved / totalTarget : 0.0;
    return MudCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('إجمالي المدخر', style: AppTextStyles.caption),
                  Text(
                    totalSaved > 0 ? totalSaved.fmt() : '—',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.success, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$activeCount نشط · $doneCount مكتمل',
                    style: AppTextStyles.caption),
                  Text(
                    totalTarget > 0 ? 'من ${totalTarget.fmt()}' : '',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
          if (totalTarget > 0) ...[
            const SizedBox(height: 10),
            MudProgressBar(value: progress, color: AppColors.success),
            const SizedBox(height: 4),
            Text('${(progress * 100).toStringAsFixed(1)}% من إجمالي الأهداف',
              style: AppTextStyles.caption),
          ],
        ],
      ),
    );
  }
}
