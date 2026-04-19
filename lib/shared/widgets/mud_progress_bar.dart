import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

class MudProgressBar extends StatelessWidget {
  final double value; // 0.0 → 1.0
  final Color  color;
  final double height;

  const MudProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(99),
    child: LinearProgressIndicator(
      value:      value.clamp(0.0, 1.0),
      minHeight:  height,
      backgroundColor: AppColors.surface3,
      valueColor: AlwaysStoppedAnimation(color),
    ),
  );
}
