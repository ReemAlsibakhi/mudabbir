import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/add_fixed_expense_usecase.dart';
import 'expenses_state.dart';

// ─── Providers ────────────────────────────────────────────

final expenseRepoProvider = Provider<ExpenseRepository>(
  (_) => ExpenseRepositoryImpl(),
);

final selectedMonthProvider = StateProvider<DateTime>(
  (_) => DateTime.now(),
);

final expensesNotifierProvider =
    StateNotifierProvider.family<ExpensesNotifier, ExpensesState, String>(
  (ref, monthKey) => ExpensesNotifier(
    monthKey: monthKey,
    repo:     ref.watch(expenseRepoProvider),
  ),
);

// ─── Notifier ─────────────────────────────────────────────

final class ExpensesNotifier extends StateNotifier<ExpensesState> {
  static const _tag = 'ExpensesNotifier';

  final String              _monthKey;
  final ExpenseRepository   _repo;
  StreamSubscription?       _varSub;
  StreamSubscription?       _fixSub;

  ExpensesNotifier({
    required String            monthKey,
    required ExpenseRepository repo,
  })  : _monthKey = monthKey,
        _repo     = repo,
        super(const ExpensesState()) {
    _init();
  }

  void _init() {
    _varSub = _repo.watchByMonth(_monthKey).listen(
      (list) => state = state.copyWith(expenses: list),
      onError: (e) => AppLogger.error(_tag, 'watchByMonth error', e),
    );
    _fixSub = _repo.watchFixed().listen(
      (list) => state = state.copyWith(fixedExpenses: list),
      onError: (e) => AppLogger.error(_tag, 'watchFixed error', e),
    );
  }

  // ── Add variable expense ─────────────────────────────

  Future<bool> addExpense(AddExpenseParams params) async {
    state = state.copyWith(isLoading: true);
    final result = await AddExpenseUseCase(_repo).call(params);
    state = state.copyWith(isLoading: false);
    return result.isSuccess;
  }

  // ── Delete variable expense ──────────────────────────

  Future<bool> deleteExpense(String id) async {
    final result = await _repo.delete(id);
    if (result.isFailure) {
      AppLogger.error(_tag, 'Delete failed: ${result.failureOrNull}');
    }
    return result.isSuccess;
  }

  // ── Add fixed expense ────────────────────────────────

  Future<bool> addFixedExpense(AddFixedExpenseParams params) async {
    state = state.copyWith(isLoading: true);
    final result = await AddFixedExpenseUseCase(_repo).call(params);
    state = state.copyWith(isLoading: false);
    return result.isSuccess;
  }

  // ── Delete fixed expense ─────────────────────────────

  Future<bool> deleteFixedExpense(String id) async {
    final result = await _repo.deleteFixed(id);
    return result.isSuccess;
  }

  @override
  void dispose() {
    _varSub?.cancel();
    _fixSub?.cancel();
    super.dispose();
  }
}
