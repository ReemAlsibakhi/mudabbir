import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSmall;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isSmall ? null : double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 16 : 0,
          vertical: isSmall ? 10 : 14,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accent, AppColors.accent2],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: isSmall ? 13 : 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
