import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/onboarding_profile.dart';
import '../providers/onboarding_notifier.dart';

class LifeStagePicker extends ConsumerWidget {
  const LifeStagePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final selected = state.draft.lifeStage;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('👤 ما وضعك الحالي؟', style: AppTextStyles.headline2),
          const SizedBox(height: 6),
          Text('سنخصص التطبيق بالكامل لاحتياجاتك', style: AppTextStyles.body),
          const SizedBox(height: 24),
          Expanded(
            child: Column(
              children: LifeStage.values.map((stage) {
                final sel = stage == selected;
                return GestureDetector(
                  onTap: () => notifier.selectLifeStage(stage),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin:  const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:        sel ? AppColors.accent.withOpacity(0.12) : AppColors.surface1,
                      borderRadius: BorderRadius.circular(14),
                      border:       Border.all(
                        color: sel ? AppColors.accent : AppColors.border,
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(stage.icon, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(stage.nameAr,
                                style: AppTextStyles.bodyBold.copyWith(
                                  color: sel ? AppColors.accentAlt : AppColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text(stage.desc, style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        if (sel)
                          const Icon(Icons.check_circle_rounded,
                            color: AppColors.accentAlt, size: 22),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          _StepNav(onNext: notifier.nextStep, onBack: notifier.prevStep),
        ],
      ),
    );
  }
}

class _StepNav extends StatelessWidget {
  final VoidCallback onNext, onBack;
  const _StepNav({required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary)),
      const SizedBox(width: 8),
      Expanded(
        child: GestureDetector(
          onTap: onNext,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: AppColors.primary, borderRadius: BorderRadius.circular(12)),
            child: Text('التالي ←', textAlign: TextAlign.center,
              style: AppTextStyles.button),
          ),
        ),
      ),
    ],
  );
}
