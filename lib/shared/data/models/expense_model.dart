import 'package:hive/hive.dart';
part 'expense_model.g.dart';

@HiveType(typeId: 2)
class ExpenseModel extends HiveObject {
  @HiveField(0) String   id;
  @HiveField(1) String   categoryId;
  @HiveField(2) String   name;
  @HiveField(3) double   amount;
  @HiveField(4) String   date;
  @HiveField(5) String   monthKey;
  @HiveField(6) bool     isFixed;
  @HiveField(7) DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.date,
    required this.monthKey,
    this.isFixed   = false,
    required this.createdAt,
  });
}
