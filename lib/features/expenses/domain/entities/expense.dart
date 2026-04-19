// ═══════════════════════════════════════════════════════════
// Expense Entity — Pure Dart, no framework dependencies
// ═══════════════════════════════════════════════════════════

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

  Expense copyWith({
    String?   name,
    double?   amount,
    String?   date,
    String?   monthKey,
  }) => Expense(
    id:         id,
    categoryId: categoryId,
    name:       name       ?? this.name,
    amount:     amount     ?? this.amount,
    date:       date       ?? this.date,
    monthKey:   monthKey   ?? this.monthKey,
    createdAt:  createdAt,
  );

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
    this.active        = true,
    this.dueDayOfMonth,
  });

  @override
  List<Object?> get props => [id, categoryId, name, amount, active, dueDayOfMonth];
}
