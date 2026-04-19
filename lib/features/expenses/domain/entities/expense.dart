import 'package:equatable/equatable.dart';

final class Expense extends Equatable {
  final String   id;
  final String   categoryId;
  final String   name;
  final double   amount;
  final String   date;       // "2025-04-18"
  final String   monthKey;   // "2025-04"
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.date,
    required this.monthKey,
    required this.createdAt,
  });

  bool get isValid => amount > 0 && categoryId.isNotEmpty && date.isNotEmpty;

  @override
  List<Object?> get props => [id, categoryId, name, amount, date, monthKey];
}

final class FixedExpense extends Equatable {
  final String   id;
  final String   categoryId;
  final String   name;
  final double   amount;
  final bool     active;
  final int?     dueDayOfMonth;

  const FixedExpense({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.amount,
    this.active = true,
    this.dueDayOfMonth,
  });

  /// Days until next payment — returns null if dueDayOfMonth not set
  int? daysUntilDue() {
    if (dueDayOfMonth == null) return null;
    final now  = DateTime.now();
    final due  = DateTime(now.year, now.month, dueDayOfMonth!);
    final next = due.isBefore(now)
        ? DateTime(now.year, now.month + 1, dueDayOfMonth!)
        : due;
    return next.difference(now).inDays;
  }

  @override
  List<Object?> get props => [id, categoryId, name, amount, active, dueDayOfMonth];
}
