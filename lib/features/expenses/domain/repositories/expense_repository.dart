import '../../../../core/errors/result.dart';
import '../entities/expense.dart';

abstract interface class ExpenseRepository {
  Stream<List<Expense>>      watchByMonth(String monthKey);
  Future<Result<void>>       add(Expense expense);
  Future<Result<void>>       delete(String id);
  double                     totalByMonth(String monthKey);
  List<Expense>              getByDate(String monthKey, String date);

  Stream<List<FixedExpense>> watchFixed();
  Future<Result<void>>       addFixed(FixedExpense expense);
  Future<Result<void>>       deleteFixed(String id);
  double                     totalFixed();
  List<FixedExpense>         allActive();
}
