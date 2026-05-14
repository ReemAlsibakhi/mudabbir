import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/insight_repository.dart';

final class InsightRepositoryImpl implements InsightRepository {
  static const _tag          = 'InsightRepo';
  static const _dismissedKey = 'insights_dismissed';
  static const _lastDayKey   = 'insights_last_day';

  Box get _box => Hive.box(AppConstants.settingsBox);

  @override
  Set<String> getDismissedIds() {
    try {
      final raw = _box.get(_dismissedKey);
      if (raw is List) return raw.cast<String>().toSet();
    } catch (e) {
      AppLogger.error(_tag, 'getDismissedIds', e);
    }
    return {};
  }

  @override
  Future<void> dismiss(String id) async {
    try {
      final current = getDismissedIds()..add(id);
      await _box.put(_dismissedKey, current.toList());
    } catch (e) {
      AppLogger.error(_tag, 'dismiss', e);
    }
  }

  @override
  Future<void> clearIfNewDay() async {
    try {
      final today   = DateTime.now().day;
      final lastDay = _box.get(_lastDayKey, defaultValue: -1) as int;
      if (lastDay != today) {
        await _box.put(_dismissedKey, <String>[]);
        await _box.put(_lastDayKey, today);
        AppLogger.info(_tag, 'Dismissed IDs cleared for new day');
      }
    } catch (e) {
      AppLogger.error(_tag, 'clearIfNewDay', e);
    }
  }
}
