// ═══════════════════════════════════════════════════════════
// SaveIncomeUseCase — ALL cases handled explicitly
// ═══════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../entities/income.dart';
import '../repositories/income_repository.dart';

final class SaveIncomeParams extends Equatable {
  final String monthKey;
  final String primaryRaw; // raw string from text field
  final String secondaryRaw;
  final String extraRaw;

  const SaveIncomeParams({
    required this.monthKey,
    required this.primaryRaw,
    this.secondaryRaw = '',
    this.extraRaw = '',
  });

  @override
  List<Object?> get props => [monthKey, primaryRaw, secondaryRaw, extraRaw];
}

final class SaveIncomeUseCase {
  final IncomeRepository _repo;
  SaveIncomeUseCase(this._repo);

  Future<Result<Income>> call(SaveIncomeParams p) async {
    // ── 1. Validate monthKey ─────────────────────────
    if (p.monthKey.isEmpty) {
      return const Fail(ValidationFailure('معرّف الشهر مطلوب'));
    }
    if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(p.monthKey)) {
      return const Fail(ValidationFailure('صيغة الشهر غير صحيحة'));
    }

    // ── 2. Parse amounts (edge: empty, letters, negative) ──
    final primary = _parseAmount(p.primaryRaw, 'الدخل الأساسي');
    final secondary = _parseAmount(p.secondaryRaw, 'دخل الشريك');
    final extra = _parseAmount(p.extraRaw, 'الدخل الإضافي');

    if (primary.isFailure) return Fail(primary.failureOrNull!);
    if (secondary.isFailure) return Fail(secondary.failureOrNull!);
    if (extra.isFailure) return Fail(extra.failureOrNull!);

    // ── 3. Business rules ─────────────────────────────
    final total =
        primary.valueOrNull! + secondary.valueOrNull! + extra.valueOrNull!;

    // Edge: all zeros — allowed (user might clear income)
    // Edge: unrealistically high income
    if (total > 10000000) {
      return const Fail(ValidationFailure(
          'إجمالي الدخل يبدو مرتفعاً جداً — تحقق من الأرقام'));
    }

    // ── 4. Build & save ───────────────────────────────
    final income = Income(
      monthKey: p.monthKey,
      primary: primary.valueOrNull!,
      secondary: secondary.valueOrNull!,
      extra: extra.valueOrNull!,
      updatedAt: DateTime.now(),
    );

    AppLogger.info(
        'SaveIncomeUseCase', 'Saving income for ${p.monthKey}: total=$total');
    final saveResult = await _repo.save(income);

    return saveResult.isSuccess
        ? Success(income)
        : Fail(saveResult.failureOrNull!);
  }

  /// Parse a raw string amount — handles all edge cases
  Result<double> _parseAmount(String raw, String fieldName) {
    // Edge: null-ish / whitespace only → treat as 0 (valid)
    if (raw.trim().isEmpty) return const Success(0.0);

    // Edge: Arabic numerals "١٢٣" → convert to Western
    final normalized = _normalizeDigits(raw.trim());

    // Edge: has letters or special chars
    final value = double.tryParse(normalized);
    if (value == null) {
      return Fail(ValidationFailure('$fieldName: أدخل رقماً صحيحاً'));
    }

    // Edge: negative number
    if (value < 0) {
      return Fail(ValidationFailure('$fieldName: لا يمكن أن يكون سالباً'));
    }

    // Edge: infinity / NaN (shouldn't happen after tryParse but just in case)
    if (value.isInfinite || value.isNaN) {
      return Fail(ValidationFailure('$fieldName: قيمة غير صالحة'));
    }

    return Success(value);
  }

  /// Convert Arabic-Indic digits to ASCII digits
  String _normalizeDigits(String s) => s
      .replaceAll('٠', '0')
      .replaceAll('١', '1')
      .replaceAll('٢', '2')
      .replaceAll('٣', '3')
      .replaceAll('٤', '4')
      .replaceAll('٥', '5')
      .replaceAll('٦', '6')
      .replaceAll('٧', '7')
      .replaceAll('٨', '8')
      .replaceAll('٩', '9')
      .replaceAll('٫', '.') // Arabic decimal separator
      .replaceAll(',', ''); // thousands separator
}
