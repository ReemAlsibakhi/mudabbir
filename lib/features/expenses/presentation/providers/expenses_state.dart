import 'package:equatable/equatable.dart';
import '../../domain/entities/expense.dart';

// ─── State ────────────────────────────────────────────────
final class ExpensesState extends Equatable {
  final List<Expense>      expenses;
  final List<FixedExpense> fixedExpenses;
  final bool               isLoading;
  final String?            errorMessage;

  const ExpensesState({
    this.expenses      = const [],
    this.fixedExpenses = const [],
    this.isLoading     = false,
    this.errorMessage,
  });

  double get totalVariable => expenses.fold(0, (s, e) => s + e.amount);
  double get totalFixed    => fixedExpenses.fold(0, (s, e) => s + e.amount);
  double get total         => totalVariable + totalFixed;

  bool get hasExpenses      => expenses.isNotEmpty;
  bool get hasFixed         => fixedExpenses.isNotEmpty;
  bool get hasError         => errorMessage != null;

  ExpensesState copyWith({
    List<Expense>?      expenses,
    List<FixedExpense>? fixedExpenses,
    bool?               isLoading,
    String?             errorMessage,
  }) => ExpensesState(
    expenses:      expenses      ?? this.expenses,
    fixedExpenses: fixedExpenses ?? this.fixedExpenses,
    isLoading:     isLoading     ?? this.isLoading,
    errorMessage:  errorMessage,
  );

  @override
  List<Object?> get props => [expenses, fixedExpenses, isLoading, errorMessage];
}
