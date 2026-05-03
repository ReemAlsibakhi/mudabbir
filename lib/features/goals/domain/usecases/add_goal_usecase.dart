import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/arabic_parser.dart';
import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

const _uuid = Uuid();

enum GoalInputMode { byDuration, byMonthlyAmount }

final class AddGoalParams extends Equatable {
  final GoalType      type;
  final String        name;
  final String        targetRaw;
  final String        savedRaw;
  final GoalInputMode mode;
  final int?          durationMonths;
  final String?       monthlyAmountRaw;

  const AddGoalParams({
    required this.type,
    required this.name,
    required this.targetRaw,
    this.savedRaw         = '0',
    required this.mode,
    this.durationMonths,
    this.monthlyAmountRaw,
  });

  @override
  List<Object?> get props =>
      [type, name, targetRaw, savedRaw, mode, durationMonths, monthlyAmountRaw];
}

final class AddGoalUseCase {
  final GoalRepository _repo;
  const AddGoalUseCase(this._repo);

  Future<Result<Goal>> call(AddGoalParams p) async {
    // Validate name
    if (p.name.trim().isEmpty)
      return const Fail(ValidationFailure(AppStrings.goalNameRequired));
    if (p.name.trim().length > 60)
      return const Fail(ValidationFailure(AppStrings.nameTooLong));

    // Parse target — shared util, handles Arabic digits
    final target = ArabicParser.parseAmount(p.targetRaw, max: 100e6);
    if (target.isFailure) return Fail(target.failureOrNull!);

    // Parse saved — optional (defaults to 0)
    final saved = ArabicParser.parseOptionalAmount(p.savedRaw);
    if (saved.isFailure) return Fail(saved.failureOrNull!);

    if (saved.valueOrNull! > target.valueOrNull!)
      return const Fail(ValidationFailure(AppStrings.savedExceedsTarget));

    final remaining = target.valueOrNull! - saved.valueOrNull!;
    double monthly  = 0;
    int?   months;

    switch (p.mode) {
      case GoalInputMode.byDuration:
        if (p.durationMonths == null || p.durationMonths! <= 0)
          return const Fail(ValidationFailure(AppStrings.positiveIntReq));
        if (p.durationMonths! > 600)
          return const Fail(ValidationFailure(AppStrings.durationTooLong));
        months  = p.durationMonths!;
        monthly = remaining > 0 ? remaining / months : 0;

      case GoalInputMode.byMonthlyAmount:
        final mo = ArabicParser.parseAmount(p.monthlyAmountRaw ?? '', max: 100e6);
        if (mo.isFailure) return Fail(mo.failureOrNull!);
        monthly = mo.valueOrNull!;
        months  = remaining > 0 ? (remaining / monthly).ceil() : 0;
        if (months > 1200)
          return const Fail(ValidationFailure(AppStrings.monthlyTooHigh));
    }

    final goal = Goal(
      id:            _uuid.v4(),
      type:          p.type,
      name:          p.name.trim(),
      target:        target.valueOrNull!,
      saved:         saved.valueOrNull!,
      monthlyTarget: monthly,
      targetMonths:  months,
      createdAt:     DateTime.now(),
    );

    final result = await _repo.save(goal);
    return result.isSuccess ? Success(goal) : Fail(result.failureOrNull!);
  }
}
