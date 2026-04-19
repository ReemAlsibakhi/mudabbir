import '../../../../core/errors/result.dart';
import '../entities/income.dart';

abstract interface class IncomeRepository {
  /// Watch income changes for a specific month
  /// Always emits — never null (emits Income.empty if not set)
  Stream<Income> watchByMonth(String monthKey);

  /// Get sync — returns Income.empty if not found (never null)
  Income getByMonth(String monthKey);

  /// Save or update income for a month
  Future<Result<void>> save(Income income);

  /// Get income for last N months (for comparison reports)
  /// Returns empty list if no data, never throws
  List<Income> getLastMonths(String currentMonthKey, {int count = 3});
}
