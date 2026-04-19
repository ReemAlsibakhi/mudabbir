import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/data/models/user_model.dart';
import '../../domain/entities/onboarding_profile.dart';
import '../../domain/repositories/onboarding_repository.dart';

final class OnboardingRepositoryImpl implements OnboardingRepository {
  static const _tag = 'OnboardingRepo';
  static const _key = 'user';

  Box<UserModel> get _box => Hive.box<UserModel>(AppConstants.userBox);

  @override
  bool isOnboarded() {
    try {
      return _box.get(_key)?.onboarded ?? false;
    } catch (e) {
      AppLogger.error(_tag, 'isOnboarded error', e);
      return false; // Edge: box error → treat as not onboarded
    }
  }

  @override
  OnboardingProfile? getSaved() {
    try {
      final m = _box.get(_key);
      if (m == null || !m.onboarded) return null;
      return OnboardingProfile(
        name:            m.name,
        countryId:       m.countryId,
        lifeStage:       LifeStage.fromString(m.lifeStage),
        primaryIncome:   m.primaryIncome.clamp(0, double.infinity),
        secondaryIncome: m.secondaryIncome.clamp(0, double.infinity),
        extraIncome:     m.extraIncome.clamp(0, double.infinity),
      );
    } catch (e, st) {
      AppLogger.error(_tag, 'getSaved error', e, st);
      return null;
    }
  }

  @override
  Future<Result<void>> save(OnboardingProfile p) => Result.guard(() async {
    final existing = _box.get(_key);
    if (existing != null) {
      existing
        ..name            = p.name.trim()
        ..countryId       = p.countryId
        ..lifeStage       = p.lifeStage.name
        ..primaryIncome   = p.primaryIncome
        ..secondaryIncome = p.secondaryIncome
        ..extraIncome     = p.extraIncome
        ..onboarded       = true;
      await existing.save();
    } else {
      await _box.put(_key, UserModel(
        name:            p.name.trim(),
        countryId:       p.countryId,
        lifeStage:       p.lifeStage.name,
        primaryIncome:   p.primaryIncome,
        secondaryIncome: p.secondaryIncome,
        extraIncome:     p.extraIncome,
        onboarded:       true,
      ));
    }
    AppLogger.info(_tag, 'Saved profile for ${p.name}');
  });

  @override
  Future<Result<void>> reset() => Result.guard(() async {
    await _box.delete(_key);
    AppLogger.info(_tag, 'Profile reset');
  });
}
