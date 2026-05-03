import '../constants/app_strings.dart';

abstract final class Validators {
  static String? amount(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.amountRequired;
    final n = double.tryParse(v.trim());
    if (n == null) return AppStrings.amountInvalid;
    if (n <= 0)    return AppStrings.amountZero;
    if (n > 1e9)   return AppStrings.amountTooLarge;
    return null;
  }

  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? AppStrings.fieldRequired : null;

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.nameRequired;
    if (v.trim().length < 2)           return AppStrings.nameTooShort;
    if (v.trim().length > 50)          return AppStrings.nameTooLong;
    return null;
  }

  static String? positiveInt(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.positiveIntReq;
    final n = int.tryParse(v.trim());
    if (n == null || n <= 0)           return AppStrings.positiveIntReq;
    return null;
  }
}
