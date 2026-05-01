// ═══════════════════════════════════════════════════════════
// ArabicParser — single source of truth for Arabic input parsing
// All Arabic digit normalization and number parsing goes here.
// ═══════════════════════════════════════════════════════════

import '../errors/result.dart';
import '../constants/app_strings.dart';

abstract final class ArabicParser {

  // ── Normalize Arabic/Persian digits to ASCII ───────────
  // ٠١٢٣٤٥٦٧٨٩ → 0123456789
  static String normalizeDigits(String input) => input
      .replaceAllMapped(
        RegExp(r'[٠-٩]'),
        (m) => (m.group(0)!.codeUnitAt(0) - 0x0660).toString(),
      )
      .replaceAll('٫', '.')   // Arabic decimal separator
      .replaceAll('،', '')    // Arabic thousands separator
      .replaceAll(',', '');   // Latin thousands separator

  // ── Parse amount string → validated double ─────────────
  static Result<double> parseAmount(
    String raw, {
    double max = 10000000,
    bool allowZero = false,
  }) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const Fail(ValidationFailure(AppStrings.amountRequired));

    final normalized = normalizeDigits(trimmed);
    final n = double.tryParse(normalized);

    if (n == null)            return const Fail(ValidationFailure(AppStrings.amountInvalid));
    if (n.isNaN || n.isInfinite) return const Fail(ValidationFailure(AppStrings.amountInfinite));
    if (!allowZero && n <= 0) return const Fail(ValidationFailure(AppStrings.amountZero));
    if (n < 0)                return const Fail(ValidationFailure(AppStrings.amountNegative));
    if (n > max)              return const Fail(ValidationFailure(AppStrings.amountTooLarge));

    return Success(n);
  }

  // ── Parse optional amount (empty = 0, not error) ───────
  static Result<double> parseOptionalAmount(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const Success(0.0);
    return parseAmount(raw, allowZero: true);
  }

  // ── Parse positive integer ─────────────────────────────
  static Result<int> parsePositiveInt(String raw) {
    final trimmed = normalizeDigits(raw.trim());
    final n = int.tryParse(trimmed);
    if (n == null || n <= 0) return const Fail(ValidationFailure(AppStrings.positiveIntReq));
    return Success(n);
  }
}
