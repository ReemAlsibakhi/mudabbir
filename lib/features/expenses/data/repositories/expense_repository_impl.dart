import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/data/models/expense_model.dart';
import '../../../../shared/data/models/fixed_expense_model.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

final class ExpenseRepositoryImpl implements ExpenseRepository {
  static const _tag = 'ExpenseRepo';

  Box<ExpenseModel>      get _box  => Hive.box<ExpenseModel>(AppConstants.dailyExpensesBox);
  Box<FixedExpenseModel> get _fBox => Hive.box<FixedExpenseModel>(AppConstants.fixedExpensesBox);

  // ── Variable ──────────────────────────────────────────

  @override
  Stream<List<Expense>> watchByMonth(String monthKey) =>
      _box.watch().map((_) => _queryByMonth(monthKey)).asBroadcastStream();

  List<Expense> _queryByMonth(String key) =>
      _box.values
          .where((m) => m.monthKey == key)
          .map(_fromModel)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  @override
  Future<Result<void>> add(Expense e) => Result.guard(() async {
    await _box.put(e.id, _toModel(e));
    AppLogger.info(_tag, 'Added expense ${e.id}');
  });

  @override
  Future<Result<void>> delete(String id) => Result.guard(() async {
    await _box.delete(id);
    AppLogger.info(_tag, 'Deleted expense $id');
  });

  @override
  double totalByMonth(String key) =>
      _box.values.where((m) => m.monthKey == key).fold(0, (s, m) => s + m.amount);

  // ── Fixed ─────────────────────────────────────────────

  @override
  Stream<List<FixedExpense>> watchFixed() =>
      _fBox.watch().map((_) => _allFixed()).asBroadcastStream();

  List<FixedExpense> _allFixed() =>
      _fBox.values.where((m) => m.active).map(_fromFixedModel).toList();

  @override
  Future<Result<void>> addFixed(FixedExpense e) => Result.guard(() async {
    await _fBox.put(e.id, _toFixedModel(e));
    AppLogger.info(_tag, 'Added fixed expense ${e.id}');
  });

  @override
  Future<Result<void>> deleteFixed(String id) => Result.guard(() async {
    await _fBox.delete(id);
  });

  @override
  double totalFixed() =>
      _fBox.values.where((m) => m.active).fold(0, (s, m) => s + m.amount);

  // ── Mappers ───────────────────────────────────────────

  Expense _fromModel(ExpenseModel m) => Expense(
    id: m.id, categoryId: m.categoryId, name: m.name,
    amount: m.amount, date: m.date, monthKey: m.monthKey,
    createdAt: m.createdAt,
  );

  ExpenseModel _toModel(Expense e) => ExpenseModel(
    id: e.id, categoryId: e.categoryId, name: e.name,
    amount: e.amount, date: e.date, monthKey: e.monthKey,
    createdAt: e.createdAt,
  );

  FixedExpense _fromFixedModel(FixedExpenseModel m) => FixedExpense(
    id: m.id, categoryId: m.categoryId, name: m.name,
    amount: m.amount, active: m.active, dueDayOfMonth: m.dueDayOfMonth,
  );

  FixedExpenseModel _toFixedModel(FixedExpense e) => FixedExpenseModel(
    id: e.id, categoryId: e.categoryId, name: e.name,
    amount: e.amount, active: e.active, createdAt: DateTime.now(),
    dueDayOfMonth: e.dueDayOfMonth,
  );
}
