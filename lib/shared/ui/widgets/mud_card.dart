import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MudCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color?              color;
  final VoidCallback?       onTap;
  final EdgeInsetsGeometry? margin;
  final double              radius;
  final Border?             border;

  const MudCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.margin,
    this.radius = 16,
    this.border,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin:  margin  ?? const EdgeInsets.only(bottom: 12),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        color ?? AppColors.surface1,
        borderRadius: BorderRadius.circular(radius),
        border:       border ?? Border.all(color: AppColors.border),
      ),
      child: child,
    ),
  );
}

class MudSectionLabel extends StatelessWidget {
  final String text;
  const MudSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 2),
    child: Text(
      text.toUpperCase(),
      style: AppTextStyles.label,
    ),
  );
}
