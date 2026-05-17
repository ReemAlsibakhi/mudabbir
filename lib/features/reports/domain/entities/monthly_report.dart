import '../../../../core/constants/app_strings.dart';
import 'package:equatable/equatable.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../onboarding/domain/entities/onboarding_profile.dart';

final class MonthlyReport extends Equatable {
  final String     monthKey;
  final double     totalIncome;
  final double     totalVariable;
  final double     totalFixed;
  final List<Goal> goals;
  final LifeStage? lifeStage;

  const MonthlyReport({
    required this.monthKey,
    required this.totalIncome,
    required this.totalVariable,
    required this.totalFixed,
    this.goals     = const [],
    this.lifeStage,
  });

  double get totalExpenses => totalVariable + totalFixed;
  double get balance       => totalIncome - totalExpenses;
  double get savingRate    => totalIncome > 0
      ? ((balance / totalIncome) * 100).clamp(-100.0, 100.0) : 0.0;
  bool   get isDeficit     => balance < 0;
  bool   get hasData       => totalIncome > 0 || totalExpenses > 0;
  double get totalGoalsSaved => goals.fold(0.0, (s, g) => s + g.saved);

  // ── Persona adapts to life stage + saving rate ─────────────
  String get personaIcon {
    if (lifeStage == LifeStage.family) {
      return switch (savingRate) {
        >= 20 => '🦁', >= 10 => '🐻', >= 0 => '🐢', _ => '🦔',
      };
    }
    return switch (savingRate) {
      >= 20 => '🦁', >= 15 => '🐯', >= 10 => '🦊',
      >= 5  => '🐻', >= 0  => '🐢', _     => '🦔',
    };
  }

  String get personaName {
    final stage = lifeStage ?? LifeStage.single;
    return switch ((stage, savingRate >= 20)) {
      (LifeStage.single, true)   => AppStrings.personaSingle1,
      (LifeStage.single, false)  => AppStrings.personaSingle2,
      (LifeStage.engaged, true)  => AppStrings.personaEngaged1,
      (LifeStage.engaged, false) => AppStrings.personaEngaged2,
      (LifeStage.married, true)  => AppStrings.personaMarried1,
      (LifeStage.married, false) => AppStrings.personaMarried2,
      (LifeStage.family, true)   => AppStrings.personaFamily1,
      (LifeStage.family, false)  => AppStrings.personaFamily2,
      _                          => AppStrings.personaDefault,
    };
  }

  String get personaDesc {
    final stage = lifeStage ?? LifeStage.single;
    if (isDeficit) {
      return switch (stage) {
        LifeStage.family  => AppStrings.adviceFamily,
        LifeStage.married => AppStrings.adviceMarried,
        LifeStage.engaged => AppStrings.adviceEngaged,
        LifeStage.single  => AppStrings.adviceSingle,
      };
    }
    if (savingRate >= 20) {
      return switch (stage) {
        LifeStage.family  => '$personaIcon ${AppStrings.personaHighFamily}',
        LifeStage.married => '$personaIcon ${AppStrings.personaHighMarried}',
        LifeStage.engaged => '$personaIcon ${AppStrings.personaHighEngaged}',
        LifeStage.single  => '$personaIcon ${AppStrings.personaHighSingle}',
      };
    }
    return switch (stage) {
      LifeStage.family  => AppStrings.adviceFamily2,
      LifeStage.married => AppStrings.adviceMarried2,
      LifeStage.engaged => AppStrings.adviceEngaged2,
      LifeStage.single  => AppStrings.adviceSingle2,
    };
  }

  @override
  List<Object?> get props =>
      [monthKey, totalIncome, totalVariable, totalFixed, goals, lifeStage];
}
