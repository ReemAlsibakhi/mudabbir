import 'package:equatable/equatable.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

final class AddSavingsParams extends Equatable {
  final String goalId;
  final String amountRaw;
  const AddSavingsParams({required this.goalId, required this.amountRaw});
  @override List<Object?> get props => [goalId, amountRaw];
}

/// Returns updated Goal or failure
final class AddSavingsUseCase {
  final GoalRepository _repo;
  AddSavingsUseCase(this._repo);

  Future<Result<Goal>> call(AddSavingsParams p) async {
    if (p.goalId.trim().isEmpty) return const Fail(NotFoundFailure('معرّف الهدف غير صالح'));

    final amount = double.tryParse(p.amountRaw.replaceAll(',', '').trim());
    if (amount == null || amount <= 0) return const Fail(ValidationFailure('أدخل مبلغاً صحيحاً'));

    final goal = _repo.getById(p.goalId);
    if (goal == null) return const Fail(NotFoundFailure('الهدف غير موجود'));
    if (goal.isCompleted) return const Fail(ValidationFailure('هذا الهدف مكتمل بالفعل'));

    final updated = goal.addSavings(amount);
    AppLogger.info('AddSavingsUseCase', 'Adding $amount to ${goal.name}, progress=${updated.progress}');

    final result = await _repo.update(updated);
    return result.isSuccess ? Success(updated) : Fail(result.failureOrNull!);
  }
}
