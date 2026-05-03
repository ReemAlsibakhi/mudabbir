import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/arabic_parser.dart';
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
      return const Fail(ValidationFailure(AppStrings.fieldRequired));

    // Edge: dueDayOfMonth must be 1-31
    if (p.dueDayOfMonth != null &&
        (p.dueDayOfMonth! < 1 || p.dueDayOfMonth! > 31))
      return const Fail(ValidationFailure(AppStrings.fieldRequired));

    final amount = ArabicParser.parseAmount(p.amountRaw);
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
    if (raw.trim().isEmpty) return const Fail(ValidationFailure(AppStrings.amountRequired));
    final n = double.tryParse(raw.trim().replaceAll(',', ''));
    if (n == null || n <= 0) return const Fail(ValidationFailure(AppStrings.amountZero));
    return Success(n);
  }
}
