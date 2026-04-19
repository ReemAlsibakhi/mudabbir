import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MudGradientButton extends StatelessWidget {
  final String       label;
  final VoidCallback onTap;
  final bool         loading;
  final double?      width;
  final bool         enabled;
  final String?      prefixEmoji;

  const MudGradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading     = false,
    this.width,
    this.enabled     = true,
    this.prefixEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading;
    return GestureDetector(
      onTap: active ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width:   width ?? double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient:     active ? AppColors.primary : null,
          color:        active ? null : AppColors.surface3,
          borderRadius: BorderRadius.circular(14),
          boxShadow:    active ? [BoxShadow(
            color:      AppColors.accent.withOpacity(0.3),
            blurRadius: 16,
            offset:     const Offset(0, 4),
          )] : null,
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (prefixEmoji != null) ...[
                      Text(prefixEmoji!,
                        style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                    ],
                    Text(label, style: AppTextStyles.button),
                  ],
                ),
        ),
      ),
    );
  }
}
