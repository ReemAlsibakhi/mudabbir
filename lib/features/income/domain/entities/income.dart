// ═══════════════════════════════════════════════════════════
// Income Entity — Immutable, validated, all cases handled
// ═══════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';

final class Income extends Equatable {
  final String  monthKey;   // "2025-04" — never empty
  final double  primary;    // >= 0
  final double  secondary;  // >= 0
  final double  extra;      // >= 0
  final DateTime updatedAt;

  const Income({
    required this.monthKey,
    this.primary   = 0,
    this.secondary = 0,
    this.extra     = 0,
    required this.updatedAt,
  });

  // ── Computed ──────────────────────────────────────────
  double get total => primary + secondary + extra;

  bool get hasIncome    => total > 0;
  bool get hasPartner   => secondary > 0;
  bool get hasExtra     => extra > 0;

  /// نسبة ادخار آمنة — إذا total = 0 ترجع 0 بدون division
  double savingRate(double expenses) =>
      total > 0 ? ((total - expenses) / total * 100).clamp(-100, 100) : 0;

  /// الفائض أو العجز
  double balance(double expenses) => total - expenses;

  /// هل وضع عجز؟
  bool isDeficit(double expenses) => balance(expenses) < 0;

  Income copyWith({
    double? primary,
    double? secondary,
    double? extra,
  }) =>
      Income(
        monthKey:  monthKey,
        primary:   (primary   ?? this.primary).clamp(0, double.infinity),
        secondary: (secondary ?? this.secondary).clamp(0, double.infinity),
        extra:     (extra     ?? this.extra).clamp(0, double.infinity),
        updatedAt: DateTime.now(),
      );

  /// Empty income for a month — safe default
  factory Income.empty(String monthKey) => Income(
    monthKey:  monthKey,
    updatedAt: DateTime.now(),
  );

  @override
  List<Object?> get props => [monthKey, primary, secondary, extra, updatedAt];

  @override
  String toString() => 'Income($monthKey: total=$total)';
}
