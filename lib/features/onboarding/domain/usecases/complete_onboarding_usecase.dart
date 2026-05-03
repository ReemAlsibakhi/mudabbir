import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../entities/onboarding_profile.dart';
import '../repositories/onboarding_repository.dart';

final class CompleteOnboardingUseCase {
  final OnboardingRepository _repo;
  CompleteOnboardingUseCase(this._repo);

  Future<Result<void>> call(OnboardingProfile p) async {
    // Validate
    if (p.name.trim().isEmpty)
      return const Fail(ValidationFailure(AppStrings.nameRequired));
    if (p.name.trim().length > 30)
      return const Fail(ValidationFailure(AppStrings.nameTooLong));
    if (p.countryId.isEmpty)
      return const Fail(ValidationFailure(AppStrings.fieldRequired));

    // Edge: negative income (shouldn't happen with UI, but guard anyway)
    if (p.primaryIncome < 0 || p.secondaryIncome < 0 || p.extraIncome < 0)
      return const Fail(ValidationFailure(AppStrings.incomeNegative));

    // Edge: absurd income
    if (p.totalIncome > 100000000)
      return const Fail(ValidationFailure(AppStrings.amountTooLarge));

    AppLogger.info('CompleteOnboarding',
        'name=${p.name} country=${p.countryId} stage=${p.lifeStage}');
    return _repo.save(p);
  }
}
