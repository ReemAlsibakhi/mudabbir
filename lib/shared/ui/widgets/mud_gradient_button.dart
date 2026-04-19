import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MudGradientButton extends StatelessWidget {
  final String       label;
  final VoidCallback onTap;
  final bool         loading;
  final double?      width;
  final bool         enabled;

  const MudGradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.width,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading;
    return GestureDetector(
      onTap: active ? onTap : null,
      child: AnimatedOpacity(
        opacity: active ? 1.0 : 0.6,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: width ?? double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient:     active ? AppColors.primary : null,
            color:        active ? null : AppColors.surface3,
            borderRadius: BorderRadius.circular(12),
            boxShadow:    active ? [BoxShadow(
              color: AppColors.accent.withOpacity(0.25),
              blurRadius: 12, offset: const Offset(0, 4),
            )] : null,
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                : Text(label, style: AppTextStyles.button),
          ),
        ),
      ),
    );
  }
}
