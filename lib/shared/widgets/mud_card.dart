import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

class MudCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const MudCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin:  margin ?? const EdgeInsets.only(bottom: 12),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        color ?? AppColors.surface1,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border),
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
      style: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
      ),
    ),
  );
}

// الاسم القديم — للتوافق
typedef MudSectionTitle = MudSectionLabel;
