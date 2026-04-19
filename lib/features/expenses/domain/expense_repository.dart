import 'expense_entity.dart';

abstract interface class ExpenseRepository {
  Stream<List<ExpenseEntity>>      watchByMonth(String monthKey);
  Future<void>                     add(ExpenseEntity expense);
  Future<void>                     delete(String id);
  double                           totalByMonth(String monthKey);

  Stream<List<FixedExpenseEntity>> watchFixed();
  Future<void>                     addFixed(FixedExpenseEntity expense);
  Future<void>                     deleteFixed(String id);
  double                           totalFixed();
}
