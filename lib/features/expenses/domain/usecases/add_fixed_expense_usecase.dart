import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/result.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

const _uuid = Uuid();

final class AddFixedExpenseParams extends Equatable {
  final String categoryId;
  final String name;
  final double amount;
  final int?   dueDayOfMonth;

  const AddFixedExpenseParams({
    required this.categoryId,
    required this.name,
    required this.amount,
    this.dueDayOfMonth,
  });

  @override
  List<Object?> get props => [categoryId, name, amount, dueDayOfMonth];
}

final class AddFixedExpenseUseCase {
  final ExpenseRepository _repository;
  AddFixedExpenseUseCase(this._repository);

  Future<Result<void>> call(AddFixedExpenseParams p) async {
    if (p.amount <= 0)         return const Fail(ValidationFailure('المبلغ يجب أن يكون أكبر من صفر'));
    if (p.name.trim().isEmpty) return const Fail(ValidationFailure('اسم المصروف مطلوب'));

    final expense = FixedExpense(
      id:            _uuid.v4(),
      categoryId:    p.categoryId,
      name:          p.name.trim(),
      amount:        p.amount,
      dueDayOfMonth: p.dueDayOfMonth,
    );
    return _repository.addFixed(expense);
  }
}
