import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MudStatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String sub;
  final Color  valueColor;

  const MudStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color:        AppColors.surface1,
      borderRadius: BorderRadius.circular(14),
      border:       Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 6),
        Text(label,
          style: AppTextStyles.label.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: 3),
        Text(value,
          style: AppTextStyles.amount.copyWith(
            color: valueColor, fontSize: 19, letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(sub, style: AppTextStyles.caption),
      ],
    ),
  );
}
