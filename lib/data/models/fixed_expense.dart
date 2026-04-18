import 'package:hive/hive.dart';
part 'fixed_expense.g.dart';

@HiveType(typeId: 3)
class FixedExpense extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String categoryId;
  @HiveField(2) String name;
  @HiveField(3) double amount;
  @HiveField(4) bool active;
  @HiveField(5) DateTime createdAt;
  @HiveField(6) int? dueDayOfMonth; // يوم السداد من الشهر

  FixedExpense({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.amount,
    this.active = true,
    required this.createdAt,
    this.dueDayOfMonth,
  });
}
