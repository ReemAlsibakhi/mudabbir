import 'package:equatable/equatable.dart';

enum LifeStage {
  single, engaged, married, family;

  String get nameAr => const {'single':'أعزب','engaged':'مخطوب','married':'متزوج','family':'أسرة مع أطفال'}[name]!;
  String get icon   => const {'single':'🧑','engaged':'💍','married':'👫','family':'👨‍👩‍👧‍👦'}[name]!;
  String get desc   => const {'single':'تحكم بمستقبلك المالي','engaged':'وفّر لحلمك الكبير','married':'نسّق مع شريك حياتك','family':'أدر مصاريف أسرتك'}[name]!;
  String get incomeLabel1 => (this==LifeStage.single||this==LifeStage.engaged) ? 'راتبك الشهري' : 'دخل الزوج';
  bool get hasPartner       => this==LifeStage.married||this==LifeStage.family;
  bool get showMarriageGoal => this==LifeStage.single ||this==LifeStage.engaged;
  bool get showChildGoals   => this==LifeStage.family;
  static LifeStage fromString(String s) =>
      LifeStage.values.firstWhere((e)=>e.name==s, orElse: ()=>LifeStage.single);
}

final class OnboardingProfile extends Equatable {
  final String    name;
  final String    countryId;
  final LifeStage lifeStage;
  final double    primaryIncome;
  final double    secondaryIncome;
  final double    extraIncome;

  const OnboardingProfile({
    required this.name,      required this.countryId,
    required this.lifeStage, this.primaryIncome=0,
    this.secondaryIncome=0,  this.extraIncome=0,
  });

  double get totalIncome => primaryIncome + secondaryIncome + extraIncome;
  bool   get hasIncome   => totalIncome > 0;

  OnboardingProfile copyWith({
    String? name, String? countryId, LifeStage? lifeStage,
    double? primaryIncome, double? secondaryIncome, double? extraIncome,
  }) => OnboardingProfile(
    name:            name            ?? this.name,
    countryId:       countryId       ?? this.countryId,
    lifeStage:       lifeStage       ?? this.lifeStage,
    primaryIncome:   primaryIncome   ?? this.primaryIncome,
    secondaryIncome: secondaryIncome ?? this.secondaryIncome,
    extraIncome:     extraIncome     ?? this.extraIncome,
  );

  @override
  List<Object?> get props =>
      [name, countryId, lifeStage, primaryIncome, secondaryIncome, extraIncome];
}
