// ═══════════════════════════════════════════════════════════
// Validators — Pure functions, return String? for Form
// ═══════════════════════════════════════════════════════════

abstract final class Validators {
  static String? amount(String? v) {
    if (v == null || v.trim().isEmpty) return 'المبلغ مطلوب';
    final n = double.tryParse(v.trim());
    if (n == null) return 'أدخل رقماً صحيحاً';
    if (n <= 0)    return 'يجب أن يكون المبلغ أكبر من صفر';
    if (n > 1e9)   return 'المبلغ كبير جداً';
    return null;
  }

  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'الاسم مطلوب';
    if (v.trim().length < 2)           return 'يجب أن يكون أكثر من حرفين';
    if (v.trim().length > 50)          return 'الاسم طويل جداً';
    return null;
  }

  static String? positiveInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'مطلوب';
    final n = int.tryParse(v.trim());
    if (n == null || n <= 0)           return 'أدخل عدداً صحيحاً موجباً';
    return null;
  }
}
