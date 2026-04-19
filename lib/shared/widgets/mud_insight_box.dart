import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

enum InsightType { info, warning, success }

class MudInsightBox extends StatelessWidget {
  final String      text;
  final InsightType type;

  const MudInsightBox({
    super.key,
    required this.text,
    this.type = InsightType.info,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, border) = switch (type) {
      InsightType.info    => (AppColors.accent.withOpacity(0.06),  AppColors.accent.withOpacity(0.15)),
      InsightType.warning => (AppColors.red.withOpacity(0.05),     AppColors.red.withOpacity(0.15)),
      InsightType.success => (AppColors.green.withOpacity(0.05),   AppColors.green.withOpacity(0.15)),
    };

    return Container(
      margin:  const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(13),
        border:       Border.all(color: border),
      ),
      child: Text(text,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
          color: AppColors.textSecondary, height: 1.85)),
    );
  }
}
