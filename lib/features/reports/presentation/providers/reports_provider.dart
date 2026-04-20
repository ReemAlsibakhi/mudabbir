import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../expenses/data/repositories/expense_repository_impl.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../goals/data/repositories/goal_repository_impl.dart';
import '../../../goals/domain/repositories/goal_repository.dart';
import '../../../income/data/repositories/income_repository_impl.dart';
import '../../../income/domain/repositories/income_repository.dart';
import '../../../onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../../onboarding/domain/repositories/onboarding_repository.dart';
import '../../domain/entities/monthly_report.dart';
import '../../domain/usecases/get_monthly_report_usecase.dart';

final _reportIncomeRepo     = Provider<IncomeRepository>    ((_) => IncomeRepositoryImpl());
final _reportExpenseRepo    = Provider<ExpenseRepository>   ((_) => ExpenseRepositoryImpl());
final _reportGoalRepo       = Provider<GoalRepository>      ((_) => GoalRepositoryImpl());
final _reportOnboardingRepo = Provider<OnboardingRepository>((_) => OnboardingRepositoryImpl());

final _reportUseCaseProvider = Provider<GetMonthlyReportUseCase>((ref) =>
  GetMonthlyReportUseCase(
    incomeRepo:     ref.watch(_reportIncomeRepo),
    expenseRepo:    ref.watch(_reportExpenseRepo),
    goalRepo:       ref.watch(_reportGoalRepo),
    onboardingRepo: ref.watch(_reportOnboardingRepo),
  ),
);

final reportMonthProvider = StateProvider<DateTime>((_) => DateTime.now());

final monthlyReportProvider =
    Provider.family<MonthlyReport, String>((ref, monthKey) {
  final result = ref.watch(_reportUseCaseProvider).call(monthKey);
  return result.valueOrNull ??
      MonthlyReport(monthKey: monthKey, totalIncome: 0, totalVariable: 0, totalFixed: 0);
});

final last3MonthsProvider =
    Provider.family<List<MonthlyReport>, String>((ref, currentKey) {
  final parts = currentKey.split('-');
  if (parts.length != 2) return [];
  final year  = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  if (year == null || month == null) return [];
  final uc = ref.watch(_reportUseCaseProvider);
  return List.generate(3, (i) {
    var m = month - i; var y = year;
    while (m <= 0) { m += 12; y--; }
    final key    = '$y-${m.toString().padLeft(2,'0')}';
    final result = uc.call(key);
    return result.valueOrNull ??
        MonthlyReport(monthKey: key, totalIncome: 0, totalVariable: 0, totalFixed: 0);
  });
});
