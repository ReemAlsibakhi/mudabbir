import 'package:hive/hive.dart';
part 'goal_model.g.dart';

@HiveType(typeId: 4)
class GoalModel extends HiveObject {
  @HiveField(0) String   id;
  @HiveField(1) String   type;
  @HiveField(2) String   name;
  @HiveField(3) double   target;
  @HiveField(4) double   saved;
  @HiveField(5) double   monthlyTarget;
  @HiveField(6) int?     targetMonths;
  @HiveField(7) DateTime createdAt;
  @HiveField(8) bool     completed;

  GoalModel({
    required this.id,       required this.type,
    required this.name,     required this.target,
    this.saved = 0,         this.monthlyTarget = 0,
    this.targetMonths,      required this.createdAt,
    this.completed = false,
  });
}
