import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../expenses/data/repositories/expense_repository_impl.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../goals/data/repositories/goal_repository_impl.dart';
import '../../../goals/domain/repositories/goal_repository.dart';
import '../../../income/data/repositories/income_repository_impl.dart';
import '../../../income/domain/repositories/income_repository.dart';
import '../../domain/entities/monthly_report.dart';
import '../../domain/usecases/get_monthly_report_usecase.dart';

// ── Repos (shared instances) ──────────────────────────────
final _reportIncomeRepo  = Provider<IncomeRepository> ((_) => IncomeRepositoryImpl());
final _reportExpenseRepo = Provider<ExpenseRepository>((_) => ExpenseRepositoryImpl());
final _reportGoalRepo    = Provider<GoalRepository>   ((_) => GoalRepositoryImpl());

// ── Use Case ──────────────────────────────────────────────
final _reportUseCaseProvider = Provider<GetMonthlyReportUseCase>((ref) =>
  GetMonthlyReportUseCase(
    incomeRepo:  ref.watch(_reportIncomeRepo),
    expenseRepo: ref.watch(_reportExpenseRepo),
    goalRepo:    ref.watch(_reportGoalRepo),
  ),
);

// ── Current month for report screen ───────────────────────
final reportMonthProvider = StateProvider<DateTime>((_) => DateTime.now());

// ── Monthly Report for one month key ──────────────────────
final monthlyReportProvider =
    Provider.family<MonthlyReport, String>((ref, monthKey) {
  final result = ref.watch(_reportUseCaseProvider).call(monthKey);
  return result.valueOrNull ??
      MonthlyReport(
        monthKey:      monthKey,
        totalIncome:   0,
        totalVariable: 0,
        totalFixed:    0,
      );
});

// ── Last 3 months for comparison ──────────────────────────
final last3MonthsProvider =
    Provider.family<List<MonthlyReport>, String>((ref, currentKey) {
  final parts = currentKey.split('-');
  // Edge: malformed key
  if (parts.length != 2) return [];

  final year  = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  if (year == null || month == null) return [];

  final uc = ref.watch(_reportUseCaseProvider);

  return List.generate(3, (i) {
    var m = month - i;
    var y = year;
    while (m <= 0) { m += 12; y--; }
    final key    = '$y-${m.toString().padLeft(2, '0')}';
    final result = uc.call(key);
    return result.valueOrNull ??
        MonthlyReport(
          monthKey:      key,
          totalIncome:   0,
          totalVariable: 0,
          totalFixed:    0,
        );
  });
});
