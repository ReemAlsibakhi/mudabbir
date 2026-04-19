import 'package:hive/hive.dart';
part 'fixed_expense_model.g.dart';

@HiveType(typeId: 3)
class FixedExpenseModel extends HiveObject {
  @HiveField(0) String   id;
  @HiveField(1) String   categoryId;
  @HiveField(2) String   name;
  @HiveField(3) double   amount;
  @HiveField(4) bool     active;
  @HiveField(5) DateTime createdAt;
  @HiveField(6) int?     dueDayOfMonth;

  FixedExpenseModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.amount,
    this.active = true,
    required this.createdAt,
    this.dueDayOfMonth,
  });
}
