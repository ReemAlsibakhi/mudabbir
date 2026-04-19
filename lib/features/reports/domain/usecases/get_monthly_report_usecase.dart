import '../../../../core/errors/result.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../income/domain/repositories/income_repository.dart';
import '../../../goals/domain/repositories/goal_repository.dart';
import '../entities/monthly_report.dart';

final class GetMonthlyReportUseCase {
  final IncomeRepository  _incomeRepo;
  final ExpenseRepository _expenseRepo;
  final GoalRepository    _goalRepo;

  GetMonthlyReportUseCase({
    required IncomeRepository  incomeRepo,
    required ExpenseRepository expenseRepo,
    required GoalRepository    goalRepo,
  }) : _incomeRepo   = incomeRepo,
       _expenseRepo  = expenseRepo,
       _goalRepo     = goalRepo;

  Result<MonthlyReport> call(String monthKey) {
    return Result.guardSync(() {
      final income   = _incomeRepo.getByMonth(monthKey);
      final expenses = _expenseRepo.totalByMonth(monthKey);
      final fixed    = _expenseRepo.totalFixed();
      final goals    = _goalRepo.getAll();

      // Edge: no data → return empty report (not an error)
      return MonthlyReport(
        monthKey:      monthKey,
        totalIncome:   income.total,
        totalVariable: expenses,
        totalFixed:    fixed,
        goals:         goals,
      );
    });
  }
}
