import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/add_fixed_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import 'expenses_state.dart';

final expenseRepoProvider = Provider<ExpenseRepository>(
  (_) => ExpenseRepositoryImpl(),
);

final selectedMonthProvider = StateProvider<DateTime>((_) => DateTime.now());

final expensesNotifierProvider =
    StateNotifierProvider.autoDispose.family<ExpensesNotifier, ExpensesState, String>(
  (ref, monthKey) => ExpensesNotifier(
    monthKey: monthKey,
    repo:     ref.watch(expenseRepoProvider),
  ),
);

final class ExpensesNotifier extends StateNotifier<ExpensesState> {
  static const _tag = 'ExpensesNotifier';

  final String              _monthKey;
  final ExpenseRepository   _repo;
  StreamSubscription?       _varSub;
  StreamSubscription?       _fixSub;

  ExpensesNotifier({required String monthKey, required ExpenseRepository repo})
      : _monthKey = monthKey, _repo = repo, super(const ExpensesLoading()) {
    _init();
  }

  void _init() {
    try {
      _varSub = _repo.watchByMonth(_monthKey).listen(
        (list) {
          if (!mounted) return;
          final current = state is ExpensesLoaded ? state as ExpensesLoaded : const ExpensesLoaded();
          state = current.copyWith(expenses: list, clearError: true);
        },
        onError: (e, st) {
          AppLogger.error(_tag, 'variable stream error', e, st as StackTrace);
          if (mounted && state is ExpensesLoaded) {
            state = (state as ExpensesLoaded).copyWith(
              errorMessage: 'تعذّر تحميل المصاريف',
            );
          }
        },
        cancelOnError: false,
      );

      _fixSub = _repo.watchFixed().listen(
        (list) {
          if (!mounted) return;
          final current = state is ExpensesLoaded ? state as ExpensesLoaded : const ExpensesLoaded();
          state = current.copyWith(fixedExpenses: list);
        },
        onError: (e, st) {
          AppLogger.error(_tag, 'fixed stream error', e, st as StackTrace);
        },
        cancelOnError: false,
      );
    } catch (e, st) {
      AppLogger.error(_tag, 'init failed', e, st);
      state = ExpensesError('تعذّر تهيئة المصاريف: ${e.runtimeType}');
    }
  }

  // ── Add variable ──────────────────────────────────────

  Future<String?> addExpense(AddExpenseParams params) async {
    if (!mounted || state is! ExpensesLoaded) return null;
    state = (state as ExpensesLoaded).copyWith(isAdding: true, clearError: true);

    final result = await AddExpenseUseCase(_repo).call(params);
    if (!mounted) return null;

    if (result.isFailure) {
      state = (state as ExpensesLoaded).copyWith(
        isAdding: false,
        errorMessage: result.failureOrNull!.message,
      );
      return result.failureOrNull!.message; // return error for form to show
    }

    state = (state as ExpensesLoaded).copyWith(isAdding: false, clearError: true);
    return null; // null = success
  }

  // ── Add fixed ─────────────────────────────────────────

  Future<String?> addFixedExpense(AddFixedExpenseParams params) async {
    if (!mounted || state is! ExpensesLoaded) return null;
    state = (state as ExpensesLoaded).copyWith(isAdding: true, clearError: true);

    final result = await AddFixedExpenseUseCase(_repo).call(params);
    if (!mounted) return null;

    if (result.isFailure) {
      state = (state as ExpensesLoaded).copyWith(
        isAdding: false,
        errorMessage: result.failureOrNull!.message,
      );
      return result.failureOrNull!.message;
    }

    state = (state as ExpensesLoaded).copyWith(isAdding: false, clearError: true);
    return null;
  }

  // ── Delete ────────────────────────────────────────────

  Future<void> deleteExpense(String id) async {
    // Optimistic: stream will update UI automatically
    final result = await DeleteExpenseUseCase(_repo).call(id);
    if (result.isFailure && mounted && state is ExpensesLoaded) {
      state = (state as ExpensesLoaded).copyWith(
        errorMessage: 'تعذّر حذف المصروف',
      );
    }
  }

  Future<void> deleteFixedExpense(String id) async {
    final result = await DeleteFixedExpenseUseCase(_repo).call(id);
    if (result.isFailure && mounted && state is ExpensesLoaded) {
      state = (state as ExpensesLoaded).copyWith(
        errorMessage: 'تعذّر حذف المصروف الثابت',
      );
    }
  }

  void clearError() {
    if (mounted && state is ExpensesLoaded) {
      state = (state as ExpensesLoaded).copyWith(clearError: true);
    }
  }

  @override
  void dispose() {
    _varSub?.cancel();
    _fixSub?.cancel();
    super.dispose();
  }
}
