import '../../../../core/errors/result.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../income/domain/repositories/income_repository.dart';
import '../../../goals/domain/repositories/goal_repository.dart';
import '../../../onboarding/domain/entities/onboarding_profile.dart';
import '../../../onboarding/domain/repositories/onboarding_repository.dart';
import '../entities/monthly_report.dart';

final class GetMonthlyReportUseCase {
  final IncomeRepository     _incomeRepo;
  final ExpenseRepository    _expenseRepo;
  final GoalRepository       _goalRepo;
  final OnboardingRepository _onboardingRepo;

  GetMonthlyReportUseCase({
    required IncomeRepository     incomeRepo,
    required ExpenseRepository    expenseRepo,
    required GoalRepository       goalRepo,
    required OnboardingRepository onboardingRepo,
  })  : _incomeRepo     = incomeRepo,
        _expenseRepo    = expenseRepo,
        _goalRepo       = goalRepo,
        _onboardingRepo = onboardingRepo;

  Result<MonthlyReport> call(String monthKey) {
    return Result.guardSync(() {
      final income    = _incomeRepo.getByMonth(monthKey);
      final expenses  = _expenseRepo.totalByMonth(monthKey);
      final fixed     = _expenseRepo.totalFixed();
      final goals     = _goalRepo.getAll();
      // Pass life stage so persona is personalised
      final profile   = _onboardingRepo.getSaved();
      final lifeStage = profile?.lifeStage;

      return MonthlyReport(
        monthKey:      monthKey,
        totalIncome:   income.total,
        totalVariable: expenses,
        totalFixed:    fixed,
        goals:         goals,
        lifeStage:     lifeStage,
      );
    });
  }
}
