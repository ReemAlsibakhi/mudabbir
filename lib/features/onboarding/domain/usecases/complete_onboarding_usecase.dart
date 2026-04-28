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
      return const Fail(ValidationFailure('الاسم مطلوب'));
    if (p.name.trim().length > 30)
      return const Fail(ValidationFailure('الاسم طويل جداً'));
    if (p.countryId.isEmpty)
      return const Fail(ValidationFailure('اختيار الدولة مطلوب'));

    // Edge: negative income (shouldn't happen with UI, but guard anyway)
    if (p.primaryIncome < 0 || p.secondaryIncome < 0 || p.extraIncome < 0)
      return const Fail(ValidationFailure('الدخل لا يمكن أن يكون سالباً'));

    // Edge: absurd income
    if (p.totalIncome > 100000000)
      return const Fail(ValidationFailure('الدخل يبدو مرتفعاً جداً'));

    AppLogger.info('CompleteOnboarding',
        'name=${p.name} country=${p.countryId} stage=${p.lifeStage}');
    return _repo.save(p);
  }
}
