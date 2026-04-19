import 'package:equatable/equatable.dart';
import '../../domain/entities/onboarding_profile.dart';

enum OnboardingStep { promo, country, lifeStage, name, budget, done }

final class OnboardingState extends Equatable {
  final OnboardingStep step;
  final OnboardingProfile draft;
  final bool   isSaving;
  final String? error;

  const OnboardingState({
    this.step    = OnboardingStep.promo,
    required this.draft,
    this.isSaving = false,
    this.error,
  });

  bool get canProceedFromCountry => draft.countryId.isNotEmpty;
  bool get canProceedFromName    => draft.name.trim().length >= 2;

  OnboardingState copyWith({
    OnboardingStep? step, OnboardingProfile? draft,
    bool? isSaving, String? error, bool clearError = false,
  }) => OnboardingState(
    step:     step     ?? this.step,
    draft:    draft    ?? this.draft,
    isSaving: isSaving ?? this.isSaving,
    error:    clearError ? null : error ?? this.error,
  );

  @override
  List<Object?> get props => [step, draft, isSaving, error];
}
