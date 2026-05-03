import '../../../../core/constants/app_strings.dart';
import 'package:equatable/equatable.dart';

enum LifeStage {
  single, engaged, married, family;

  String get nameAr => const {'single':AppStrings.stageSingle,'engaged':AppStrings.stageEngaged,'married':AppStrings.stageMarried,'family':AppStrings.stageFamily}[name]!;
  String get icon   => const {'single':'🧑','engaged':'💍','married':'👫','family':'👨‍👩‍👧‍👦'}[name]!;
  String get desc   => const {'single':AppStrings.stageMottoSingle,'engaged':AppStrings.stageMottoEngaged,'married':AppStrings.stageMottoMarried,'family':AppStrings.stageMottoFamily}[name]!;
  String get incomeLabel1 => (this==LifeStage.single||this==LifeStage.engaged) ? AppStrings.incomeLabelSingle : AppStrings.incomeLabelHusb;
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
