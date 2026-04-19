import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/result.dart';
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
  AddExpenseUseCase(this._repo);

  Future<Result<Expense>> call(AddExpenseParams p) async {
    // ── Validate ─────────────────────────────────────────
    if (p.categoryId.trim().isEmpty)
      return const Fail(ValidationFailure('الفئة مطلوبة'));

    // Edge: future date not allowed
    if (p.date.isAfter(DateTime.now().add(const Duration(days: 1))))
      return const Fail(ValidationFailure('لا يمكن تسجيل مصروف في المستقبل'));

    // Edge: date too old (> 90 days)
    if (p.date.isBefore(DateTime.now().subtract(const Duration(days: 90))))
      return const Fail(ValidationFailure('لا يمكن تسجيل مصروف قبل 90 يوماً'));

    final amount = _parseAmount(p.amountRaw);
    if (amount.isFailure) return Fail(amount.failureOrNull!);

    final expense = Expense(
      id:         _uuid.v4(),
      categoryId: p.categoryId.trim(),
      name:       p.name.trim().isEmpty ? p.categoryId : p.name.trim(),
      amount:     amount.valueOrNull!,
      date:       _dateKey(p.date),
      monthKey:   _monthKey(p.date),
      createdAt:  DateTime.now(),
    );

    AppLogger.info('AddExpense', '${expense.amount} → ${expense.categoryId}');
    final result = await _repo.add(expense);
    return result.isSuccess ? Success(expense) : Fail(result.failureOrNull!);
  }

  Result<double> _parseAmount(String raw) {
    if (raw.trim().isEmpty) return const Fail(ValidationFailure('المبلغ مطلوب'));
    final n = double.tryParse(_normalize(raw.trim()));
    if (n == null)    return const Fail(ValidationFailure('أدخل رقماً صحيحاً'));
    if (n <= 0)       return const Fail(ValidationFailure('المبلغ يجب أن يكون أكبر من صفر'));
    if (n > 10000000) return const Fail(ValidationFailure('المبلغ كبير جداً'));
    if (n.isNaN || n.isInfinite) return const Fail(ValidationFailure('قيمة غير صالحة'));
    return Success(n);
  }

  String _normalize(String s) => s
      .replaceAllMapped(RegExp(r'[٠-٩]'), (m) =>
          (m.group(0)!.codeUnitAt(0) - 0x0660).toString())
      .replaceAll('٫', '.').replaceAll(',', '');

  String _dateKey(DateTime d)  =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  String _monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}';
}
