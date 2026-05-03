// ═══════════════════════════════════════════════════════════
// AppStrings — Single source of truth for ALL user-facing text
//
// RULE: Any string that appears in more than one file,
//       or represents user feedback (error/success/dialog),
//       MUST be defined here and imported from here.
//
// Exception: content-specific strings used exactly once
//            (e.g. persona descriptions, onboarding copy)
//            may stay inline.
// ═══════════════════════════════════════════════════════════

abstract final class AppStrings {

  // ── App identity ───────────────────────────────────────
  static const String appName           = 'مدبّر';
  static const String appTagline        = 'تطبيق المصروف العائلي العربي';

  // ══════════════════════════════════════════════════════
  // VALIDATION ERRORS
  // ══════════════════════════════════════════════════════

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
  static const String goalNameTooLong   = 'اسم الهدف طويل جداً (أقل من 60 حرفاً)';
  static const String incomeNegative    = 'الدخل لا يمكن أن يكون سالباً';
  static const String incomeTooHigh     = 'إجمالي الدخل يبدو مرتفعاً جداً — تحقق من الأرقام';
  static const String apiKeyRequired    = 'أدخل المفتاح';
  static const String apiKeyInvalidFmt  = 'المفتاح يجب أن يبدأ بـ sk-ant-';
  static const String monthKeyRequired  = 'معرّف الشهر مطلوب';
  static const String monthKeyInvalid   = 'صيغة الشهر غير صحيحة';

  // ══════════════════════════════════════════════════════
  // API / NETWORK ERRORS
  // ══════════════════════════════════════════════════════

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
  static const String genericError      = 'حدث خطأ';

  // ══════════════════════════════════════════════════════
  // STORAGE ERRORS
  // ══════════════════════════════════════════════════════

  static const String loadFailed        = 'تعذّر تحميل البيانات';
  static const String saveFailed        = 'تعذّر حفظ البيانات';
  static const String deleteFailed      = 'تعذّر حذف البيانات';
  static const String expenseLoadFailed = 'تعذّر تحميل المصاريف';
  static const String expenseDelFailed  = 'تعذّر حذف المصروف';
  static const String fixedDelFailed    = 'تعذّر حذف المصروف الثابت';
  static const String goalLoadFailed    = 'تعذّر تحميل الأهداف';
  static const String goalDelFailed     = 'تعذّر حذف الهدف';
  static const String incomeLoadFailed  = 'تعذّر تحميل بيانات الدخل';
  static const String incomeDataError   = 'خطأ في تحميل البيانات';
  static const String goalNotFound      = 'الهدف غير موجود';
  static const String goalAlreadyDone   = 'هذا الهدف مكتمل بالفعل';
  static const String idInvalid         = 'معرّف غير صالح';

  // ══════════════════════════════════════════════════════
  // LOCATION ERRORS
  // ══════════════════════════════════════════════════════

  static const String locationDisabled  = 'GPS غير مفعّل على الجهاز';
  static const String permissionDenied  = 'تم رفض إذن الموقع';
  static const String permDeniedForever = 'الإذن مرفوض بشكل دائم — افتح الإعدادات';
  static const String locationError     = 'خطأ في تحديد المكان';
  static const String locationNotFound  = 'لم يتم تحديد المكان';
  static const String locationTimeout   = 'انتهت مهلة تحديد الموقع';
  static const String locationUnknown   = 'موقع غير معروف';

  // ══════════════════════════════════════════════════════
  // SUCCESS MESSAGES (snackbars)
  // ══════════════════════════════════════════════════════

  static const String expenseAdded     = '✅ تم تسجيل المصروف';
  static const String fixedAdded       = '✅ تمت الإضافة — سيتكرر كل شهر';
  static const String goalAdded        = '✅ تمت إضافة الهدف';
  static const String incomeSaved      = '✅ تم حفظ الدخل';
  static const String noSpendDay       = '✅ يوم بدون مصاريف — عمل رائع!';
  static const String keySaved         = '✅ تم حفظ المفتاح';
  static const String reportGenerated  = '✅ تم إنشاء التقرير';
  static const String savingAdded      = '✅ تمت إضافة المبلغ للهدف';
  static const String copied           = 'تم النسخ';
  static const String dataSaved        = '✅ تم الحفظ';

  // ══════════════════════════════════════════════════════
  // COMMON UI LABELS
  // ══════════════════════════════════════════════════════

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
  static const String retry             = 'إعادة المحاولة';
  static const String close             = 'إغلاق';
  static const String today             = 'اليوم';
  static const String yesterday         = 'أمس';
  static const String saved             = 'محفوظ';

  // ══════════════════════════════════════════════════════
  // CONFIRMATION DIALOG CONTENT
  // ══════════════════════════════════════════════════════

  static const String deleteExpenseTitle = 'حذف المصروف';
  static const String deleteExpenseQ     = 'هل تريد حذف هذا المصروف؟';
  static const String deleteFixedTitle   = 'حذف الثابت';
  static const String deleteFixedQ       = 'هل تريد حذف هذا المصروف الثابت؟';
  static const String deleteGoalTitle    = 'حذف الهدف';
  static const String deleteGoalQ        = 'هل تريد حذف هذا الهدف؟';
  static const String deleteDataTitle    = 'حذف البيانات';
  static const String deleteDataQ        = 'سيتم حذف جميع بياناتك نهائياً. لا يمكن التراجع.';
  static const String clearChatTitle     = 'مسح المحادثة';
  static const String clearChatQ         = 'سيتم حذف سجل المحادثة كاملاً';
  static const String changeStageTitle   = 'تغيير مرحلة الحياة';

  // ══════════════════════════════════════════════════════
  // EMPTY STATES
  // ══════════════════════════════════════════════════════

  static const String noExpensesTitle   = 'لا توجد مصاريف هذا الشهر';
  static const String noExpensesBody    = 'اضغط + لإضافة مصروف جديد';
  static const String noFixedTitle      = 'لا توجد مصاريف ثابتة';
  static const String noFixedBody       = 'أضف إيجارك وفواتيرك لتتبعها تلقائياً كل شهر';
  static const String noGoalsTitle      = 'لا توجد أهداف بعد';
  static const String noGoalsBody       = 'أضف هدفك الأول وابدأ رحلة التوفير';
  static const String noGoalsBtn        = 'أضف هدفك الأول';
  static const String noCompareData     = 'لا توجد بيانات للمقارنة بعد';
  static const String noCompareBody     = 'سجّل مصاريف شهرين على الأقل';
  static const String noGoalReport      = 'لا توجد أهداف بعد';
  static const String noGoalReportBody  = 'أضف أهدافاً مالية لتتبع تقدمها هنا';
  static const String noDataMonth       = 'لا توجد بيانات لهذا الشهر';
  static const String noDataMonthBody   = 'ابدأ بإدخال دخلك ومصاريفك';
  static const String noTodayExpenses   = 'لم تسجل أي مصروف اليوم بعد';

  // ══════════════════════════════════════════════════════
  // NAV LABELS (bottom nav tabs)
  // ══════════════════════════════════════════════════════

  static const String navToday          = 'اليوم';
  static const String navExpenses       = 'مصروف';
  static const String navGoals          = 'أهداف';
  static const String navReports        = 'تقارير';

  // ══════════════════════════════════════════════════════
  // SCREEN TITLES
  // ══════════════════════════════════════════════════════

  static const String incomeTitle       = '💰 الدخل الشهري';
  static const String expensesTitle     = '💸 المصروف';
  static const String goalsTitle        = '🎯 الأهداف المالية';
  static const String reportsTitle      = '📈 التقارير';
  static const String settingsTitle     = '⚙️ الإعدادات';
  static const String chatTitle         = 'مستشارك المالي';
  static const String chatOnline        = 'Claude AI — جاهز';
  static const String apiKeyTitle       = 'مفتاح Claude API';
  static const String aiChatFree        = 'المستشار الذكي 🆓';

  // ══════════════════════════════════════════════════════
  // MONTH NAVIGATION (shared across Expenses, Income, Reports)
  // ══════════════════════════════════════════════════════

  static const String prevMonth         = 'الشهر السابق';
  static const String nextMonth         = 'الشهر التالي';

  // ══════════════════════════════════════════════════════
  // SETTINGS SCREEN
  // ══════════════════════════════════════════════════════

  static const String profile           = 'الملف الشخصي';
  static const String subscription      = 'الاشتراك';
  static const String notifications     = 'الإشعارات';
  static const String privacy           = 'الخصوصية والأمان';
  static const String countryChange     = '🌍 تغيير الدولة';
  static const String lifeStageLabel   = '👥 مرحلة الحياة';
  static const String premiumPlan       = '✅ مشترك — نسخة مميزة';
  static const String upgradeLabel      = 'ترقية للنسخة المميزة';
  static const String upgradeFeatures   = 'AI Chat + GPS + PDF + وضع الزوجين';
  static const String openChat          = 'فتح المستشار الذكي';
  static const String apiKeyReady       = '✅ مضبوط — المستشار جاهز للاستخدام';
  static const String apiKeyMissingHint = '⚠️ أدخل مفتاحك المجاني للبدء';
  static const String apiKeyNeeded      = 'يتطلب إدخال المفتاح أولاً';
  static const String deleteAllData     = '🗑️ حذف جميع البيانات';
  static const String morningNotif      = 'إشعار الصباح (9:00)';
  static const String morningNotifBody  = 'تذكير بتسجيل المصاريف';
  static const String eveningNotif      = 'ملخص المساء (9:00)';
  static const String eveningNotifBody  = 'مراجعة يومية سريعة';
  static const String privacyLocal      = '✅ بياناتك على هاتفك فقط';
  static const String privacyNoServer   = '✅ لا سيرفر، لا إنترنت مطلوب';
  static const String privacyNoAds      = '✅ لا إعلانات أبداً';
  static const String privacyDelete     = '✅ يمكنك حذف كل شيء في أي وقت';
  static const String aboutVersion      = 'الإصدار 2.0.0';
  static const String aboutCountries    = '22 دولة عربية · 4 مراحل حياة';

  // ══════════════════════════════════════════════════════
  // REPORTS SCREEN
  // ══════════════════════════════════════════════════════

  static const String tabMonthly        = 'شهري';
  static const String tabCompare        = 'مقارنة';
  static const String tabGoals          = 'الأهداف';
  static const String reportIncome      = 'الدخل';
  static const String reportExpense     = 'المصروف';
  static const String reportBalance     = 'الفائض';
  static const String reportDeficit     = 'العجز';
  static const String reportSavingRate  = 'نسبة الادخار';
  static const String reportPersona     = 'شخصيتكم هذا الشهر';
  static const String reportBreakdown   = 'تفصيل المصاريف';
  static const String reportThisMonth   = 'هذا الشهر';
  static const String reportFixedVar    = 'ثابت + متغير';
  static const String reportSavable     = 'قابل للادخار';
  static const String reportOverBudget  = 'تجاوزت الميزانية';
  static const String ratingExcellent   = 'ممتاز 🌟';
  static const String ratingGood        = 'جيد 👍';
  static const String ratingImprove     = 'يحتاج تحسين';
  static const String compareTitle      = 'مقارنة الأشهر';
  static const String compareSummary    = 'ملخص الفروق';
  static const String compareImproved   = 'تحسن 💚';
  static const String compareIncreased  = 'زيادة في الإنفاق';
  static const String last3Chart        = 'الإنفاق — آخر 3 أشهر';
  static const String compareFixed      = 'المصاريف الثابتة';
  static const String compareVariable   = 'المصاريف المتغيرة';
  static const String compareTotal      = 'إجمالي الإنفاق';
  static const String compareSaving     = 'الادخار';
  static const String goalsActive       = 'أهداف نشطة';
  static const String goalsDone         = 'مكتملة';
  static const String goalsTotalSaved   = 'إجمالي مدخر';
  static const String goalsOverall      = 'التقدم الكلي';
  static const String goalCompleted     = '✅ مكتمل';

  // ══════════════════════════════════════════════════════
  // EXPENSES SCREEN
  // ══════════════════════════════════════════════════════

  static const String tabFixed          = '📅 ثابت شهري';
  static const String tabVariable       = '📆 متغير يومي';
  static const String addFixed          = 'إضافة ثابت';
  static const String addExpense        = 'إضافة مصروف';
  static const String totalFixed        = 'ثابت';
  static const String totalVariable     = 'متغير';
  static const String totalExpenses     = 'الإجمالي';
  static const String fixedAutoRenew    = 'تلقائي كل شهر';
  static const String fixedTotal        = 'إجمالي الثابت الشهري';
  static const String addExpenseTitle   = '➕ إضافة مصروف';
  static const String addFixedTitle     = '📅 إضافة مصروف ثابت';
  static const String categoryLabel     = 'الفئة';
  static const String amountLabel       = 'المبلغ';
  static const String descOptional      = 'الوصف (اختياري)';
  static const String nameLabel         = 'الاسم';
  static const String dayLabel          = 'يوم الاستحقاق (اختياري)';
  static const String notSpecified      = 'غير محدد';
  static const String typeLabel         = 'النوع';
  static const String addFixedBtn       = 'إضافة — يتكرر كل شهر تلقائياً';

  // ══════════════════════════════════════════════════════
  // GOALS SCREEN
  // ══════════════════════════════════════════════════════

  static const String newGoal           = 'هدف جديد';
  static const String goalsCompleted    = '✅ مكتملة';
  static const String addGoalTitle      = '✨ إضافة الهدف';
  static const String goalNameLabel     = 'اسم الهدف';
  static const String goalTargetLabel   = 'المبلغ المستهدف';
  static const String goalSavedLabel    = 'مدخر حالياً (اختياري)';
  static const String goalDurationLabel = 'المدة المطلوبة';
  static const String goalMonthlyLabel  = 'مقدار الادخار الشهري';
  static const String chooseDuration    = 'حدد المدة';
  static const String chooseMonthly     = 'حدد الشهري';
  static const String goalSavingAdd     = 'إضافة مبلغ للادخار';
  static const String goalCelebration   = '🎉 تم تحقيق الهدف! مبروك!';
  static const String goalSummaryTotal  = 'إجمالي المدخر';
  static const String enterAmount       = 'أدخل مبلغاً';

  // ══════════════════════════════════════════════════════
  // DAILY SCREEN
  // ══════════════════════════════════════════════════════

  static const String addManually       = 'إضافة مصروف يدوياً';
  static const String noSpendBtn        = 'اليوم ما صرفت شيء';
  static const String todaySummary      = 'ملخص اليوم';
  static const String todayNoExpenses   = 'لم تسجل أي مصروف اليوم بعد';
  static const String todayTotal        = 'مجموع اليوم';
  static const String quickAdd          = 'إضافة سريعة';
  static const String aiAssistant       = 'المستشار الذكي';
  static const String incomeTooltip     = 'الدخل الشهري';
  static const String settingsTooltip   = 'الإعدادات';

  // ══════════════════════════════════════════════════════
  // INCOME SCREEN
  // ══════════════════════════════════════════════════════

  static const String incomeSaveBtn     = '💾 حفظ الدخل';
  static const String incomeSavedBtn    = '✅ محفوظ';
  static const String incomeUnsaved     = '⚠️ لديك تغييرات غير محفوظة';
  static const String incomeExtra       = '💼 دخل إضافي (مكافآت، عمل حر، إيجارات...)';
  static const String incomeTotalLabel  = 'إجمالي الدخل';
  static const String incomePrimLabel   = '👨 الدخل الأساسي';
  static const String incomePartLabel   = '👩 دخل الشريك';
  static const String incomeExtraLabel  = '💼 دخل إضافي';

  // ══════════════════════════════════════════════════════
  // BALANCE CARD
  // ══════════════════════════════════════════════════════

  static const String available         = 'المتاح هذا الشهر';
  static const String savingExcellent   = '% نسبة ادخار ممتازة';
  static const String savingGood        = 'نسبة ادخار جيدة %';
  static const String savingLow         = 'ادخر أكثر لتحسين نسبتك';
  static const String statIncome        = 'الدخل';
  static const String statExpense       = 'المصروف';
  static const String statSaving        = 'الادخار';

  // ══════════════════════════════════════════════════════
  // CHAT SCREEN
  // ══════════════════════════════════════════════════════

  static const String chatHeroTitle     = 'المستشار المالي الذكي';
  static const String chatHeroBody      = 'اسألني عن ميزانيتك، مصاريفك، أهدافك — وسأجيبك بناءً على بياناتك الحقيقية';
  static const String chatGetKey        = 'احصل على مفتاح API مجاني';
  static const String chatFreeNote      = 'مجاني تماماً — Anthropic تعطي رصيداً ابتدائياً مجاناً';
  static const String chatKeyPrivacy    = 'يُحفظ على هاتفك فقط — لا يُرفع لأي مكان';
  static const String chatStartTitle    = 'ابدأ المحادثة';
  static const String chatStartBody     = 'اسألني عن ميزانيتك، مصاريفك، أو أي قرار مالي';
  static const String chatInputHint     = 'اسأل عن ميزانيتك...';
  static const String chatChangeKey     = 'تغيير المفتاح';
  static const String chatClearTitle    = 'مسح المحادثة';
  static const String chatClearHistory  = 'مسح المحادثة';
  static const String chatDeleteBody    = 'سيتم حذف كل الرسائل';
  static const String chatSuggestions  = 'أسئلة مقترحة';
  static const String chatContextNA    = 'بيانات غير متاحة';

  // ══════════════════════════════════════════════════════
  // API KEY SETUP
  // ══════════════════════════════════════════════════════

  static const String apiKeyInputLabel  = 'أدخل مفتاح API';
  static const String apiKeyHowTitle    = 'كيف تحصل على المفتاح؟';
  static const String apiKeyStep1       = '١. افتح: console.anthropic.com';
  static const String apiKeyStep2       = '٢. سجّل دخول أو أنشئ حساباً';
  static const String apiKeyStep3       = '٣. API Keys ← Create Key';
  static const String apiKeyStep4       = '٤. انسخ المفتاح والصقه أدناه';
  static const String apiKeyUpdateBtn   = '💾 تحديث المفتاح';
  static const String apiKeySaveBtn     = '🔑 حفظ والبدء';
  static const String apiKeyDeleteBtn   = '🗑️ حذف المفتاح';

  // ══════════════════════════════════════════════════════
  // PAYWALL
  // ══════════════════════════════════════════════════════

  static const String paywallPrice      = '9.99 ريال';
  static const String paywallPeriod     = ' / شهر فقط';
  static const String paywallCta        = 'جرّب مجاناً لمدة 7 أيام';
  static const String paywallNotNow     = 'ليس الآن';
  static const String paywallAiChat     = 'مستشار Claude AI المالي الذكي';
  static const String paywallGps        = 'تنبيهات GPS عند دخول المحلات';
  static const String paywallPdf        = 'تصدير تقارير PDF احترافية';
  static const String paywallCouple     = 'وضع الزوجين — ميزانية مشتركة';
  static const String paywallTokens     = '3 رموز إنقاذ للسلسلة شهرياً';

  // ══════════════════════════════════════════════════════
  // ROUTER
  // ══════════════════════════════════════════════════════

  static const String navError          = 'خطأ في التنقل';
}
