import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../models/income.dart';

final currentMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final incomeProvider = Provider.family<Income?, DateTime>((ref, month) {
  final box = Hive.box<Income>(AppConstants.incomeBox);
  final key = MudabbirDateUtils.monthKey(month);
  return box.get(key);
});

final incomeActionsProvider = Provider((ref) => IncomeActions(ref));

class IncomeActions {
  final Ref _ref;
  IncomeActions(this._ref);

  Box<Income> get _box => Hive.box<Income>(AppConstants.incomeBox);

  Future<void> saveIncome({
    required DateTime month,
    required double primary,
    double secondary = 0,
    double extra = 0,
  }) async {
    final key = MudabbirDateUtils.monthKey(month);
    final income = Income(
      monthKey: key,
      primary: primary,
      secondary: secondary,
      extra: extra,
      updatedAt: DateTime.now(),
    );
    await _box.put(key, income);
  }

  double getTotalIncome(DateTime month) {
    final key = MudabbirDateUtils.monthKey(month);
    return _box.get(key)?.total ?? 0;
  }
}
