import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../entities/onboarding_data.dart';

final class CompleteOnboardingUseCase {
  Future<Result<void>> call(OnboardingData data) async {
    // ── Validate ────────────────────────────────────────
    if (data.name.trim().isEmpty)   return const Fail(ValidationFailure('الاسم مطلوب'));
    if (data.name.trim().length < 2) return const Fail(ValidationFailure('الاسم قصير جداً'));
    if (data.name.trim().length > 30) return const Fail(ValidationFailure('الاسم طويل جداً'));
    if (data.countryId.isEmpty)     return const Fail(ValidationFailure('اختر دولتك'));

    return Result.guard(() async {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString(AppConstants.keyUserName,   data.name.trim()),
        prefs.setString(AppConstants.keyCountry,    data.countryId),
        prefs.setString(AppConstants.keyLifeStage,  data.lifeStage.name),
        prefs.setBool(AppConstants.keyOnboarded,    true),
      ]);
      AppLogger.info('CompleteOnboarding', 'Done for ${data.name}');
    });
  }
}
