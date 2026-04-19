import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/onboarding_data.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';

// ─── State ────────────────────────────────────────────────
final class OnboardingState extends Equatable {
  final int       step;       // 0=promo 1=country 2=lifeStage 3=name
  final String    countryId;
  final LifeStage lifeStage;
  final String    name;
  final bool      isLoading;
  final String?   error;

  const OnboardingState({
    this.step      = 0,
    this.countryId = 'sa',
    this.lifeStage = LifeStage.single,
    this.name      = '',
    this.isLoading = false,
    this.error,
  });

  bool get canFinish => name.trim().length >= 2 && countryId.isNotEmpty;

  OnboardingState copyWith({
    int? step, String? countryId, LifeStage? lifeStage,
    String? name, bool? isLoading, String? error, bool clearError = false,
  }) => OnboardingState(
    step:      step      ?? this.step,
    countryId: countryId ?? this.countryId,
    lifeStage: lifeStage ?? this.lifeStage,
    name:      name      ?? this.name,
    isLoading: isLoading ?? this.isLoading,
    error:     clearError ? null : error ?? this.error,
  );

  @override
  List<Object?> get props => [step, countryId, lifeStage, name, isLoading, error];
}

// ─── Provider ─────────────────────────────────────────────
final onboardingProvider =
    StateNotifierProvider.autoDispose<OnboardingNotifier, OnboardingState>(
  (_) => OnboardingNotifier(),
);

// ─── Notifier ─────────────────────────────────────────────
final class OnboardingNotifier extends StateNotifier<OnboardingState> {
  static const _tag = 'OnboardingNotifier';

  OnboardingNotifier() : super(const OnboardingState()) {
    _autoDetectCountry();
  }

  void _autoDetectCountry() {
    try {
      // Try detecting from device locale
      // In real app: use Platform.localeName
      AppLogger.debug(_tag, 'Auto-detecting country from locale');
    } catch (e) {
      AppLogger.warn(_tag, 'Country auto-detect failed: $e');
      // Silently keep default 'sa'
    }
  }

  void nextStep() {
    // Edge: don't go beyond last step
    if (state.step >= 3) return;
    if (!mounted) return;
    state = state.copyWith(step: state.step + 1);
  }

  void prevStep() {
    if (state.step <= 0) return;
    if (!mounted) return;
    state = state.copyWith(step: state.step - 1, clearError: true);
  }

  void selectCountry(String id) {
    // Edge: validate country exists
    final exists = kCountries.any((c) => c.id == id);
    if (!exists) {
      AppLogger.warn(_tag, 'Unknown country id: $id');
      return;
    }
    state = state.copyWith(countryId: id);
  }

  void selectLifeStage(LifeStage stage) {
    state = state.copyWith(lifeStage: stage);
  }

  void setName(String name) {
    // Edge: trim + limit length
    state = state.copyWith(
      name:       name.substring(0, name.length.clamp(0, 30)),
      clearError: true,
    );
  }

  Future<bool> finish() async {
    if (!state.canFinish) {
      state = state.copyWith(error: 'أدخل اسمك أولاً');
      return false;
    }
    if (!mounted) return false;
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await CompleteOnboardingUseCase().call(
      OnboardingData(
        name:      state.name.trim(),
        countryId: state.countryId,
        lifeStage: state.lifeStage,
      ),
    );

    if (!mounted) return false;
    if (result.isFailure) {
      state = state.copyWith(isLoading: false, error: result.failureOrNull!.message);
      return false;
    }
    state = state.copyWith(isLoading: false, clearError: true);
    return true;
  }

  void clearError() { if (mounted) state = state.copyWith(clearError: true); }
}
