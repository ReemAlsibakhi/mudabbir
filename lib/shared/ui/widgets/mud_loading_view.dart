import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MudLoadingView extends StatelessWidget {
  final String? message;
  const MudLoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: AppColors.accent),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(message!, style: AppTextStyles.body),
        ],
      ],
    ),
  );
}
