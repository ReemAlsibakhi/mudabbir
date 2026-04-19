import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/result.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

const _uuid = Uuid();

final class AddFixedExpenseParams extends Equatable {
  final String categoryId;
  final String name;
  final String amountRaw;
  final int?   dueDayOfMonth;

  const AddFixedExpenseParams({
    required this.categoryId,
    required this.name,
    required this.amountRaw,
    this.dueDayOfMonth,
  });

  @override
  List<Object?> get props => [categoryId, name, amountRaw, dueDayOfMonth];
}

final class AddFixedExpenseUseCase {
  final ExpenseRepository _repo;
  AddFixedExpenseUseCase(this._repo);

  Future<Result<FixedExpense>> call(AddFixedExpenseParams p) async {
    if (p.name.trim().isEmpty)
      return const Fail(ValidationFailure('اسم المصروف مطلوب'));

    // Edge: dueDayOfMonth must be 1-31
    if (p.dueDayOfMonth != null &&
        (p.dueDayOfMonth! < 1 || p.dueDayOfMonth! > 31))
      return const Fail(ValidationFailure('يوم الاستحقاق يجب أن يكون بين 1 و 31'));

    final amount = _parseAmount(p.amountRaw);
    if (amount.isFailure) return Fail(amount.failureOrNull!);

    final expense = FixedExpense(
      id:            _uuid.v4(),
      categoryId:    p.categoryId,
      name:          p.name.trim(),
      amount:        amount.valueOrNull!,
      dueDayOfMonth: p.dueDayOfMonth,
    );

    final result = await _repo.addFixed(expense);
    return result.isSuccess ? Success(expense) : Fail(result.failureOrNull!);
  }

  Result<double> _parseAmount(String raw) {
    if (raw.trim().isEmpty) return const Fail(ValidationFailure('المبلغ مطلوب'));
    final n = double.tryParse(raw.trim().replaceAll(',', ''));
    if (n == null || n <= 0) return const Fail(ValidationFailure('أدخل مبلغاً صحيحاً أكبر من صفر'));
    return Success(n);
  }
}
