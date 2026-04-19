import 'package:equatable/equatable.dart';
import '../../../goals/domain/entities/goal.dart' show GoalType;

enum LifeStage { single, engaged, married, family }

extension LifeStageExt on LifeStage {
  String get nameAr {
    const m = {LifeStage.single:'أعزب',LifeStage.engaged:'مخطوب',LifeStage.married:'متزوج',LifeStage.family:'أسرة مع أطفال'};
    return m[this]!;
  }
  String get icon {
    const m = {LifeStage.single:'🧑',LifeStage.engaged:'💍',LifeStage.married:'👫',LifeStage.family:'👨‍👩‍👧‍👦'};
    return m[this]!;
  }
  String get desc {
    const m = {
      LifeStage.single:  'أدر مصاريفك الشخصية ووفّر لأهدافك',
      LifeStage.engaged: 'خطط لتكاليف زواجك وحقق حلمك',
      LifeStage.married: 'نسّق ميزانيتك مع شريك حياتك',
      LifeStage.family:  'أدر مصاريف أسرتك بذكاء واكتمال',
    };
    return m[this]!;
  }
  bool get showMarriageGoal => this == LifeStage.single || this == LifeStage.engaged;
  bool get showChildrenGoals => this == LifeStage.family;
  bool get hasPartner => this == LifeStage.married || this == LifeStage.family;
  String get incomeLabel => hasPartner ? 'دخل الزوج' : 'راتبك الشهري';
  String greet(String name) => hasPartner ? 'أبو $name' : 'يا $name';
  static LifeStage fromString(String s) =>
      LifeStage.values.firstWhere((e) => e.name == s, orElse: () => LifeStage.single);
}

final class OnboardingData extends Equatable {
  final String    name;
  final String    countryId;
  final LifeStage lifeStage;

  const OnboardingData({
    required this.name,
    required this.countryId,
    required this.lifeStage,
  });

  bool get isComplete =>
      name.trim().isNotEmpty &&
      countryId.isNotEmpty &&
      name.trim().length >= 2;

  @override
  List<Object?> get props => [name, countryId, lifeStage];
}
