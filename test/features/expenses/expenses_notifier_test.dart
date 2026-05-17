import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/core/errors/result.dart';
import 'package:mudabbir/features/expenses/domain/entities/expense.dart';
import 'package:mudabbir/features/expenses/domain/repositories/expense_repository.dart';
import 'package:mudabbir/features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:mudabbir/features/expenses/domain/usecases/add_fixed_expense_usecase.dart';
import 'package:mudabbir/features/expenses/domain/usecases/delete_expense_usecase.dart';
import 'package:mudabbir/features/expenses/presentation/providers/expenses_notifier.dart';
import 'package:mudabbir/features/expenses/presentation/providers/expenses_state.dart';

// ── Fake repo ──────────────────────────────────────────────
class _FakeRepo implements ExpenseRepository {
  final List<Expense> _expenses = [];

  @override Stream<List<Expense>> watchByMonth(String k) =>
      Stream.value(List.from(_expenses));
  @override Stream<List<FixedExpense>> watchFixed() =>
      const Stream.empty();
  @override Future<Result<void>> add(Expense e) async {
    _expenses.add(e); return const Success(null);
  }
  @override Future<Result<void>> delete(String id) async {
    _expenses.removeWhere((e) => e.id == id); return const Success(null);
  }
  @override double totalByMonth(String k) =>
      _expenses.fold(0, (s, e) => s + e.amount);
  @override List<Expense> getByDate(String m, String d) => [];
  @override List<Expense> getByMonth(String k) => List.from(_expenses);
  @override Future<Result<void>> addFixed(FixedExpense e) async => const Success(null);
  @override Future<Result<void>> deleteFixed(String id) async => const Success(null);
  @override double totalFixed() => 0;
  @override List<FixedExpense> allActive() => [];
}

// ── Test helpers ───────────────────────────────────────────
ProviderContainer makeContainer(_FakeRepo repo) {
  final addUC     = AddExpenseUseCase(repo);
  final addFixUC  = AddFixedExpenseUseCase(repo);
  final delUC     = DeleteExpenseUseCase(repo);
  final delFixUC  = DeleteFixedExpenseUseCase(repo);

  return ProviderContainer(
    overrides: [
      expenseRepoProvider.overrideWithValue(repo),
      addExpenseUseCaseProvider.overrideWithValue(addUC),
      addFixedUseCaseProvider.overrideWithValue(addFixUC),
      deleteExpenseUseCaseProvider.overrideWithValue(delUC),
      deleteFixedUseCaseProvider.overrideWithValue(delFixUC),
    ],
  );
}

void main() {
  late _FakeRepo repo;
  late ProviderContainer container;
  const monthKey = '2025-04';

  setUp(() {
    repo      = _FakeRepo();
    container = makeContainer(repo);
    addTearDown(container.dispose);
  });

  test('initial state is ExpensesLoading', () {
    final state = container
        .read(expensesNotifierProvider(monthKey));
    expect(state, isA<ExpensesLoading>());
  });

  test('addExpense returns null on success', () async {
    await Future.delayed(Duration.zero); // allow stream to emit
    final notifier = container
        .read(expensesNotifierProvider(monthKey).notifier);
    final error = await notifier.addExpense(AddExpenseParams(
      categoryId: 'food', name: 'test',
      amountRaw: '100', date: DateTime.now(),
    ));
    expect(error, isNull);
  });

  test('addExpense returns error message on validation failure', () async {
    await Future.delayed(Duration.zero);
    final notifier = container
        .read(expensesNotifierProvider(monthKey).notifier);
    final error = await notifier.addExpense(AddExpenseParams(
      categoryId: '', name: 'test',
      amountRaw: '100', date: DateTime.now(),
    ));
    expect(error, isNotNull);
    expect(error, isA<String>());
  });
}
