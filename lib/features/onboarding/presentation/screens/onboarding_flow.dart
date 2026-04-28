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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);

    // Listen for completion → GoRouter redirect handles navigation automatically
    // via RouterNotifier.notifyListeners() → refreshListenable on GoRouter
    // This is a safety net in case redirect doesn't fire fast enough
    ref.listen(onboardingNotifierProvider, (_, next) {
      if (next.step == OnboardingStep.done && context.mounted) {
        Future.microtask(() {
          if (context.mounted) context.go(AppRoutes.home);
        });
      }
    });

    return PopScope(
      // Prevent system back on onboarding — use in-app navigation
      canPop: false,
      child: Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child:   SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0), end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          ),
          child: _stepWidget(state, ref),
        ),
      ),
    ));
  }

  Widget _stepWidget(OnboardingState state, WidgetRef ref) {
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    return switch (state.step) {
      OnboardingStep.promo      => PromoSlide(onNext: notifier.nextStep,       key: const ValueKey('promo')),
      OnboardingStep.country    => CountryPickerStep(                           key: const ValueKey('country')),
      OnboardingStep.lifeStage  => LifeStagePicker(                            key: const ValueKey('stage')),
      OnboardingStep.name       => NameStep(                                   key: const ValueKey('name')),
      OnboardingStep.budget     => BudgetSetupStep(                            key: const ValueKey('budget')),
      OnboardingStep.done       => const _LoadingStep(                         key: ValueKey('done')),
    };
  }
}

class _LoadingStep extends StatelessWidget {
  const _LoadingStep({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: AppColors.accentAlt),
  );
}
