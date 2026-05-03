import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../expenses/presentation/providers/expenses_notifier.dart';
import '../../../goals/presentation/providers/goals_notifier.dart';
import '../../../income/presentation/providers/income_notifier.dart';
import '../../../onboarding/presentation/providers/onboarding_notifier.dart';
import '../../domain/entities/monthly_report.dart';
import '../../domain/usecases/get_monthly_report_usecase.dart';

// ✅ Reuses shared repo providers — no duplicate Hive connections
final _reportUseCaseProvider = Provider<GetMonthlyReportUseCase>(
  (ref) => GetMonthlyReportUseCase(
    incomeRepo:     ref.watch(incomeRepoProvider),    // shared
    expenseRepo:    ref.watch(expenseRepoProvider),   // shared
    goalRepo:       ref.watch(goalRepoProvider),      // shared
    onboardingRepo: ref.watch(onboardingRepoProvider),// shared
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
