import 'package:hive/hive.dart';
part 'expense.g.dart';

@HiveType(typeId: 2)
class Expense extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String categoryId;
  @HiveField(2) String name;
  @HiveField(3) double amount;
  @HiveField(4) String date;      // "2025-04-18"
  @HiveField(5) String monthKey;  // "2025-04"
  @HiveField(6) bool isFixed;     // ثابت شهري
  @HiveField(7) DateTime createdAt;
  @HiveField(8) String? note;
  @HiveField(9) String? receiptPath;

  Expense({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.date,
    required this.monthKey,
    this.isFixed = false,
    required this.createdAt,
    this.note,
    this.receiptPath,
  });
}
