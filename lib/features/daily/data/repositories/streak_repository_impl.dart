import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/streak.dart';
import '../../domain/repositories/streak_repository.dart';

final class StreakRepositoryImpl implements StreakRepository {
  static const _tag = 'StreakRepo';
  static const _key = 'streak_data';

  Box get _box => Hive.box(AppConstants.settingsBox);

  @override
  Streak get() {
    try {
      final raw = _box.get(_key);
      if (raw == null) return const Streak(); // Edge: first launch
      if (raw is! Map)   { // Edge: corrupted
        AppLogger.warn(_tag, 'corrupted streak data');
        return const Streak();
      }
      return Streak(
        count:        _safeInt(raw['count']),
        lastLogDate:  raw['lastLogDate']?.toString() ?? '',
        bestCount:    _safeInt(raw['bestCount']),
        rescueTokens: _safeInt(raw['rescueTokens'], fallback: 1),
      );
    } catch (e, st) {
      AppLogger.error(_tag, 'get error', e, st);
      return const Streak();
    }
  }

  @override
  Future<Result<void>> save(Streak s) => Result.guard(() => _box.put(_key, {
    'count':        s.count,
    'lastLogDate':  s.lastLogDate,
    'bestCount':    s.bestCount,
    'rescueTokens': s.rescueTokens,
  }));

  @override
  Future<Result<void>> reset() => Result.guard(() => _box.delete(_key));

  int _safeInt(dynamic v, {int fallback = 0}) {
    if (v is int)    return v.clamp(0, 99999);
    if (v is double) return v.toInt().clamp(0, 99999);
    return fallback;
  }
}
