import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

class MudGradientButton extends StatelessWidget {
  final String     label;
  final VoidCallback onTap;
  final bool       loading;
  final double?    width;

  const MudGradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      width: width ?? double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient:     AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(
          color: AppColors.accent.withOpacity(0.25),
          blurRadius: 12, offset: const Offset(0, 4),
        )],
      ),
      child: Center(
        child: loading
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label, style: const TextStyle(fontFamily: 'Cairo',
                fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    ),
  );
}
