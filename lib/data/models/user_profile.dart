import 'package:hive/hive.dart';
part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0) String name;
  @HiveField(1) String countryId;
  @HiveField(2) String lifeStage; // single/engaged/married/family
  @HiveField(3) bool setupComplete;
  @HiveField(4) int streakCount;
  @HiveField(5) String lastLogDate;
  @HiveField(6) String bestStreak;
  @HiveField(7) int rescueTokensLeft;
  @HiveField(8) bool isPremium;
  @HiveField(9) String? weddingDate; // للمخطوب

  UserProfile({
    required this.name,
    required this.countryId,
    required this.lifeStage,
    this.setupComplete = false,
    this.streakCount = 0,
    this.lastLogDate = '',
    this.bestStreak = '0',
    this.rescueTokensLeft = 1,
    this.isPremium = false,
    this.weddingDate,
  });
}
