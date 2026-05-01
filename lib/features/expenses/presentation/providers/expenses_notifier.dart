import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/add_fixed_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import 'expenses_state.dart';

// ── Single shared repo instance ────────────────────────────
final expenseRepoProvider = Provider<ExpenseRepository>(
  (_) => ExpenseRepositoryImpl(),
);

// ── Injected use case providers ────────────────────────────
final addExpenseUseCaseProvider = Provider<AddExpenseUseCase>(
  (ref) => AddExpenseUseCase(ref.watch(expenseRepoProvider)),
);
final addFixedUseCaseProvider = Provider<AddFixedExpenseUseCase>(
  (ref) => AddFixedExpenseUseCase(ref.watch(expenseRepoProvider)),
);
final deleteExpenseUseCaseProvider = Provider<DeleteExpenseUseCase>(
  (ref) => DeleteExpenseUseCase(ref.watch(expenseRepoProvider)),
);
final deleteFixedUseCaseProvider = Provider<DeleteFixedExpenseUseCase>(
  (ref) => DeleteFixedExpenseUseCase(ref.watch(expenseRepoProvider)),
);

// ── Notifier provider ─────────────────────────────────────
final selectedMonthProvider = StateProvider<DateTime>((_) => DateTime.now());

final expensesNotifierProvider =
    StateNotifierProvider.autoDispose.family<ExpensesNotifier, ExpensesState, String>(
  (ref, monthKey) => ExpensesNotifier(
    monthKey:       monthKey,
    repo:           ref.watch(expenseRepoProvider),
    addUseCase:     ref.watch(addExpenseUseCaseProvider),
    addFixedUseCase: ref.watch(addFixedUseCaseProvider),
    deleteUseCase:  ref.watch(deleteExpenseUseCaseProvider),
    deleteFixedUseCase: ref.watch(deleteFixedUseCaseProvider),
  ),
);

final class ExpensesNotifier extends StateNotifier<ExpensesState> {
  static const _tag = 'ExpensesNotifier';

  final String                  _monthKey;
  final ExpenseRepository       _repo;
  // ✅ Injected — mockable in tests
  final AddExpenseUseCase       _addUseCase;
  final AddFixedExpenseUseCase  _addFixedUseCase;
  final DeleteExpenseUseCase    _deleteUseCase;
  final DeleteFixedExpenseUseCase _deleteFixedUseCase;

  StreamSubscription? _varSub;
  StreamSubscription? _fixSub;

  ExpensesNotifier({
    required String                  monthKey,
    required ExpenseRepository       repo,
    required AddExpenseUseCase       addUseCase,
    required AddFixedExpenseUseCase  addFixedUseCase,
    required DeleteExpenseUseCase    deleteUseCase,
    required DeleteFixedExpenseUseCase deleteFixedUseCase,
  })  : _monthKey          = monthKey,
        _repo              = repo,
        _addUseCase        = addUseCase,
        _addFixedUseCase   = addFixedUseCase,
        _deleteUseCase     = deleteUseCase,
        _deleteFixedUseCase = deleteFixedUseCase,
        super(const ExpensesLoading()) {
    _init();
  }

  void _init() {
    try {
      _varSub = _repo.watchByMonth(_monthKey).listen(
        (list) {
          if (!mounted) return;
          final cur = state is ExpensesLoaded
              ? state as ExpensesLoaded
              : const ExpensesLoaded();
          state = cur.copyWith(expenses: list, clearError: true);
        },
        onError: (e, st) {
          AppLogger.error(_tag, 'variable stream', e, st as StackTrace);
          if (mounted && state is ExpensesLoaded)
            state = (state as ExpensesLoaded).copyWith(errorMessage: 'تعذّر تحميل المصاريف');
        },
        cancelOnError: false,
      );
      _fixSub = _repo.watchFixed().listen(
        (list) {
          if (!mounted) return;
          final cur = state is ExpensesLoaded
              ? state as ExpensesLoaded
              : const ExpensesLoaded();
          state = cur.copyWith(fixedExpenses: list);
        },
        onError: (e, st) =>
            AppLogger.error(_tag, 'fixed stream', e, st as StackTrace),
        cancelOnError: false,
      );
    } catch (e, st) {
      AppLogger.error(_tag, 'init failed', e, st);
      state = ExpensesError('تعذّر تهيئة المصاريف: ${e.runtimeType}');
    }
  }

  Future<String?> addExpense(AddExpenseParams params) async {
    if (!mounted || state is! ExpensesLoaded) return null;
    state = (state as ExpensesLoaded).copyWith(isAdding: true, clearError: true);
    final result = await _addUseCase(params); // ✅ injected
    if (!mounted) return null;
    if (result.isFailure) {
      state = (state as ExpensesLoaded).copyWith(
        isAdding: false, errorMessage: result.failureOrNull!.message);
      return result.failureOrNull!.message;
    }
    state = (state as ExpensesLoaded).copyWith(isAdding: false, clearError: true);
    return null;
  }

  Future<String?> addFixedExpense(AddFixedExpenseParams params) async {
    if (!mounted || state is! ExpensesLoaded) return null;
    state = (state as ExpensesLoaded).copyWith(isAdding: true, clearError: true);
    final result = await _addFixedUseCase(params); // ✅ injected
    if (!mounted) return null;
    if (result.isFailure) {
      state = (state as ExpensesLoaded).copyWith(
        isAdding: false, errorMessage: result.failureOrNull!.message);
      return result.failureOrNull!.message;
    }
    state = (state as ExpensesLoaded).copyWith(isAdding: false, clearError: true);
    return null;
  }

  Future<void> deleteExpense(String id) async {
    final result = await _deleteUseCase(id); // ✅ injected
    if (result.isFailure && mounted && state is ExpensesLoaded)
      state = (state as ExpensesLoaded).copyWith(errorMessage: 'تعذّر حذف المصروف');
  }

  Future<void> deleteFixedExpense(String id) async {
    final result = await _deleteFixedUseCase(id); // ✅ injected
    if (result.isFailure && mounted && state is ExpensesLoaded)
      state = (state as ExpensesLoaded).copyWith(errorMessage: 'تعذّر حذف المصروف الثابت');
  }

  void clearError() {
    if (mounted && state is ExpensesLoaded)
      state = (state as ExpensesLoaded).copyWith(clearError: true);
  }

  @override
  void dispose() {
    _varSub?.cancel();
    _fixSub?.cancel();
    super.dispose();
  }
}
