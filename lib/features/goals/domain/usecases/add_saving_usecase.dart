import 'package:equatable/equatable.dart';
import '../../../../core/errors/result.dart';
import '../repositories/goal_repository.dart';

final class AddSavingParams extends Equatable {
  final String goalId;
  final String amountRaw;

  const AddSavingParams({required this.goalId, required this.amountRaw});

  @override
  List<Object?> get props => [goalId, amountRaw];
}

final class AddSavingUseCase {
  final GoalRepository _repo;
  AddSavingUseCase(this._repo);

  Future<Result<void>> call(AddSavingParams p) async {
    if (p.goalId.trim().isEmpty)
      return const Fail(ValidationFailure('معرّف الهدف غير صالح'));

    final amount = double.tryParse(p.amountRaw.trim().replaceAll(',', ''));
    if (amount == null)  return const Fail(ValidationFailure('أدخل رقماً صحيحاً'));
    if (amount <= 0)     return const Fail(ValidationFailure('المبلغ يجب أن يكون أكبر من صفر'));
    if (amount > 100e6)  return const Fail(ValidationFailure('المبلغ كبير جداً'));

    // Check goal exists first
    final goals = _repo.getAll();
    final goal  = goals.where((g) => g.id == p.goalId).firstOrNull;
    if (goal == null)
      return const Fail(NotFoundFailure('الهدف غير موجود'));

    // Edge: already completed
    if (goal.isCompleted)
      return const Fail(ValidationFailure('هذا الهدف مكتمل بالفعل'));

    return _repo.addSaving(p.goalId, amount);
  }
}
