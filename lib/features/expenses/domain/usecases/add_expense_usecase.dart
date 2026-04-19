import 'package:equatable/equatable.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

// ─── Params ───────────────────────────────────────────────
final class AddExpenseParams extends Equatable {
  final String   categoryId;
  final String   name;
  final double   amount;
  final DateTime date;

  const AddExpenseParams({
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.date,
  });

  @override
  List<Object?> get props => [categoryId, name, amount, date];
}

// ─── Use Case ─────────────────────────────────────────────
final class AddExpenseUseCase {
  final ExpenseRepository _repository;
  AddExpenseUseCase(this._repository);

  Future<Result<void>> call(AddExpenseParams p) async {
    // 1. Validate
    if (p.amount <= 0)       return const Fail(ValidationFailure('المبلغ يجب أن يكون أكبر من صفر'));
    if (p.name.trim().isEmpty) return const Fail(ValidationFailure('اسم المصروف مطلوب'));
    if (p.amount > 1e9)      return const Fail(ValidationFailure('المبلغ كبير جداً'));

    // 2. Build entity
    final expense = Expense(
      id:         DateTime.now().millisecondsSinceEpoch.toString(),
      categoryId: p.categoryId,
      name:       p.name.trim(),
      amount:     p.amount,
      date:       _dateKey(p.date),
      monthKey:   _monthKey(p.date),
      createdAt:  DateTime.now(),
    );

    // 3. Persist
    AppLogger.info('AddExpenseUseCase', 'Adding ${p.amount} to ${p.categoryId}');
    return _repository.add(expense);
  }

  String _dateKey(DateTime d)  => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _monthKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';
}
