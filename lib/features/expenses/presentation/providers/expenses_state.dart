import 'package:equatable/equatable.dart';
import '../../domain/entities/expense.dart';

sealed class ExpensesState extends Equatable {
  const ExpensesState();
  @override List<Object?> get props => [];
}

final class ExpensesLoading extends ExpensesState { const ExpensesLoading(); }

final class ExpensesLoaded extends ExpensesState {
  final List<Expense>      expenses;
  final List<FixedExpense> fixedExpenses;
  final bool               isAdding;
  final String?            errorMessage;

  const ExpensesLoaded({
    this.expenses      = const [],
    this.fixedExpenses = const [],
    this.isAdding      = false,
    this.errorMessage,
  });

  double get totalVariable => expenses.fold(0.0, (s, e) => s + e.amount);
  double get totalFixed    => fixedExpenses.fold(0.0, (s, e) => s + e.amount);
  double get total         => totalVariable + totalFixed;

  bool get isEmpty         => expenses.isEmpty && fixedExpenses.isEmpty;
  bool get hasUpcomingDue  => fixedExpenses.any((e) {
    final days = e.daysUntilDue();
    return days != null && days <= 3;
  });

  /// Group expenses by date for display
  Map<String, List<Expense>> get byDate {
    final map = <String, List<Expense>>{};
    for (final e in expenses) {
      map.putIfAbsent(e.date, () => []).add(e);
    }
    return map;
  }

  /// Category totals for charts
  Map<String, double> get categoryTotals {
    final map = <String, double>{};
    for (final e in expenses) {
      map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
    }
    return map;
  }

  ExpensesLoaded copyWith({
    List<Expense>?      expenses,
    List<FixedExpense>? fixedExpenses,
    bool?               isAdding,
    String?             errorMessage,
    bool                clearError = false,
  }) => ExpensesLoaded(
    expenses:      expenses      ?? this.expenses,
    fixedExpenses: fixedExpenses ?? this.fixedExpenses,
    isAdding:      isAdding      ?? this.isAdding,
    errorMessage:  clearError    ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [expenses, fixedExpenses, isAdding, errorMessage];
}

final class ExpensesError extends ExpensesState {
  final String message;
  const ExpensesError(this.message);
  @override List<Object?> get props => [message];
}
