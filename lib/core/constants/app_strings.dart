// ═══════════════════════════════════════════════════════════
// AppStrings — Single source of truth for all user-facing text
// Usage: AppStrings.expenseAdded (never hardcode Arabic strings)
// ═══════════════════════════════════════════════════════════

abstract final class AppStrings {

  // ── Validation errors ──────────────────────────────────
  static const String amountRequired    = 'المبلغ مطلوب';
  static const String amountInvalid     = 'أدخل رقماً صحيحاً';
  static const String amountZero        = 'المبلغ يجب أن يكون أكبر من صفر';
  static const String amountNegative    = 'لا يمكن أن يكون سالباً';
  static const String amountTooLarge    = 'المبلغ كبير جداً';
  static const String amountInfinite    = 'قيمة غير صالحة';
  static const String fieldRequired     = 'هذا الحقل مطلوب';
  static const String categoryRequired  = 'الفئة مطلوبة';
  static const String nameTooShort      = 'يجب أن يكون أكثر من حرفين';
  static const String nameTooLong       = 'الاسم طويل جداً';
  static const String nameRequired      = 'الاسم مطلوب';
  static const String positiveIntReq    = 'أدخل عدداً صحيحاً موجباً';
  static const String dateInFuture      = 'لا يمكن تسجيل مصروف في المستقبل';
  static const String dateTooOld        = 'لا يمكن تسجيل مصروف قبل 90 يوماً';
  static const String targetRequired    = 'المبلغ المستهدف مطلوب';
  static const String targetTooSmall    = 'يجب أن يكون المستهدف أكبر من صفر';
  static const String savedExceedsTarget= 'المدخر لا يمكن أن يتجاوز الهدف';
  static const String monthlyTooHigh    = 'الادخار الشهري يتجاوز الهدف';
  static const String durationTooLong   = 'المدة أطول من 100 سنة';
  static const String goalNameRequired  = 'اسم الهدف مطلوب';
  static const String incomeNegative    = 'الدخل لا يمكن أن يكون سالباً';
  static const String apiKeyRequired    = 'أدخل المفتاح';
  static const String apiKeyInvalidFmt  = 'المفتاح يجب أن يبدأ بـ sk-ant-';

  // ── API / Network errors ───────────────────────────────
  static const String networkError      = 'تعذّر الاتصال بالإنترنت — تحقق من الشبكة';
  static const String timeoutError      = 'انتهت مهلة الاتصال — حاول مرة أخرى';
  static const String unexpectedError   = 'حدث خطأ غير متوقع';
  static const String emptyMessage      = 'الرسالة فارغة';
  static const String apiKeyMissing     = 'مفتاح API غير مضبوط';
  static const String apiKeyInvalid     = 'مفتاح API غير صالح — تحقق من الإعدادات';
  static const String rateLimitError    = 'تم تجاوز حد الطلبات — انتظر دقيقة';
  static const String serverError       = 'خطأ في الخادم — حاول لاحقاً';
  static const String serviceUnavail    = 'الخدمة غير متاحة مؤقتاً';
  static const String emptyResponse     = 'استلمنا رداً فارغاً';
  static const String unexpectedShape   = 'رد غير متوقع من الخادم';

  // ── Storage errors ─────────────────────────────────────
  static const String loadFailed        = 'تعذّر تحميل البيانات';
  static const String saveFailed        = 'تعذّر حفظ البيانات';
  static const String deleteFailed      = 'تعذّر حذف البيانات';
  static const String expenseLoadFailed = 'تعذّر تحميل المصاريف';
  static const String expenseInitFailed = 'تعذّر تهيئة المصاريف';

  // ── Location errors ────────────────────────────────────
  static const String locationDisabled  = 'GPS غير مفعّل على الجهاز';
  static const String permissionDenied  = 'تم رفض إذن الموقع';
  static const String permDeniedForever = 'الإذن مرفوض بشكل دائم — افتح الإعدادات';
  static const String locationError     = 'خطأ في تحديد المكان';
  static const String locationNotFound  = 'لم يتم تحديد المكان';
  static const String locationTimeout   = 'انتهت مهلة تحديد الموقع';

  // ── Success messages ───────────────────────────────────
  static const String expenseAdded     = '✅ تم تسجيل المصروف';
  static const String fixedAdded       = '✅ تمت الإضافة — سيتكرر كل شهر';
  static const String goalAdded        = '✅ تمت إضافة الهدف';
  static const String incomeSaved      = '✅ تم حفظ الدخل';
  static const String noSpendDay       = '✅ يوم بدون مصاريف — عمل رائع!';
  static const String keySaved         = '✅ تم حفظ المفتاح';
  static const String reportGenerated  = '✅ تم إنشاء التقرير';
  static const String savingAdded      = '✅ تمت إضافة المبلغ للهدف';

  // ── UI Labels ──────────────────────────────────────────
  static const String confirm           = 'تأكيد';
  static const String cancel            = 'إلغاء';
  static const String delete            = 'حذف';
  static const String back              = 'رجوع';
  static const String save              = 'حفظ';
  static const String add               = 'إضافة';
  static const String edit              = 'تعديل';
  static const String next              = 'التالي ←';
  static const String skip              = 'تخطى';
  static const String loading           = 'جاري التحميل...';

  // ── Confirmation prompts ───────────────────────────────
  static const String deleteExpenseQ   = 'هل تريد حذف هذا المصروف؟';
  static const String deleteGoalQ      = 'هل تريد حذف هذا الهدف؟';
  static const String deleteDataQ      = 'سيتم حذف جميع بياناتك نهائياً. لا يمكن التراجع.';
  static const String clearChatQ       = 'سيتم حذف سجل المحادثة كاملاً';

  // ── Goal type names ────────────────────────────────────
  static const String goalHome         = 'شراء منزل';
  static const String goalCar          = 'سيارة';
  static const String goalWedding      = 'زواج';
  static const String goalTravel       = 'سفر وإجازة';
  static const String goalEducation    = 'تعليم الأبناء';
  static const String goalEmergency    = 'صندوق طوارئ';
  static const String goalBusiness     = 'مشروع تجاري';
  static const String goalHajj         = 'حج وعمرة';
  static const String goalGold         = 'ذهب ومجوهرات';
  static const String goalOther        = 'أخرى';
}
