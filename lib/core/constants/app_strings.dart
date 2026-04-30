// ═══════════════════════════════════════════════════════════
// AppStrings — كل الرسائل والنصوص المركزية
// استخدم هذه الثوابت بدل hardcoding النصوص
// ═══════════════════════════════════════════════════════════

abstract final class AppStrings {
  // ── Errors ───────────────────────────────────────────────
  static const String networkError     = 'تعذّر الاتصال بالإنترنت — تحقق من الشبكة';
  static const String timeoutError     = 'انتهت مهلة الاتصال — حاول مرة أخرى';
  static const String unexpectedError  = 'حدث خطأ غير متوقع';
  static const String emptyMessage     = 'الرسالة فارغة';
  static const String apiKeyMissing    = 'مفتاح API غير مضبوط';
  static const String apiKeyInvalid    = 'مفتاح API غير صالح — تحقق من الإعدادات';
  static const String rateLimitError   = 'تم تجاوز حد الطلبات — انتظر دقيقة';
  static const String serverError      = 'خطأ في الخادم — حاول لاحقاً';
  static const String serviceUnavail   = 'الخدمة غير متاحة مؤقتاً';
  static const String emptyResponse    = 'استلمنا رداً فارغاً';
  static const String locationDisabled = 'GPS غير مفعّل على الجهاز';
  static const String permissionDenied = 'تم رفض إذن الموقع';
  static const String permDeniedForever= 'الإذن مرفوض بشكل دائم — افتح الإعدادات';
  static const String locationError    = 'خطأ في تحديد المكان';

  // ── Validation ────────────────────────────────────────────
  static const String fieldRequired    = 'هذا الحقل مطلوب';
  static const String invalidAmount    = 'أدخل رقماً صحيحاً';
  static const String negativeAmount   = 'لا يمكن أن يكون سالباً';
  static const String amountTooLarge   = 'الرقم كبير جداً';
  static const String nameTooShort     = 'الاسم قصير جداً';
  static const String nameTooLong      = 'الاسم طويل جداً';

  // ── Success ───────────────────────────────────────────────
  static const String expenseAdded     = '✅ تم تسجيل المصروف';
  static const String fixedAdded       = '✅ تمت الإضافة — سيتكرر كل شهر';
  static const String goalAdded        = '✅ تمت إضافة الهدف';
  static const String incomeSaved      = '✅ تم حفظ الدخل';
  static const String noSpendDay       = '✅ يوم بدون مصاريف — عمل رائع!';
  static const String keySaved         = '✅ تم حفظ المفتاح';

  // ── Confirmations ─────────────────────────────────────────
  static const String deleteExpense    = 'هل تريد حذف هذا المصروف؟';
  static const String deleteGoal       = 'هل تريد حذف هذا الهدف؟';
  static const String deleteData       = 'سيتم حذف جميع بياناتك نهائياً. لا يمكن التراجع.';
  static const String clearChat        = 'سيتم حذف سجل المحادثة كاملاً';

  // ── Labels ────────────────────────────────────────────────
  static const String confirm          = 'تأكيد';
  static const String cancel           = 'إلغاء';
  static const String delete           = 'حذف';
  static const String back             = 'رجوع';
  static const String save             = 'حفظ';
  static const String next             = 'التالي ←';
  static const String skip             = 'تخطى';
}
