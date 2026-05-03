import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/entities/onboarding_profile.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';
import 'onboarding_state.dart';

// ── Shared providers ─────────────────────────────────────
final onboardingRepoProvider = Provider<OnboardingRepository>(
  (_) => OnboardingRepositoryImpl(),
);

// ✅ Injected UseCase
final completeOnboardingUseCaseProvider = Provider<CompleteOnboardingUseCase>(
  (ref) => CompleteOnboardingUseCase(ref.watch(onboardingRepoProvider)),
);

// Router guard — reads fresh from Hive on every check
final isOnboardedProvider = Provider<bool>(
  (ref) => ref.watch(onboardingRepoProvider).isOnboarded(),
);

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(
    repo:        ref.watch(onboardingRepoProvider),
    completeUC:  ref.watch(completeOnboardingUseCaseProvider),
  ),
);

final class OnboardingNotifier extends StateNotifier<OnboardingState> {
  static const _tag = 'OnboardingNotifier';

  final OnboardingRepository       _repo;
  final CompleteOnboardingUseCase  _completeUC; // ✅ injected

  OnboardingNotifier({
    required OnboardingRepository      repo,
    required CompleteOnboardingUseCase completeUC,
  })  : _repo       = repo,
        _completeUC = completeUC,
        super(OnboardingState(
          draft: OnboardingProfile(
            name:      '',
            countryId: _detectCountry(),
            lifeStage: LifeStage.single,
          ),
        ));

  void nextStep() {
    final next = OnboardingStep.values[state.step.index + 1];
    state = state.copyWith(step: next, clearError: true);
  }

  void prevStep() {
    if (state.step.index == 0) return;
    state = state.copyWith(
      step: OnboardingStep.values[state.step.index - 1],
      clearError: true,
    );
  }

  void selectCountry(String id)    =>
      state = state.copyWith(draft: state.draft.copyWith(countryId: id));
  void selectLifeStage(LifeStage s) =>
      state = state.copyWith(draft: state.draft.copyWith(lifeStage: s));
  void setName(String name)         =>
      state = state.copyWith(draft: state.draft.copyWith(name: name));
  void setIncome({double? primary, double? secondary, double? extra}) =>
      state = state.copyWith(draft: state.draft.copyWith(
        primaryIncome:   primary?.clamp(0, double.infinity),
        secondaryIncome: secondary?.clamp(0, double.infinity),
        extraIncome:     extra?.clamp(0, double.infinity),
      ));

  Future<bool> complete() async {
    state = state.copyWith(isSaving: true, clearError: true);
    final result = await _completeUC(state.draft); // ✅ injected
    if (!mounted) return false;
    if (result.isFailure) {
      AppLogger.warn(_tag, 'complete failed: ${result.failureOrNull}');
      state = state.copyWith(
        isSaving: false, error: result.failureOrNull!.message);
      return false;
    }
    state = state.copyWith(step: OnboardingStep.done, isSaving: false);
    AppLogger.info(_tag, 'Onboarding complete ✅');
    return true;
  }

  static String _detectCountry() => 'sa'; // default Saudi Arabia
}
