import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

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
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10,
          color: AppColors.textTertiary)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 19,
          fontWeight: FontWeight.w900, color: valueColor, letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10,
          color: AppColors.textTertiary)),
      ],
    ),
  );
}
