import 'package:hive/hive.dart';
part 'goal.g.dart';

@HiveType(typeId: 4)
class Goal extends HiveObject {
  @HiveField(0)  String id;
  @HiveField(1)  String type;          // home/car/wedding/travel/education/emergency/business/other
  @HiveField(2)  String name;
  @HiveField(3)  double target;
  @HiveField(4)  double saved;
  @HiveField(5)  double monthlyTarget;
  @HiveField(6)  int?   targetMonths;
  @HiveField(7)  String? deadline;     // "2026-12"
  @HiveField(8)  DateTime createdAt;
  @HiveField(9)  bool completed;

  Goal({
    required this.id,
    required this.type,
    required this.name,
    required this.target,
    this.saved = 0,
    this.monthlyTarget = 0,
    this.targetMonths,
    this.deadline,
    required this.createdAt,
    this.completed = false,
  });

  double get progress => target > 0 ? (saved / target).clamp(0, 1) : 0;
  double get remaining => (target - saved).clamp(0, double.infinity);
  int get monthsLeft => monthlyTarget > 0 ? (remaining / monthlyTarget).ceil() : 0;
}
