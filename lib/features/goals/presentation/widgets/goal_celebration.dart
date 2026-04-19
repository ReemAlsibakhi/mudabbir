import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class GoalCelebration {
  static Future<void> show(BuildContext context, String goalName, String icon) =>
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _Dialog(goalName: goalName, icon: icon),
      );
}

class _Dialog extends StatelessWidget {
  final String goalName, icon;
  const _Dialog({required this.goalName, required this.icon});

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: AppColors.surface2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon,    style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text('🎉 مبروك!', style: AppTextStyles.headline1),
          const SizedBox(height: 8),
          Text('حققت هدف "$goalName" بنجاح!',
            style: AppTextStyles.body, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('رائع! 🚀'),
          ),
        ],
      ),
    ),
  );
}
