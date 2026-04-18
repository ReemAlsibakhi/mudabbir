class Validators {
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
    final num = double.tryParse(value);
    if (num == null) return 'أدخل رقماً صحيحاً';
    if (num <= 0) return 'يجب أن يكون المبلغ أكبر من صفر';
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
    if (value.length < 2) return 'يجب أن يكون أكثر من حرفين';
    return null;
  }

  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
    return null;
  }
}
