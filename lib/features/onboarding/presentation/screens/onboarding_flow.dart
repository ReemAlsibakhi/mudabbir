import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/onboarding_notifier.dart';
import '../providers/onboarding_state.dart';
import '../widgets/promo_slide.dart';
import '../widgets/country_picker.dart';
import '../widgets/life_stage_picker.dart';
import '../widgets/name_step.dart';
import '../widgets/budget_setup_step.dart';

class OnboardingFlow extends ConsumerWidget {
  const OnboardingFlow({super.key});

  // Steps that show the progress bar (not promo or done)
  static const _progressSteps = [
    OnboardingStep.country,
    OnboardingStep.lifeStage,
    OnboardingStep.name,
    OnboardingStep.budget,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);

    ref.listen(onboardingNotifierProvider, (_, next) {
      if (next.step == OnboardingStep.done && context.mounted) {
        Future.microtask(() {
          if (context.mounted) context.go(AppRoutes.home);
        });
      }
    });

    final stepIndex = _progressSteps.indexOf(state.step);
    final showProgress = stepIndex >= 0;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              // ── Progress bar for steps 2-5 ────────────
              if (showProgress)
                _StepProgress(
                  current: stepIndex + 1,
                  total:   _progressSteps.length,
                  step:    state.step,
                ),

              // ── Step content ──────────────────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child:   SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0), end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: anim, curve: Curves.easeOut)),
                      child: child,
                    ),
                  ),
                  child: _stepWidget(state, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepWidget(OnboardingState state, WidgetRef ref) {
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    return switch (state.step) {
      OnboardingStep.promo     => PromoSlide(onNext: notifier.nextStep,
          key: const ValueKey('promo')),
      OnboardingStep.country   => CountryPickerStep(
          key: const ValueKey('country')),
      OnboardingStep.lifeStage => LifeStagePicker(
          key: const ValueKey('stage')),
      OnboardingStep.name      => NameStep(
          key: const ValueKey('name')),
      OnboardingStep.budget    => BudgetSetupStep(
          key: const ValueKey('budget')),
      OnboardingStep.done      => const _LoadingStep(
          key: ValueKey('done')),
    };
  }
}

// ── Step Progress indicator ───────────────────────────────
class _StepProgress extends StatelessWidget {
  final int           current, total;
  final OnboardingStep step;

  const _StepProgress({
    required this.current, required this.total, required this.step,
  });

  String get _label => switch (step) {
    OnboardingStep.country   => 'الدولة',
    OnboardingStep.lifeStage => 'مرحلة الحياة',
    OnboardingStep.name      => 'الاسم',
    OnboardingStep.budget    => 'الدخل',
    _                        => '',
  };

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('خطوة $current من $total',
              style: AppTextStyles.caption.copyWith(color: AppColors.accentAlt)),
            Text(_label, style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 6),
        // Segmented progress
        Row(
          children: List.generate(total, (i) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: i < current
                    ? AppColors.accent
                    : AppColors.surface3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
      ],
    ),
  );
}

class _LoadingStep extends StatelessWidget {
  const _LoadingStep({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: AppColors.accentAlt),
  );
}
