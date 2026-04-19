import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/extensions/datetime_ext.dart';
import '../data/expense_repo_impl.dart';
import '../domain/expense_entity.dart';
import '../domain/expense_repository.dart';

const _uuid = Uuid();

// ── Repository provider ───────────────────────────
final expenseRepoProvider = Provider<ExpenseRepository>((_) => ExpenseRepoImpl());

// ── Current month ────────────────────────────────
final selectedMonthProvider = StateProvider<DateTime>((_) => DateTime.now());

// ── Watch variable expenses ──────────────────────
final expenseListProvider = StreamProvider.family<List<ExpenseEntity>, String>(
  (ref, monthKey) => ref.watch(expenseRepoProvider).watchByMonth(monthKey),
);

// ── Watch fixed expenses ─────────────────────────
final fixedExpenseListProvider = StreamProvider<List<FixedExpenseEntity>>(
  (ref) => ref.watch(expenseRepoProvider).watchFixed(),
);

// ── Totals ────────────────────────────────────────
final totalVariableProvider = Provider.family<double, String>(
  (ref, monthKey) => ref.watch(expenseRepoProvider).totalByMonth(monthKey),
);

final totalFixedProvider = Provider<double>(
  (ref) => ref.watch(expenseRepoProvider).totalFixed(),
);

final totalExpensesProvider = Provider.family<double, String>((ref, monthKey) {
  final variable = ref.watch(expenseRepoProvider).totalByMonth(monthKey);
  final fixed    = ref.watch(expenseRepoProvider).totalFixed();
  return variable + fixed;
});

// ── Actions ───────────────────────────────────────
final expenseActionsProvider = Provider((ref) => ExpenseActions(ref.read(expenseRepoProvider)));

final class ExpenseActions {
  final ExpenseRepository _repo;
  ExpenseActions(this._repo);

  Future<void> addExpense({
    required String categoryId,
    required String name,
    required double amount,
    required DateTime date,
  }) =>
      _repo.add(ExpenseEntity(
        id:         _uuid.v4(),
        categoryId: categoryId,
        name:       name,
        amount:     amount,
        date:       date.dateKey,
        monthKey:   date.monthKey,
        createdAt:  DateTime.now(),
      ));

  Future<void> deleteExpense(String id) => _repo.delete(id);

  Future<void> addFixedExpense({
    required String categoryId,
    required String name,
    required double amount,
    int? dueDayOfMonth,
  }) =>
      _repo.addFixed(FixedExpenseEntity(
        id:           _uuid.v4(),
        categoryId:   categoryId,
        name:         name,
        amount:       amount,
        dueDayOfMonth: dueDayOfMonth,
      ));

  Future<void> deleteFixedExpense(String id) => _repo.deleteFixed(id);
}
