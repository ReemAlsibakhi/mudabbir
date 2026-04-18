import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../models/expense.dart';
import '../models/fixed_expense.dart';

const _uuid = Uuid();

final expensesProvider = Provider.family<List<Expense>, DateTime>((ref, month) {
  final box = Hive.box<Expense>(AppConstants.dailyExpensesBox);
  final key = MudabbirDateUtils.monthKey(month);
  return box.values.where((e) => e.monthKey == key).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});

final fixedExpensesProvider = Provider<List<FixedExpense>>((ref) {
  final box = Hive.box<FixedExpense>(AppConstants.fixedExpensesBox);
  return box.values.where((e) => e.active).toList();
});

final expenseActionsProvider = Provider((ref) => ExpenseActions(ref));

class ExpenseActions {
  final Ref _ref;
  ExpenseActions(this._ref);

  Box<Expense> get _expBox => Hive.box<Expense>(AppConstants.dailyExpensesBox);
  Box<FixedExpense> get _fixBox => Hive.box<FixedExpense>(AppConstants.fixedExpensesBox);

  Future<void> addExpense({
    required String categoryId,
    required String name,
    required double amount,
    required DateTime date,
  }) async {
    final id = _uuid.v4();
    final exp = Expense(
      id: id,
      categoryId: categoryId,
      name: name,
      amount: amount,
      date: MudabbirDateUtils.dateKey(date),
      monthKey: MudabbirDateUtils.monthKey(date),
      createdAt: DateTime.now(),
    );
    await _expBox.put(id, exp);
  }

  Future<void> deleteExpense(String id) async {
    await _expBox.delete(id);
  }

  Future<void> addFixedExpense({
    required String categoryId,
    required String name,
    required double amount,
    int? dueDayOfMonth,
  }) async {
    final id = _uuid.v4();
    final exp = FixedExpense(
      id: id,
      categoryId: categoryId,
      name: name,
      amount: amount,
      createdAt: DateTime.now(),
      dueDayOfMonth: dueDayOfMonth,
    );
    await _fixBox.put(id, exp);
  }

  Future<void> deleteFixedExpense(String id) async {
    await _fixBox.delete(id);
  }

  double getTotalFixed() {
    return _fixBox.values
        .where((e) => e.active)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double getTotalVariable(DateTime month) {
    final key = MudabbirDateUtils.monthKey(month);
    return _expBox.values
        .where((e) => e.monthKey == key)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double getTotal(DateTime month) => getTotalFixed() + getTotalVariable(month);
}
