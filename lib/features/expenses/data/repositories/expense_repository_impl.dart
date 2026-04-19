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
  Stream<List<Expense>> watchByMonth(String monthKey) => Stream.multi((c) {
    c.add(_byMonth(monthKey));
    final sub = _box.watch().listen(
      (_) { if (!c.isClosed) c.add(_byMonth(monthKey)); },
      onError: (e, st) {
        AppLogger.error(_tag, 'stream error', e, st as StackTrace);
        if (!c.isClosed) c.add([]);
      },
    );
    c.onCancel = sub.cancel;
  });

  List<Expense> _byMonth(String key) {
    try {
      return _box.values
          .where((m) => m.monthKey == key)
          .map(_fromModel)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e, st) {
      AppLogger.error(_tag, 'byMonth error', e, st);
      return [];
    }
  }

  @override
  Future<Result<void>> add(Expense e) => Result.guard(() => _box.put(e.id, _toModel(e)));

  @override
  Future<Result<void>> delete(String id) => Result.guard(() async {
    // Edge: id doesn't exist → Hive silently ignores, no error needed
    if (!_box.containsKey(id)) {
      AppLogger.warn(_tag, 'delete called on non-existent key: $id');
      return;
    }
    await _box.delete(id);
  });

  @override
  double totalByMonth(String key) {
    try {
      return _box.values
          .where((m) => m.monthKey == key)
          .fold(0.0, (s, m) => s + m.amount);
    } catch (e) {
      AppLogger.error(_tag, 'totalByMonth error', e);
      return 0.0; // Edge: any error → safe default
    }
  }

  @override
  List<Expense> getByDate(String monthKey, String date) {
    try {
      return _box.values
          .where((m) => m.monthKey == monthKey && m.date == date)
          .map(_fromModel)
          .toList();
    } catch (e) {
      AppLogger.error(_tag, 'getByDate error', e);
      return [];
    }
  }

  // ── Fixed ─────────────────────────────────────────────

  @override
  Stream<List<FixedExpense>> watchFixed() => Stream.multi((c) {
    c.add(_allFixed());
    final sub = _fBox.watch().listen(
      (_) { if (!c.isClosed) c.add(_allFixed()); },
      onError: (e, st) {
        AppLogger.error(_tag, 'fixed stream error', e, st as StackTrace);
        if (!c.isClosed) c.add([]);
      },
    );
    c.onCancel = sub.cancel;
  });

  List<FixedExpense> _allFixed() {
    try {
      return _fBox.values.where((m) => m.active).map(_fromFixedModel).toList();
    } catch (e) {
      AppLogger.error(_tag, 'allFixed error', e);
      return [];
    }
  }

  @override
  Future<Result<void>> addFixed(FixedExpense e) =>
      Result.guard(() => _fBox.put(e.id, _toFixedModel(e)));

  @override
  Future<Result<void>> deleteFixed(String id) => Result.guard(() async {
    if (!_fBox.containsKey(id)) return; // Edge: silent if not found
    await _fBox.delete(id);
  });

  @override
  double totalFixed() {
    try {
      return _fBox.values.where((m) => m.active).fold(0.0, (s, m) => s + m.amount);
    } catch (e) {
      return 0.0;
    }
  }

  @override
  List<FixedExpense> allActive() => _allFixed();

  // ── Mappers ───────────────────────────────────────────

  Expense _fromModel(ExpenseModel m) {
    try {
      return Expense(
        id: m.id, categoryId: m.categoryId.isNotEmpty ? m.categoryId : 'other',
        name: m.name.isNotEmpty ? m.name : '—',
        amount: m.amount.clamp(0, double.infinity),
        date: m.date, monthKey: m.monthKey,
        createdAt: m.createdAt,
      );
    } catch (e) {
      AppLogger.error(_tag, 'fromModel error for ${m.id}', e);
      return Expense(
        id: m.id, categoryId: 'other', name: '—',
        amount: 0, date: m.date, monthKey: m.monthKey,
        createdAt: m.createdAt,
      );
    }
  }

  ExpenseModel _toModel(Expense e) => ExpenseModel(
    id: e.id, categoryId: e.categoryId, name: e.name,
    amount: e.amount, date: e.date, monthKey: e.monthKey,
    createdAt: e.createdAt,
  );

  FixedExpense _fromFixedModel(FixedExpenseModel m) => FixedExpense(
    id: m.id, categoryId: m.categoryId, name: m.name,
    amount: m.amount.clamp(0, double.infinity),
    active: m.active, dueDayOfMonth: m.dueDayOfMonth,
  );

  FixedExpenseModel _toFixedModel(FixedExpense e) => FixedExpenseModel(
    id: e.id, categoryId: e.categoryId, name: e.name,
    amount: e.amount, active: e.active, createdAt: DateTime.now(),
    dueDayOfMonth: e.dueDayOfMonth,
  );
}
