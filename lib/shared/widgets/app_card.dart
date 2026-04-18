import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final bool gradient;
  final EdgeInsets? padding;

  const AppCard({
    super.key,
    required this.child,
    this.gradient = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient ? null : AppColors.surface1,
        gradient: gradient
            ? LinearGradient(
                colors: [
                  AppColors.gold.withOpacity(.12),
                  AppColors.orange.withOpacity(.06),
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradient
              ? AppColors.gold.withOpacity(.2)
              : AppColors.border,
        ),
      ),
      child: child,
    );
  }
}
