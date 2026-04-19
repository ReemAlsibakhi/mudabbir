// ═══════════════════════════════════════════════════════════
// IncomeRepositoryImpl — Hive, all cases handled
// ═══════════════════════════════════════════════════════════

import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/income.dart';
import '../../domain/repositories/income_repository.dart';

final class IncomeRepositoryImpl implements IncomeRepository {
  static const _tag = 'IncomeRepo';

  // Lazy getter — box is always open after Bootstrap.init()
  Box get _box => Hive.box(AppConstants.incomeBox);

  @override
  Stream<Income> watchByMonth(String monthKey) {
    // Edge: emit current value immediately, then listen to changes
    return Stream.multi((controller) {
      // Emit current state right away
      controller.add(getByMonth(monthKey));

      // Listen for future changes
      final sub = _box.watch(key: monthKey).listen(
        (event) {
          // Edge: key was deleted → emit empty
          final value = event.deleted ? Income.empty(monthKey) : _decode(event.value, monthKey);
          controller.add(value);
        },
        onError: (e, st) {
          AppLogger.error(_tag, 'watchByMonth error', e, st as StackTrace);
          // Don't close stream on error — emit empty and continue
          controller.add(Income.empty(monthKey));
        },
      );
      controller.onCancel = sub.cancel;
    });
  }

  @override
  Income getByMonth(String monthKey) {
    try {
      final raw = _box.get(monthKey);
      // Edge: never stored before → safe empty
      if (raw == null) return Income.empty(monthKey);
      return _decode(raw, monthKey);
    } catch (e, st) {
      // Edge: corrupted data → log and return safe default
      AppLogger.error(_tag, 'getByMonth corrupted data for $monthKey', e, st);
      return Income.empty(monthKey);
    }
  }

  @override
  Future<Result<void>> save(Income income) async {
    return Result.guard(() async {
      await _box.put(income.monthKey, _encode(income));
      AppLogger.info(_tag, 'Saved income for ${income.monthKey}');
    });
  }

  @override
  List<Income> getLastMonths(String currentMonthKey, {int count = 3}) {
    // Edge: count <= 0
    if (count <= 0) return [];

    try {
      final parts = currentMonthKey.split('-');
      // Edge: malformed monthKey
      if (parts.length != 2) return [];

      final year  = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      if (year == null || month == null) return [];

      final result = <Income>[];
      for (var i = 1; i <= count; i++) {
        var m = month - i;
        var y = year;
        while (m <= 0) { m += 12; y--; }
        final key = '$y-${m.toString().padLeft(2, '0')}';
        result.add(getByMonth(key)); // always returns Income.empty if not found
      }
      return result;
    } catch (e, st) {
      AppLogger.error(_tag, 'getLastMonths error', e, st);
      return []; // Edge: any unexpected error → safe empty list
    }
  }

  // ── Serialization ─────────────────────────────────────

  Map<String, dynamic> _encode(Income i) => {
    'primary':   i.primary,
    'secondary': i.secondary,
    'extra':     i.extra,
    'updatedAt': i.updatedAt.toIso8601String(),
  };

  Income _decode(dynamic raw, String monthKey) {
    // Edge: raw is not a Map (corrupted)
    if (raw is! Map) {
      AppLogger.warn(_tag, 'Unexpected data type for $monthKey: ${raw.runtimeType}');
      return Income.empty(monthKey);
    }
    try {
      return Income(
        monthKey:  monthKey,
        // Edge: missing fields → default to 0
        primary:   _safeDouble(raw['primary']),
        secondary: _safeDouble(raw['secondary']),
        extra:     _safeDouble(raw['extra']),
        // Edge: missing/malformed date → use now()
        updatedAt: _safeDate(raw['updatedAt']),
      );
    } catch (e) {
      AppLogger.error(_tag, 'Decode error for $monthKey', e);
      return Income.empty(monthKey);
    }
  }

  double _safeDouble(dynamic v) {
    if (v == null)    return 0.0;
    if (v is double)  return v.clamp(0, double.infinity);
    if (v is int)     return v.toDouble().clamp(0, double.infinity);
    if (v is String)  return double.tryParse(v)?.clamp(0, double.infinity) ?? 0.0;
    return 0.0; // Edge: unexpected type
  }

  DateTime _safeDate(dynamic v) {
    if (v is String) {
      return DateTime.tryParse(v) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
