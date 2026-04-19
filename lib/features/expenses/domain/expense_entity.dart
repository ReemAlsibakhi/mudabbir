class ExpenseEntity {
  final String id;
  final String categoryId;
  final String name;
  final double amount;
  final String date;
  final String monthKey;
  final bool   isFixed;
  final DateTime createdAt;

  const ExpenseEntity({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.date,
    required this.monthKey,
    this.isFixed = false,
    required this.createdAt,
  });
}

class FixedExpenseEntity {
  final String id;
  final String categoryId;
  final String name;
  final double amount;
  final bool   active;
  final int?   dueDayOfMonth;

  const FixedExpenseEntity({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.amount,
    this.active = true,
    this.dueDayOfMonth,
  });
}
