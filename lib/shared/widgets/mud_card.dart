import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

class MudCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  const MudCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? AppColors.surface1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      ),
    );
  }
}

class MudSectionTitle extends StatelessWidget {
  final String title;
  const MudSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
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
}

class MudProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color color;
  final double height;

  const MudProgressBar({
    super.key,
    required this.progress,
    required this.color,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface3,
        borderRadius: BorderRadius.circular(99),
      ),
      child: FractionallySizedBox(
        widthFactor: progress.clamp(0.0, 1.0),
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}

class MudStatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String sub;
  final Color valueColor;

  const MudStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary, fontFamily: 'Cairo')),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: valueColor, fontFamily: 'Cairo', letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary, fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}

class MudGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  const MudGradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }
}

class MudInsightBox extends StatelessWidget {
  final String text;
  final Color? borderColor;
  final Color? bgColor;

  const MudInsightBox({super.key, required this.text, this.borderColor, this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderColor ?? AppColors.accent.withOpacity(0.15)),
      ),
      child: Text(text, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary, height: 1.8)),
    );
  }
}
