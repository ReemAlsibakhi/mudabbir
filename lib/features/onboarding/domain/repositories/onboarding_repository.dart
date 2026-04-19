import '../../../../core/errors/result.dart';
import '../entities/onboarding_profile.dart';

abstract interface class OnboardingRepository {
  bool                    isOnboarded();
  OnboardingProfile?      getSaved();
  Future<Result<void>>    save(OnboardingProfile profile);
  Future<Result<void>>    reset();
}
