import 'package:hive/hive.dart';
part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0) String name;
  @HiveField(1) String countryId;
  @HiveField(2) String lifeStage;
  @HiveField(3) double primaryIncome;
  @HiveField(4) double secondaryIncome;
  @HiveField(5) double extraIncome;
  @HiveField(6) bool   onboarded;
  @HiveField(7) int    streakCount;
  @HiveField(8) String lastLogDate;
  @HiveField(9) String bestStreak;
  @HiveField(10) int   rescueTokens;

  UserModel({
    required this.name,        required this.countryId,
    required this.lifeStage,   this.primaryIncome=0,
    this.secondaryIncome=0,    this.extraIncome=0,
    this.onboarded=false,      this.streakCount=0,
    this.lastLogDate='',       this.bestStreak='0',
    this.rescueTokens=1,
  });
}
