import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

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
      InsightType.info    => (AppColors.accent.withOpacity(0.06),   AppColors.accent.withOpacity(0.15)),
      InsightType.warning => (AppColors.warning.withOpacity(0.06),  AppColors.warning.withOpacity(0.15)),
      InsightType.success => (AppColors.success.withOpacity(0.06),  AppColors.success.withOpacity(0.15)),
    };
    return Container(
      margin:  const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(13),
        border:       Border.all(color: border),
      ),
      child: Text(text, style: AppTextStyles.body),
    );
  }
}
