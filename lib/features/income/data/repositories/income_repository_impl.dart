import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/income.dart';
import '../../domain/repositories/income_repository.dart';

final class IncomeRepositoryImpl implements IncomeRepository {
  static const _tag = 'IncomeRepo';

  // Plain box (Map<dynamic,dynamic>) — income stored as Map
  Box get _box => Hive.box(AppConstants.incomeBox);

  @override
  Stream<Income> watchByMonth(String monthKey) => Stream.multi((c) {
    c.add(getByMonth(monthKey));
    final sub = _box.watch(key: monthKey).listen(
      (event) {
        if (!c.isClosed) {
          c.add(event.deleted ? Income.empty(monthKey) : _decode(event.value, monthKey));
        }
      },
      onError: (e, st) {
        AppLogger.error(_tag, 'watchByMonth error', e, st as StackTrace);
        if (!c.isClosed) c.add(Income.empty(monthKey));
      },
    );
    c.onCancel = sub.cancel;
  });

  @override
  Income getByMonth(String monthKey) {
    try {
      final raw = _box.get(monthKey);
      if (raw == null) return Income.empty(monthKey);
      return _decode(raw, monthKey);
    } catch (e, st) {
      AppLogger.error(_tag, 'getByMonth corrupted: $monthKey', e, st);
      return Income.empty(monthKey);
    }
  }

  @override
  Future<Result<void>> save(Income income) => Result.guard(() async {
    await _box.put(income.monthKey, {
      'primary':   income.primary,
      'secondary': income.secondary,
      'extra':     income.extra,
      'updatedAt': income.updatedAt.toIso8601String(),
    });
    AppLogger.info(_tag, 'Saved income for ${income.monthKey}');
  });

  @override
  List<Income> getLastMonths(String currentMonthKey, {int count = 3}) {
    if (count <= 0) return [];
    try {
      final parts = currentMonthKey.split('-');
      if (parts.length != 2) return [];
      final year  = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      if (year == null || month == null) return [];

      return List.generate(count, (i) {
        var m = month - i - 1;
        var y = year;
        while (m <= 0) { m += 12; y--; }
        return getByMonth('$y-${m.toString().padLeft(2,'0')}');
      });
    } catch (e) {
      AppLogger.error(_tag, 'getLastMonths error', e);
      return [];
    }
  }

  Income _decode(dynamic raw, String monthKey) {
    if (raw is! Map) {
      AppLogger.warn(_tag, 'unexpected type for $monthKey: ${raw.runtimeType}');
      return Income.empty(monthKey);
    }
    try {
      return Income(
        monthKey:  monthKey,
        primary:   _safeDouble(raw['primary']),
        secondary: _safeDouble(raw['secondary']),
        extra:     _safeDouble(raw['extra']),
        updatedAt: _safeDate(raw['updatedAt']),
      );
    } catch (e) {
      AppLogger.error(_tag, 'decode error for $monthKey', e);
      return Income.empty(monthKey);
    }
  }

  double _safeDouble(dynamic v) {
    if (v == null)   return 0.0;
    if (v is double) return v.clamp(0, double.infinity);
    if (v is int)    return v.toDouble().clamp(0, double.infinity);
    if (v is String) return double.tryParse(v)?.clamp(0, double.infinity) ?? 0.0;
    return 0.0;
  }

  DateTime _safeDate(dynamic v) =>
      v is String ? DateTime.tryParse(v) ?? DateTime.now() : DateTime.now();
}
