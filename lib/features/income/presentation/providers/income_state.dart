// ═══════════════════════════════════════════════════════════
// IncomeState — All UI states represented
// ═══════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import '../../domain/entities/income.dart';

sealed class IncomeState extends Equatable {
  const IncomeState();
  @override List<Object?> get props => [];
}

/// Initial / Loading
final class IncomeLoading extends IncomeState {
  const IncomeLoading();
}

/// Data loaded successfully
final class IncomeLoaded extends IncomeState {
  final Income   income;
  final bool     isSaving;
  final String?  saveError;    // null = no error
  final bool     saveSuccess;  // true = just saved

  const IncomeLoaded({
    required this.income,
    this.isSaving    = false,
    this.saveError,
    this.saveSuccess = false,
  });

  bool get hasIncome  => income.hasIncome;
  bool get hasError   => saveError != null;

  IncomeLoaded copyWith({
    Income?  income,
    bool?    isSaving,
    String?  saveError,
    bool?    saveSuccess,
    bool     clearError = false,
  }) =>
      IncomeLoaded(
        income:       income       ?? this.income,
        isSaving:     isSaving     ?? this.isSaving,
        saveError:    clearError   ? null : saveError ?? this.saveError,
        saveSuccess:  saveSuccess  ?? this.saveSuccess,
      );

  @override
  List<Object?> get props => [income, isSaving, saveError, saveSuccess];
}

/// Fatal error (box not open, etc.)
final class IncomeError extends IncomeState {
  final String message;
  const IncomeError(this.message);
  @override List<Object?> get props => [message];
}
