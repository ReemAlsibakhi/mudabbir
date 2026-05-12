import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_strings.dart';

enum GoalType {
  home, car, wedding, travel, education,
  emergency, business, hajj, gold,
  // Family-specific
  university,     // الصندوق الجامعي للأبناء
  childWedding,   // زواج الأبناء
  healthInsurance,// التأمين الصحي العائلي
  other;

  String get nameAr => switch (this) {
    GoalType.home      => AppStrings.goalHome,
    GoalType.car       => AppStrings.goalCar,
    GoalType.wedding   => AppStrings.goalWedding,
    GoalType.travel    => AppStrings.goalTravel,
    GoalType.education => AppStrings.goalEducation,
    GoalType.emergency => AppStrings.goalEmergency,
    GoalType.business  => AppStrings.goalBusiness,
    GoalType.hajj      => AppStrings.goalHajj,
    GoalType.gold           => AppStrings.goalGold,
    GoalType.university     => AppStrings.goalUniversity,
    GoalType.childWedding   => AppStrings.goalChildWedding,
    GoalType.healthInsurance=> AppStrings.goalHealthInsurance,
    GoalType.other          => AppStrings.goalOther,
  };

  String get icon => switch (this) {
    GoalType.home      => '🏠',
    GoalType.car       => '🚗',
    GoalType.wedding   => '💍',
    GoalType.travel    => '✈️',
    GoalType.education => '🎓',
    GoalType.emergency => '🛡️',
    GoalType.business  => '💼',
    GoalType.hajj      => '🕌',
    GoalType.gold      => '💎',
    GoalType.other     => '⭐',
  };

  static GoalType fromString(String s) =>
      GoalType.values.firstWhere((t) => t.name == s, orElse: () => GoalType.other);
}

final class Goal extends Equatable {
  final String   id;
  final GoalType type;
  final String   name;
  final double   target;
  final double   saved;
  final double   monthlyTarget;
  final int?     targetMonths;
  final DateTime createdAt;
  final bool     completed;

  const Goal({
    required this.id,
    required this.type,
    required this.name,
    required this.target,
    this.saved         = 0,
    this.monthlyTarget = 0,
    this.targetMonths,
    required this.createdAt,
    this.completed = false,
  });

  // ── Computed ──────────────────────────────────────────
  double get progress    => target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;
  double get remaining   => (target - saved).clamp(0.0, double.infinity);
  bool   get isCompleted => saved >= target;

  /// Months left based on monthly target
  int? get monthsLeft {
    if (monthlyTarget <= 0 || remaining <= 0) return null;
    return (remaining / monthlyTarget).ceil();
  }

  /// What monthly saving would achieve goal in N months
  double monthlyNeeded(int months) {
    if (months <= 0 || remaining <= 0) return 0;
    return remaining / months;
  }

  /// Projected completion date
  DateTime? get projectedCompletion {
    final ml = monthsLeft;
    if (ml == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month + ml);
  }

  Goal copyWith({
    double? saved,
    double? monthlyTarget,
    bool?   completed,
  }) =>
      Goal(
        id:            id,
        type:          type,
        name:          name,
        target:        target,
        saved:         (saved ?? this.saved).clamp(0.0, target),
        monthlyTarget: monthlyTarget ?? this.monthlyTarget,
        targetMonths:  targetMonths,
        createdAt:     createdAt,
        completed:     completed ?? (saved ?? this.saved) >= target,
      );

  @override
  List<Object?> get props =>
      [id, type, name, target, saved, monthlyTarget, targetMonths, completed];
}
