import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/utils/arabic_parser.dart';
import '../../../../core/utils/logger.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

const _uuid = Uuid();

final class AddExpenseParams extends Equatable {
  final String   categoryId;
  final String   name;
  final String   amountRaw;
  final DateTime date;

  const AddExpenseParams({
    required this.categoryId,
    required this.name,
    required this.amountRaw,
    required this.date,
  });

  @override
  List<Object?> get props => [categoryId, name, amountRaw, date];
}

final class AddExpenseUseCase {
  final ExpenseRepository _repo;
  const AddExpenseUseCase(this._repo);

  Future<Result<Expense>> call(AddExpenseParams p) async {
    // Validate category
    if (p.categoryId.trim().isEmpty)
      return const Fail(ValidationFailure(AppStrings.categoryRequired));

    // Validate date — no future, no older than 90 days
    final now = DateTime.now();
    if (p.date.isAfter(now.add(const Duration(days: 1))))
      return const Fail(ValidationFailure(AppStrings.dateInFuture));
    if (p.date.isBefore(now.subtract(const Duration(days: 90))))
      return const Fail(ValidationFailure(AppStrings.dateTooOld));

    // Parse amount via shared util (no duplication)
    final amountResult = ArabicParser.parseAmount(p.amountRaw);
    if (amountResult.isFailure) return Fail(amountResult.failureOrNull!);

    final expense = Expense(
      id:        _uuid.v4(),
      categoryId: p.categoryId.trim(),
      name:      p.name.trim().isEmpty ? p.categoryId : p.name.trim(),
      amount:    amountResult.valueOrNull!,
      date:      p.date.dateKey,    // ✅ extension, not inline formatting
      monthKey:  p.date.monthKey,   // ✅ extension
      createdAt: now,
    );

    AppLogger.info('AddExpense', '${expense.amount} → ${expense.categoryId}');
    return await _repo.add(expense).then(
      (r) => r.isSuccess ? Success(expense) : Fail(r.failureOrNull!),
    );
  }
}
