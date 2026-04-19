// ═══════════════════════════════════════════════════
// Validators — form validation functions
// ═══════════════════════════════════════════════════

abstract final class Validators {
  static String? amount(String? v) {
    if (v == null || v.trim().isEmpty) return 'هذا الحقل مطلوب';
    final n = double.tryParse(v.trim());
    if (n == null) return 'أدخل رقماً صحيحاً';
    if (n <= 0)    return 'يجب أن يكون المبلغ أكبر من صفر';
    return null;
  }

  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'هذا الحقل مطلوب';
    if (v.trim().length < 2)           return 'يجب أن يكون أكثر من حرفين';
    return null;
  }
}
