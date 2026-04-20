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
      (LifeStage.single, true)   => 'الأعزب المنضبط',
      (LifeStage.single, false)  => 'الأعزب المتعلم',
      (LifeStage.engaged, true)  => 'المخطوب الذكي',
      (LifeStage.engaged, false) => 'المخطوب المستعجل',
      (LifeStage.married, true)  => 'الزوجان المثاليان',
      (LifeStage.married, false) => 'الزوجان المتحسّنان',
      (LifeStage.family, true)   => 'الأسرة البطلة',
      (LifeStage.family, false)  => 'الأسرة المتقدمة',
      _                          => 'المالي الذكي',
    };
  }

  String get personaDesc {
    final stage = lifeStage ?? LifeStage.single;
    if (isDeficit) {
      return switch (stage) {
        LifeStage.family  => 'الأسرة تحتاج مراجعة. ابدأ بالمصاريف الثابتة الكبيرة أولاً.',
        LifeStage.married => 'اتفقا على خفض بند واحد هذا الشهر — ابدأا بالمطاعم.',
        LifeStage.engaged => 'انتبه — الزواج يحتاج ميزانية وفائض، ليس عجزاً.',
        LifeStage.single  => 'وضع صعب. راجع أكبر 3 مصاريف وقلّلها الشهر القادم.',
      };
    }
    if (savingRate >= 20) {
      return switch (stage) {
        LifeStage.family  => '${personaIcon} أسرتكم من أفضل 10% في إدارة الميزانية! الأطفال محظوظون.',
        LifeStage.married => '${personaIcon} زوجان يتفاهمان — انضباطكم المالي مثال يُحتذى به.',
        LifeStage.engaged => '${personaIcon} ممتاز! تبدأ حياتكم بأفضل أساس مالي ممكن.',
        LifeStage.single  => '${personaIcon} انضباط استثنائي! وفّر الآن واستثمر — الوقت في صالحك.',
      };
    }
    return switch (stage) {
      LifeStage.family  => 'أداء جيد للأسرة. صندوق طوارئ 6 أشهر = الأولوية القصوى الآن.',
      LifeStage.married => 'وضع معقول. جرّبا تحديد سقف أسبوعي للمصاريف اليومية معاً.',
      LifeStage.engaged => 'ادخروا أكثر — حفل الزفاف والشقة يحتاجان جيباً عميقاً.',
      LifeStage.single  => 'يمكنك أفضل من هذا. هدف بسيط: وفّر 500 ريال إضافية الشهر القادم.',
    };
  }

  @override
  List<Object?> get props =>
      [monthKey, totalIncome, totalVariable, totalFixed, goals, lifeStage];
}
