import '../../../../core/errors/result.dart';
import '../entities/expense.dart';

abstract interface class ExpenseRepository {
  // ── Variable Expenses ───────────────────────────────
  Stream<List<Expense>> watchByMonth(String monthKey);
  Future<Result<void>>  add(Expense expense);
  Future<Result<void>>  delete(String id);
  double                totalByMonth(String monthKey);

  // ── Fixed Expenses ──────────────────────────────────
  Stream<List<FixedExpense>> watchFixed();
  Future<Result<void>>       addFixed(FixedExpense expense);
  Future<Result<void>>       deleteFixed(String id);
  double                     totalFixed();
}
