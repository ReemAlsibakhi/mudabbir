import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/result.dart';
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
  final int?          durationMonths;   // mode = byDuration
  final String?       monthlyAmountRaw; // mode = byMonthlyAmount

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
  AddGoalUseCase(this._repo);

  Future<Result<Goal>> call(AddGoalParams p) async {
    // ── Validate name ─────────────────────────────────
    if (p.name.trim().isEmpty)
      return const Fail(ValidationFailure('اسم الهدف مطلوب'));
    if (p.name.trim().length > 60)
      return const Fail(ValidationFailure('اسم الهدف طويل جداً (أقل من 60 حرفاً)'));

    // ── Parse target ──────────────────────────────────
    final target = _parsePositive(p.targetRaw, 'المبلغ المستهدف');
    if (target.isFailure) return Fail(target.failureOrNull!);
    if (target.valueOrNull! < 1)
      return const Fail(ValidationFailure('المبلغ المستهدف يجب أن يكون أكبر من صفر'));

    // ── Parse saved ───────────────────────────────────
    final saved = _parseNonNeg(p.savedRaw, 'المدخر الحالي');
    if (saved.isFailure) return Fail(saved.failureOrNull!);

    // Edge: saved > target
    if (saved.valueOrNull! > target.valueOrNull!) {
      return const Fail(ValidationFailure('المدخر الحالي لا يمكن أن يتجاوز المبلغ المستهدف'));
    }

    // ── Compute monthly target ─────────────────────────
    final remaining = target.valueOrNull! - saved.valueOrNull!;
    double monthly  = 0;
    int?   months;

    switch (p.mode) {
      case GoalInputMode.byDuration:
        if (p.durationMonths == null || p.durationMonths! <= 0)
          return const Fail(ValidationFailure('عدد الأشهر غير صالح'));
        if (p.durationMonths! > 600)
          return const Fail(ValidationFailure('المدة تبدو طويلة جداً (أكثر من 50 سنة)'));
        months  = p.durationMonths!;
        monthly = remaining > 0 ? remaining / months : 0;

      case GoalInputMode.byMonthlyAmount:
        final mo = _parsePositive(p.monthlyAmountRaw ?? '', 'المبلغ الشهري');
        if (mo.isFailure) return Fail(mo.failureOrNull!);
        monthly = mo.valueOrNull!;
        months  = remaining > 0 ? (remaining / monthly).ceil() : 0;
        // Edge: would take > 100 years
        if (months > 1200)
          return const Fail(ValidationFailure('بهذا المعدل سيستغرق الهدف أكثر من 100 سنة'));
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

  Result<double> _parsePositive(String raw, String field) {
    if (raw.trim().isEmpty) return Fail(ValidationFailure('$field مطلوب'));
    final n = double.tryParse(raw.trim().replaceAll(',', ''));
    if (n == null)  return Fail(ValidationFailure('$field: أدخل رقماً صحيحاً'));
    if (n <= 0)     return Fail(ValidationFailure('$field يجب أن يكون أكبر من صفر'));
    if (n > 100e6)  return Fail(ValidationFailure('$field كبير جداً'));
    return Success(n);
  }

  Result<double> _parseNonNeg(String raw, String field) {
    if (raw.trim().isEmpty) return const Success(0.0);
    final n = double.tryParse(raw.trim().replaceAll(',', ''));
    if (n == null) return Fail(ValidationFailure('$field: أدخل رقماً صحيحاً'));
    if (n < 0)     return Fail(ValidationFailure('$field لا يمكن أن يكون سالباً'));
    return Success(n);
  }
}
