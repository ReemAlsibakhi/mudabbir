import 'package:equatable/equatable.dart';
import '../../../goals/domain/entities/goal.dart';

final class MonthlyReport extends Equatable {
  final String     monthKey;
  final double     totalIncome;
  final double     totalVariable;
  final double     totalFixed;
  final List<Goal> goals;

  const MonthlyReport({
    required this.monthKey,
    required this.totalIncome,
    required this.totalVariable,
    required this.totalFixed,
    this.goals = const [],
  });

  double get totalExpenses  => totalVariable + totalFixed;
  double get balance        => totalIncome - totalExpenses;
  double get savingRate     => totalIncome > 0
      ? ((balance / totalIncome) * 100).clamp(-100.0, 100.0) : 0.0;
  bool   get isDeficit      => balance < 0;
  bool   get hasData        => totalIncome > 0 || totalExpenses > 0;

  double get totalGoalsSaved => goals.fold(0.0, (s, g) => s + g.saved);

  String get personaIcon => switch (savingRate) {
    >= 20 => '🦁', >= 15 => '🐯', >= 10 => '🦊',
    >= 5  => '🐻', >= 0  => '🐢', _     => '🦔',
  };

  String get personaName => switch (savingRate) {
    >= 20 => 'الأسد المنضبط',  >= 15 => 'النمر الذكي',
    >= 10 => 'الثعلب الماهر',  >= 5  => 'الدب المتعلم',
    >= 0  => 'السلحفاة الصابرة', _    => 'القنفذ الحذر',
  };

  String get personaDesc => switch (savingRate) {
    >= 20 => 'انضباط مالي استثنائي! أنتم من أفضل الأسر ادخاراً.',
    >= 10 => 'أداء جيد. مع قليل من التحسين ستصلون للقمة.',
    >= 0  => 'الوضع يحتاج اهتماماً. ركزوا على أكبر 3 مصاريف.',
    _     => 'منطقة ضغط مالي. راجعوا المصاريف الثابتة فوراً.',
  };

  @override
  List<Object?> get props =>
      [monthKey, totalIncome, totalVariable, totalFixed, goals];
}
