import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/onboarding_notifier.dart';

class CountryPickerStep extends ConsumerWidget {
  const CountryPickerStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final selected = state.draft.countryId;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🌍 من أي دولة أنت؟', style: AppTextStyles.headline2),
          const SizedBox(height: 6),
          Text('سنضبط العملة والإعدادات تلقائياً',
            style: AppTextStyles.body),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 9, crossAxisSpacing: 9,
                childAspectRatio: 2.8,
              ),
              itemCount: kCountries.length,
              itemBuilder: (_, i) {
                final c   = kCountries[i];
                final sel = c.id == selected;
                return GestureDetector(
                  onTap: () => notifier.selectCountry(c.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color:        sel ? AppColors.accent.withOpacity(0.12) : AppColors.surface2,
                      borderRadius: BorderRadius.circular(11),
                      border:       Border.all(
                        color: sel ? AppColors.accent : AppColors.border,
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(c.flag, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(c.nameAr,
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: sel ? AppColors.accentAlt : AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis),
                        ),
                        Text(c.currency,
                          style: AppTextStyles.label.copyWith(color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _NavButtons(
            canNext: state.canProceedFromCountry,
            onNext:  notifier.nextStep,
            onBack:  notifier.prevStep,
          ),
        ],
      ),
    );
  }
}
class _NavButtons extends StatelessWidget {
  final bool canNext;
  final VoidCallback onNext, onBack;
  const _NavButtons({required this.canNext, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      GestureDetector(
        onTap: onBack,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface2, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Text('→', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: GestureDetector(
          onTap: canNext ? onNext : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient:     canNext ? AppColors.primary : null,
              color:        canNext ? null : AppColors.surface3,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('التالي ←', textAlign: TextAlign.center,
              style: AppTextStyles.button.copyWith(
                color: canNext ? Colors.white : AppColors.textTertiary)),
          ),
        ),
      ),
    ],
  );
}
