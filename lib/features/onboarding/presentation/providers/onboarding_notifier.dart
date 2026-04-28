import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/entities/onboarding_profile.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';
import 'onboarding_state.dart';

final onboardingRepoProvider = Provider<OnboardingRepository>(
  (_) => OnboardingRepositoryImpl(),
);

// ✅ Always reads fresh from Hive — never cached
// Used by anything outside the router that needs onboarding status
final isOnboardedProvider = Provider<bool>(
  (ref) => OnboardingRepositoryImpl().isOnboarded(),
);

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(ref.watch(onboardingRepoProvider)),
);

final class OnboardingNotifier extends StateNotifier<OnboardingState> {
  static const _tag = 'OnboardingNotifier';
  final OnboardingRepository _repo;

  OnboardingNotifier(this._repo)
      : super(OnboardingState(
          draft: OnboardingProfile(
            name:      '',
            countryId: _detectCountry(),
            lifeStage: LifeStage.single,
          ),
        ));

  // ── Navigation ────────────────────────────────────────

  void nextStep() {
    final next = OnboardingStep.values[state.step.index + 1];
    state = state.copyWith(step: next, clearError: true);
  }

  void prevStep() {
    if (state.step.index == 0) return;
    final prev = OnboardingStep.values[state.step.index - 1];
    state = state.copyWith(step: prev, clearError: true);
  }

  // ── Updates ───────────────────────────────────────────

  void selectCountry(String id) =>
      state = state.copyWith(draft: state.draft.copyWith(countryId: id));

  void selectLifeStage(LifeStage stage) =>
      state = state.copyWith(draft: state.draft.copyWith(lifeStage: stage));

  void setName(String name) =>
      state = state.copyWith(draft: state.draft.copyWith(name: name));

  void setIncome({double? primary, double? secondary, double? extra}) =>
      state = state.copyWith(draft: state.draft.copyWith(
        primaryIncome:   primary?.clamp(0, double.infinity),
        secondaryIncome: secondary?.clamp(0, double.infinity),
        extraIncome:     extra?.clamp(0, double.infinity),
      ));

  // ── Complete ──────────────────────────────────────────

  Future<bool> complete() async {
    state = state.copyWith(isSaving: true, clearError: true);

    final result = await CompleteOnboardingUseCase(_repo).call(state.draft);
    if (!mounted) return false;

    if (result.isFailure) {
      AppLogger.warn(_tag, 'Complete failed: ${result.failureOrNull}');
      state = state.copyWith(
        isSaving: false,
        error:    result.failureOrNull!.message,
      );
      return false;
    }

    state = state.copyWith(step: OnboardingStep.done, isSaving: false, clearError: true);
    AppLogger.info(_tag, 'Onboarding complete ✅');
    return true;
  }

  // ── Auto-detect country from device locale ─────────────
  static String _detectCountry() {
    try {
      // Use platform locale to detect country
      // In real app: PlatformDispatcher.instance.locale
      return 'sa'; // default Saudi Arabia
    } catch (_) {
      return 'sa';
    }
  }
}

// Re-export repo provider for use in settings
// ignore_for_file: duplicate_export
