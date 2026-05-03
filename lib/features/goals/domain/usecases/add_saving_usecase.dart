import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/arabic_parser.dart';
import '../repositories/goal_repository.dart';

final class AddSavingParams extends Equatable {
  final String goalId;
  final String amountRaw;
  const AddSavingParams({required this.goalId, required this.amountRaw});
  @override List<Object?> get props => [goalId, amountRaw];
}

final class AddSavingUseCase {
  final GoalRepository _repo;
  const AddSavingUseCase(this._repo);

  Future<Result<void>> call(AddSavingParams p) async {
    if (p.goalId.trim().isEmpty)
      return const Fail(ValidationFailure(AppStrings.fieldRequired));

    // Shared parser — handles Arabic digits
    final amount = ArabicParser.parseAmount(p.amountRaw, max: 100e6);
    if (amount.isFailure) return Fail(amount.failureOrNull!);

    final goals = _repo.getAll();
    final goal  = goals.where((g) => g.id == p.goalId).firstOrNull;
    if (goal == null)
      return const Fail(NotFoundFailure(AppStrings.fieldRequired));
    if (goal.isCompleted)
      return const Fail(ValidationFailure(AppStrings.savedExceedsTarget));

    return _repo.addSaving(p.goalId, amount.valueOrNull!);
  }
}
