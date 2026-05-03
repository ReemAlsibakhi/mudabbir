import '../../../../core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../onboarding/domain/entities/onboarding_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_notifier.dart';

class SuggestedQuestions extends ConsumerWidget {
  final ValueChanged<String> onTap;
  const SuggestedQuestions({super.key, required this.onTap});

  static const _questions = {
    LifeStage.single: [
      AppStrings.q1Single,
      AppStrings.q2Single,
      AppStrings.q3Single,
    ],
    LifeStage.engaged: [
      AppStrings.q1Engaged,
      AppStrings.q2Engaged,
      AppStrings.q3Engaged,
    ],
    LifeStage.married: [
      AppStrings.q1Married,
      AppStrings.q2Married,
      AppStrings.q3Married,
    ],
    LifeStage.family: [
      AppStrings.q1Family,
      AppStrings.q2Family,
      AppStrings.q3Family,
    ],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(onboardingRepoProvider).getSaved();
    final stage   = profile?.lifeStage ?? LifeStage.single;
    final qs      = _questions[stage] ?? _questions[LifeStage.single]!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.chatSuggestions, style: AppTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: qs.map((q) => GestureDetector(
              onTap: () => onTap(q),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color:        AppColors.surface2,
                  borderRadius: BorderRadius.circular(20),
                  border:       Border.all(color: AppColors.borderMid),
                ),
                child: Text(q,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
