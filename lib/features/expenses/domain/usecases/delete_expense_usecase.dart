import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/expense_repository.dart';

final class DeleteExpenseUseCase {
  final ExpenseRepository _repo;
  DeleteExpenseUseCase(this._repo);

  Future<Result<void>> call(String id) async {
    // Edge: empty id
    if (id.trim().isEmpty)
      return const Fail(ValidationFailure('معرّف المصروف غير صالح'));

    AppLogger.info('DeleteExpense', 'Deleting $id');
    return _repo.delete(id);
  }
}

final class DeleteFixedExpenseUseCase {
  final ExpenseRepository _repo;
  DeleteFixedExpenseUseCase(this._repo);

  Future<Result<void>> call(String id) async {
    if (id.trim().isEmpty)
      return const Fail(ValidationFailure('معرّف المصروف غير صالح'));
    return _repo.deleteFixed(id);
  }
}
