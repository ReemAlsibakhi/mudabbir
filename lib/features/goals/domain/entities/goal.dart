import 'package:equatable/equatable.dart';

enum GoalType {
  home, car, wedding, travel, education,
  emergency, business, hajj, gold, other;

  String get nameAr => switch (this) {
    GoalType.home      => 'شراء منزل',
    GoalType.car       => 'سيارة',
    GoalType.wedding   => 'زواج',
    GoalType.travel    => 'سفر وإجازة',
    GoalType.education => 'تعليم الأبناء',
    GoalType.emergency => 'صندوق طوارئ',
    GoalType.business  => 'مشروع تجاري',
    GoalType.hajj      => 'حج وعمرة',
    GoalType.gold      => 'ذهب ومجوهرات',
    GoalType.other     => 'أخرى',
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
