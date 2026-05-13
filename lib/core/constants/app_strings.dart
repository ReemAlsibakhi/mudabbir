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

  // ══════════════════════════════════════════════════════
  // GOAL TYPE NAMES (GoalType.nameAr)
  // ══════════════════════════════════════════════════════

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

  // ══════════════════════════════════════════════════════
  // SETTINGS — additional labels
  // ══════════════════════════════════════════════════════

  static const String currencyLabel    = '💱 العملة';
  static const String premiumTitle     = 'النسخة المميزة';
  static const String upgradeDesc      = 'احصل على كل الميزات بـ 9.99 ريال/شهر';
  static const String activeSubLabel   = 'اشتراك نشط';
  static const String aboutSection     = 'عن مدبّر';
  static const String openSource       = 'مفتوح المصدر — github.com/ReemAlsibakhi/mudabbir';
  static const String badgePremium     = '👑 مميز';
  static const String badgeFree        = '🆓 مجاني';


  // ══════════════════════════════════════════════════════
  // BOOTSTRAP
  // ══════════════════════════════════════════════════════
  static const String appInitializing   = 'Initializing مدبّر...';

  // ══════════════════════════════════════════════════════
  // STREAK / DAILY ENTITY
  // ══════════════════════════════════════════════════════
  static const String streakStart       = 'ابدأ سلسلتك اليوم!';
  static const String streakBest        = 'أنت من أفضل المستخدمين 🌟';
  static const String badgeLegendary    = '🏆 أسطوري';
  static const String badgeExcellent    = '⭐ متميز';
  static const String streakDaysSuffix  = 'يوم متواصل';

  // ══════════════════════════════════════════════════════
  // BALANCE CARD
  // ══════════════════════════════════════════════════════
  static const String balanceAvailable  = 'المتاح هذا الشهر';
  static const String savingRateLow     = 'ادخر أكثر لتحسين نسبتك';

  // ══════════════════════════════════════════════════════
  // DAILY HEADER GREETINGS
  // ══════════════════════════════════════════════════════
  static const String greetingMorning   = 'صباح الخير';
  static const String greetingNoon      = 'مرحباً';
  static const String greetingEvening   = 'مساء الخير';
  static const String dailySubtitle     = 'سجّل مصاريفك في 30 ثانية 👇';

  // ══════════════════════════════════════════════════════
  // QUICK ADD GRID
  // ══════════════════════════════════════════════════════
  static const String descOptHint       = 'وصف (اختياري)';
  static const String andConnector      = 'و';

  // ══════════════════════════════════════════════════════
  // ADD EXPENSE SHEET
  // ══════════════════════════════════════════════════════
  static const String addExpenseTitle2  = '➕ إضافة مصروف';
  static const String descExample       = 'مثال: بقالة الخميس';

  // ══════════════════════════════════════════════════════
  // ADD FIXED EXPENSE SHEET
  // ══════════════════════════════════════════════════════
  static const String fixedAmountMonthly= 'المبلغ الشهري';
  static const String fixedNameExample  = 'مثال: إيجار الشقة';
  static const String fixedDayOptional  = 'يوم الاستحقاق (اختياري)';
  static const String fixedAddBtn       = 'إضافة — يتكرر كل شهر تلقائياً';

  // ══════════════════════════════════════════════════════
  // GOALS — ADD GOAL SHEET
  // ══════════════════════════════════════════════════════
  static const String goalSingle        = '✨ ابدأ مشوار الثروة';
  static const String goalEngaged       = '💍 وفّر لحلمكم';
  static const String goalMarried       = '🏡 أهداف أسرتكم';
  static const String goalFamily        = '👨‍👩‍👧‍👦 مستقبل أطفالكم';
  static const String goalChooseDur     = 'حدد المدة';
  static const String goalChooseMon     = 'حدد الشهري';
  static const String yearLabel         = 'سنة';
  static const String twoYearsLabel     = 'سنتان';

  // ══════════════════════════════════════════════════════
  // GOAL COMPLETION OVERLAY
  // ══════════════════════════════════════════════════════
  static const String congrats          = 'تهانينا! 🎉';
  static const String congratsBtn       = 'رائع! شكراً 🚀';

  // ══════════════════════════════════════════════════════
  // INCOME FORM
  // ══════════════════════════════════════════════════════
  static const String incomePrimSingle  = '👨 راتبك الشهري';
  static const String incomeHusbandRole = '👨 دخل الزوج (رب الأسرة)';
  static const String incomeWifeOpt     = '👩 دخل الزوجة (اختياري)';
  static const String incomeTipSingle   = '💡 نصيحة للأعزب: وفّر 30% الآن قبل الالتزامات';
  static const String incomeTipEngaged  = '💡 نصيحة للمخطوب: ابدأ صندوق الزفاف — الأيام تمر سريعاً';
  static const String incomeTipMarried  = '💡 نصيحة للمتزوجين: اتفقا على ميزانية مشتركة كل بداية شهر';
  static const String incomeTipFamily   = '💡 نصيحة للأسرة: صندوق طوارئ 6 أشهر = أولوية قصوى';
  static const String incomeInputLabel  = 'إدخال الدخل الشهري';
  static const String incomeExample     = 'مثال: 8000';
  static const String incomeExtraFull   = '💼 دخل إضافي (مكافآت، عمل حر، إيجارات...)';

  // ══════════════════════════════════════════════════════
  // INCOME SAVINGS TIP
  // ══════════════════════════════════════════════════════
  static const String savingsTip20      = '💡 لو وفّرت 20% من دخلك = ';

  // ══════════════════════════════════════════════════════
  // LOCATION ALERT (static parts)
  // ══════════════════════════════════════════════════════
  static const String alertPharmacy     = 'في صيدلية — تريد تسجيل مصروف صحة؟';
  static const String alertFuel         = 'عند محطة وقود — تريد تسجيل مصروف وقود؟';

  // ══════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ══════════════════════════════════════════════════════
  static const String notifDefaultName  = 'صديقي';
  static const String notifAppMorning   = 'مدبّر 💰';
  static const String notifAppEvening   = 'مدبّر 🌙';
  static const String notifMorningChan  = 'إشعار الصباح';
  static const String notifEveningChan  = 'ملخص المساء';
  static const String notifBudgetTitle  = '⚠️ تنبيه ميزانية';
  static const String notifBudgetChan   = 'تنبيهات الميزانية';
  static const String notifStreakTitle   = '🔥 سلسلتك في خطر!';
  static const String notifStreakChan    = 'تنبيه السلسلة';
  static const String notifDueTitle     = '📅 موعد سداد قادم';
  static const String notifDueChan      = 'مواعيد السداد';

  // ══════════════════════════════════════════════════════
  // ONBOARDING PROFILE — life stage data
  // ══════════════════════════════════════════════════════
  static const String stageSingle       = 'أعزب';
  static const String stageEngaged      = 'مخطوب';
  static const String stageMarried      = 'متزوج';
  static const String stageFamily       = 'أسرة مع أطفال';
  static const String stageMottoSingle  = 'تحكم بمستقبلك المالي';
  static const String stageMottoEngaged = 'وفّر لحلمك الكبير';
  static const String stageMottoMarried = 'نسّق مع شريك حياتك';
  static const String stageMottoFamily  = 'أدر مصاريف أسرتك';
  static const String incomeLabelSingle = 'راتبك الشهري';
  static const String incomeLabelHusb   = 'دخل الزوج';

  // ══════════════════════════════════════════════════════
  // ONBOARDING FLOW — step names
  // ══════════════════════════════════════════════════════
  static const String stepCountry       = 'الدولة';
  static const String stepStage         = 'مرحلة الحياة';
  static const String stepName          = 'الاسم';
  static const String stepIncome        = 'الدخل';

  // ══════════════════════════════════════════════════════
  // ONBOARDING WIDGETS
  // ══════════════════════════════════════════════════════
  static const String countryTitle      = '🌍 من أي دولة أنت؟';
  static const String countrySubtitle   = 'سنضبط العملة والإعدادات تلقائياً';
  static const String stageTitle        = '👤 ما وضعك الحالي؟';
  static const String stageSubtitle     = 'سنخصص التطبيق بالكامل لاحتياجاتك';
  static const String nameTitle         = '👋 ما اسمك؟';
  static const String nameSubtitle      = 'سنناديك به في كل رسائل مدبّر';
  static const String nameExample       = 'مثال: خالد أو نورة';
  static const String nextArrow         = 'التالي ←';
  static const String nextArrowRtl      = 'التالي →';
  static const String startNow          = 'ابدأ الآن 🚀';
  static const String skipNow           = 'تخطى الآن — سأضيفه لاحقاً';
  static const String incomeTitle2      = '💰 ما دخلك الشهري؟';
  static const String incomeSubtitle    = 'سنوزع ميزانيتك تلقائياً — يمكنك تعديلها لاحقاً';
  static const String wifeIncomeOpt     = 'دخل الزوجة (اختياري)';
  static const String extraIncomeOpt    = 'دخل إضافي (مكافآت، إيجارات...)';
  static const String totalMonthlyLabel = 'إجمالي الدخل الشهري';
  static const String savingGoal20      = 'هدف الادخار الموصى به (20%) = ';
  static const String startWithApp      = '🚀 ابدأ مع مدبّر';

  // ══════════════════════════════════════════════════════
  // MONTHLY REPORT — persona names & advice
  // ══════════════════════════════════════════════════════
  static const String personaSingle1    = 'الأعزب المنضبط';
  static const String personaSingle2    = 'الأعزب المتعلم';
  static const String personaEngaged1   = 'المخطوب الذكي';
  static const String personaEngaged2   = 'المخطوب المستعجل';
  static const String personaMarried1   = 'الزوجان المثاليان';
  static const String personaMarried2   = 'الزوجان المتحسّنان';
  static const String personaFamily1    = 'الأسرة البطلة';
  static const String personaFamily2    = 'الأسرة المتقدمة';
  static const String personaDefault    = 'المالي الذكي';
  static const String adviceFamily      = 'الأسرة تحتاج مراجعة. ابدأ بالمصاريف الثابتة الكبيرة أولاً.';
  static const String adviceMarried     = 'اتفقا على خفض بند واحد هذا الشهر — ابدأا بالمطاعم.';
  static const String adviceEngaged     = 'انتبه — الزواج يحتاج ميزانية وفائض، ليس عجزاً.';
  static const String adviceSingle      = 'وضع صعب. راجع أكبر 3 مصاريف وقلّلها الشهر القادم.';
  static const String adviceFamily2     = 'أداء جيد للأسرة. صندوق طوارئ 6 أشهر = الأولوية القصوى الآن.';
  static const String adviceMarried2    = 'وضع معقول. جرّبا تحديد سقف أسبوعي للمصاريف اليومية معاً.';
  static const String adviceEngaged2    = 'ادخروا أكثر — حفل الزفاف والشقة يحتاجان جيباً عميقاً.';
  static const String adviceSingle2     = 'يمكنك أفضل من هذا. هدف بسيط: وفّر 500 ريال إضافية الشهر القادم.';

  // ══════════════════════════════════════════════════════
  // PDF REPORT LABELS
  // ══════════════════════════════════════════════════════
  static const String pdfTitle          = 'تقرير مدبّر المالي';
  static const String pdfAppFooter      = 'مدبّر — تطبيق المصروف العائلي العربي';
  static const String pdfSummaryHeader  = '── الملخص ──────────────────────────';
  static const String pdfPersonaHeader  = '── الشخصية المالية ─────────────────';
  static const String pdfBreakHeader    = '── تفصيل المصاريف ──────────────────';
  static const String pdfGoalsHeader    = '── الأهداف ─────────────────────────';
  static const String pdfDetailLabel    = 'التفصيل:';



  // ══════════════════════════════════════════════════════
  // CHAT SUGGESTED QUESTIONS (per life stage)
  // ══════════════════════════════════════════════════════
  static const String q1Single    = 'كيف أوزع راتبي بذكاء؟';
  static const String q2Single    = 'كم أحتاج في صندوق الطوارئ؟';
  static const String q3Single    = 'ما أفضل هدف ادخار لي الآن؟';
  static const String q1Engaged   = 'كيف نخطط لميزانية الزفاف؟';
  static const String q2Engaged   = 'كيف نبدأ حياتنا المالية صح؟';
  static const String q3Engaged   = 'كم نحتاج قبل الزواج؟';
  static const String q1Married   = 'كيف نوزع الدخل المشترك؟';
  static const String q2Married   = 'هل وضعنا المالي جيد هذا الشهر؟';
  static const String q3Married   = 'كيف نوفر أكثر كزوجين؟';
  static const String q1Family    = 'كيف نوفر لتعليم الأطفال؟';
  static const String q2Family    = 'هل ميزانية الأسرة متوازنة؟';
  static const String q3Family    = 'ما المبلغ الكافي لصندوق الطوارئ؟';

  // ══════════════════════════════════════════════════════
  // CHAT SCREEN — API key steps (Latin numerals version)
  // ══════════════════════════════════════════════════════

  static const String chatApiStep2     = '2. أنشئ حساباً مجانياً';

  // ══════════════════════════════════════════════════════
  // BALANCE CARD — currency fallback
  // ══════════════════════════════════════════════════════

  static const String defaultCurrency  = 'ريال';

  // ══════════════════════════════════════════════════════
  // PROMO SLIDE — onboarding content
  // ══════════════════════════════════════════════════════

  static const String promoDesc1       = 'مدبّر يساعدك تتحكم في مصاريف أسرتك بذكاء — 30 ثانية يومياً فقط';
  static const String promoDesc2       = 'منزل، سيارة، إجازة — مدبّر يحسب كم تحتاج توفير كل شهر';
  static const String promoDesc3       = 'لا سيرفر، لا إنترنت، لا أحد يراها. بياناتك ملكك فقط.';

  // ══════════════════════════════════════════════════════
  // INCOME FORM — life stage specific labels
  // ══════════════════════════════════════════════════════

  static const String incomeHusbandMarried = '👨 دخل الزوج';

  // ══════════════════════════════════════════════════════
  // ADD GOAL SHEET — contextual hints per type+stage
  // ══════════════════════════════════════════════════════

  static const String hintHomeFamily   = 'بيت واسع للأسرة';
  static const String hintHomeSingle   = 'شقتي الأولى';
  static const String hintWeddingFull  = 'حفل الزفاف والشبكة';
  static const String hintWeddingSmall = 'حفل زواج';
  static const String hintEduFamily    = 'تعليم الأبناء الجامعي';
  static const String hintEduSelf      = 'دراستي';
  static const String hintEmgFamily    = 'صندوق طوارئ الأسرة (6 أشهر)';
  static const String hintEmgSingle    = 'صندوق الطوارئ';
  static const String hintCar          = 'سيارة العائلة';
  static const String hintTravel       = 'رحلة إجازة';
  static const String hintHajj         = 'حج أو عمرة';
  static const String hintBusiness     = 'مشروعي التجاري';
  static const String hintGold         = 'ذهب وادخار';
  static const String hintOther        = 'هدف مخصص';

  // ══════════════════════════════════════════════════════
  // LOCATION — place detection keywords
  // (used for contains() matching — not UI display)
  // ══════════════════════════════════════════════════════

  static const String placeKwLulu      = 'لولو';
  static const String placeKwGrocery   = 'بقالة';
  static const String placeKwRestaurant= 'مطعم';
  static const String placeKwCafe      = 'كافيه';
  static const String placeKwMall      = 'مول';
  static const String placeKwPharmacy  = 'صيدلية';
  static const String placeKwNahdi     = 'النهدي';
  static const String placeKwGasStation= 'محطة';

  // ══════════════════════════════════════════════════════
  // PROMO SLIDE — titles
  // ══════════════════════════════════════════════════════

  static const String promoTitle1      = 'تعرّف أين يذهب\nراتبك كل شهر';
  static const String promoTitle2      = 'حقق أهدافك\nالمالية أسرع';
  static const String promoTitle3      = 'بياناتك خاصة\n100%% على هاتفك';

  // ── Fixed expense list ─────────────────────────────────
  static const String due           = 'بعد';
  static const String days          = 'أيام';
  static const String countryLabel  = '🌍 الدولة';

  // ══════════════════════════════════════════════════════
  // TIME UNITS (used in dynamic strings)
  // ══════════════════════════════════════════════════════

  static const String monthly           = 'شهرياً';
  static const String yearly            = 'سنوياً! 🎯';
  static const String months            = 'شهر';
  static const String monthsAr         = 'أشهر';
  static const String monthSuffix      = 'شهراً';
  static const String years            = 'سنوات';
  static const String year             = 'سنة';
  static const String oneYear          = 'سنة واحدة';
  static const String twoYears         = 'سنتان';

  // ══════════════════════════════════════════════════════
  // INCOME SCREEN — missing
  // ══════════════════════════════════════════════════════

  static const String incomeHintPrefix  = 'مثال: 8000';

  // ══════════════════════════════════════════════════════
  // GOAL CARD — dynamic templates (Arabic part only)
  // ══════════════════════════════════════════════════════

  static const String goalInsightRemaining  = '💡 المتبقي: ';
  static const String goalInsightAtRate     = ' · ';
  static const String goalInsightMonthsRate = ' شهر بمعدلك';
  static const String goalInsightFasterPre  = '⚡ بادخار ';
  static const String goalInsightFasterMid  = '/شهر → ';
  static const String goalInsightFasterSuf  = ' شهر فقط';
  static const String goalDeleteConfirmPre  = 'هل تريد حذف هدف "';
  static const String goalDeleteConfirmSuf  = '"؟';
  static const String goalNeedMonthlyPre    = 'تحتاج ';
  static const String goalNeedMonthlySuf    = ' شهرياً خلال ';
  static const String goalNeedMonthlySuf2   = ' شهر';
  static const String goalReachPre          = 'ستصل للهدف في ';
  static const String goalReachMid          = ' شهر (';
  static const String goalReachSuf          = ' سنة)';
  static const String goalCelebPre          = 'لقد حققت هدف\n"';
  static const String goalCelebSuf          = '"\nبنجاح! 🏆';
  static const String goalSaved            = ' مدخر';
  static const String goalFrom             = 'من ';
  static const String goalProgressSuf      = '% من إجمالي الأهداف';
  static const String goalMonthsLeft       = '💡 بمعدلك الحالي: ';
  static const String goalMonthsLeftSuf    = ' شهر للوصول للهدف';

  // ══════════════════════════════════════════════════════
  // GOALS SUMMARY — dynamic
  // ══════════════════════════════════════════════════════

  static const String goalActiveCount      = ' نشط · ';
  static const String goalDoneCount        = ' مكتمل';

  // ══════════════════════════════════════════════════════
  // FIXED EXPENSE LIST — dynamic
  // ══════════════════════════════════════════════════════

  static const String autoMonthly          = ' · تلقائي كل شهر';
  static const String dayPrefix            = 'اليوم ';

  // ══════════════════════════════════════════════════════
  // BALANCE CARD — dynamic saving rate
  // ══════════════════════════════════════════════════════

  static const String savingExcellentSuf   = '% نسبة ادخار ممتازة';
  static const String savingGoodPre        = 'نسبة ادخار جيدة ';
  static const String savingRateLow        = 'ادخر أكثر لتحسين نسبتك';

  // ══════════════════════════════════════════════════════
  // NOTIFICATIONS — dynamic templates
  // ══════════════════════════════════════════════════════

  static const String notifMorningPre      = 'صباح الخير يا ';
  static const String notifMorningSuf      = '! المتاح اليوم: ';
  static const String notifEvening         = 'كيف كان يومك يا ';
  static const String notifEveningSuf      = '؟ سجّل مصاريفك الآن في 30 ثانية';
  static const String notifBudgetPre       = 'استنفدت ';
  static const String notifBudgetMid       = '% من ميزانية ';
  static const String notifStreakPre        = 'لا تكسر سلسلتك الـ ';
  static const String notifStreakSuf        = ' يوم! سجّل في 30 ثانية';
  static const String notifFixedPre        = '';
  static const String notifFixedSuf        = ' موعده بعد 3 أيام';

  // ══════════════════════════════════════════════════════
  // STREAK — dynamic
  // ══════════════════════════════════════════════════════

  static const String streakDaysSuf        = ' أيام متواصلة 💪';
  static const String streakLegendPre      = 'أسطوري! ';
  static const String streakLegendSuf      = ' يوم بدون انقطاع 🏆';

  // ══════════════════════════════════════════════════════
  // LOCATION ALERTS — dynamic (placeName is runtime)
  // ══════════════════════════════════════════════════════

  static const String alertSuperPre        = 'دخلت ';
  static const String alertSuperSuf        = ' — تريد تسجيل مصروف بقالة؟';
  static const String alertRestPre         = 'أنت في ';
  static const String alertRestSuf         = ' — تريد تسجيل وجبة؟';
  static const String alertMallPre         = 'دخلت ';
  static const String alertMallSuf         = ' — انتبه من التسوق الزائد!';

  // ══════════════════════════════════════════════════════
  // ONBOARDING — dynamic
  // ══════════════════════════════════════════════════════

  static const String onboardingStepPre    = 'خطوة ';
  static const String onboardingStepMid    = ' من ';

  // ══════════════════════════════════════════════════════
  // REPORTS — dynamic
  // ══════════════════════════════════════════════════════

  static const String compareMonthPre      = 'مقارنة ';
  static const String compareMonthMid      = ' بـ ';
  static const String reportDeficitMsg     = '⚠️ عجز مالي بمقدار ';
  static const String reportDeficitSuf     = '. راجعوا المصاريف معاً.';
  static const String reportSavingMsg      = '💡 نسبة الادخار ';
  static const String reportSavingMid      = '%. الهدف 20% — واصلوا!';
  static const String reportExcellentPre   = '✨ وضع ممتاز! تدخرون ';
  static const String reportExcellentSuf   = ' هذا الشهر. واصلوا!';

  // ══════════════════════════════════════════════════════
  // PAYWALL — dynamic
  // ══════════════════════════════════════════════════════

  static const String paywallFeatureSuf    = ' — للمشتركين فقط';

  // ══════════════════════════════════════════════════════
  // QUICK ADD — dynamic
  // ══════════════════════════════════════════════════════

  static const String quickAddSuccessPre   = '✅ تم تسجيل ';
  static const String quickAddSuccessSuf   = ' ريال';

  // ══════════════════════════════════════════════════════
  // SETTINGS — dynamic
  // ══════════════════════════════════════════════════════

  static const String subExpiresPre        = 'ينتهي في ';

  // ══════════════════════════════════════════════════════
  // DAILY HEADER — dynamic greeting
  // ══════════════════════════════════════════════════════

  static const String greetingSuf          = '، ';

  // ══════════════════════════════════════════════════════
  // AI CHAT CONTEXT — dynamic labels (not UI, system prompt)
  // These stay inline — they're API prompts not UI text
  // ══════════════════════════════════════════════════════

  // ══════════════════════════════════════════════════════
  // PDF / EXPORT — dynamic report labels
  // ══════════════════════════════════════════════════════

  static const String pdfNameLabel         = 'الاسم:    ';
  static const String pdfMonthLabel        = 'الشهر:    ';
  static const String pdfCurrencyLabel     = 'العملة:   ';
  static const String pdfIncomeLabel       = 'الدخل:              ';
  static const String pdfFixedLabel        = 'المصاريف الثابتة:   ';
  static const String pdfVariableLabel     = 'المصاريف المتغيرة:  ';
  static const String pdfTotalLabel        = 'الإجمالي:           ';
  static const String pdfBalanceLabel      = 'الفائض:             ';
  static const String pdfSavingLabel       = 'نسبة الادخار:       ';
  static const String pdfSavedLabel        = ' مدخر';
  static const String pdfFromTarget        = ' مدخر من ';
  static const String expenseInitError    = 'تعذّر تهيئة المصاريف: ';
  static const String goalInitError      = 'خطأ في تهيئة الأهداف: ';
  static const String incomeInitError    = 'تعذّر تهيئة الدخل: ';

  // ══════════════════════════════════════════════════════
  // PERSONA DESCRIPTIONS — high savers (savingRate >= 20)
  // ══════════════════════════════════════════════════════

  static const String personaHighFamily   = 'أسرتكم من أفضل 10% في إدارة الميزانية! الأطفال محظوظون.';
  static const String personaHighMarried  = 'زوجان يتفاهمان — انضباطكم المالي مثال يُحتذى به.';
  static const String personaHighEngaged  = 'ممتاز! تبدأ حياتكم بأفضل أساس مالي ممكن.';
  static const String personaHighSingle   = 'انضباط استثنائي! وفّر الآن واستثمر — الوقت في صالحك.';

  // ══════════════════════════════════════════════════════
  // REPORT INSIGHT MESSAGES — dynamic (balance/rate from runtime)
  // ══════════════════════════════════════════════════════

  static const String reportDeficitPre    = '⚠️ عجز مالي بمقدار ';
  static const String reportDeficitSuf2   = '. راجعوا المصاريف وقللوا البنود غير الضرورية فوراً.';
  static const String reportLowSavePre    = '💡 نسبة الادخار ';
  static const String reportLowSaveMid    = '%. الهدف 20% = ';
  static const String reportLowSaveSuf    = ' شهرياً.';

  // ══════════════════════════════════════════════════════
  // WEDDING GOAL — engaged scenario
  // ══════════════════════════════════════════════════════

  static const String weddingDateLabel    = '📅 تاريخ الزواج';
  static const String weddingDateHint     = 'اختر تاريخ الزواج';
  static const String weddingMonthsLeft   = 'أشهر متبقية للزواج';
  static const String weddingBudgetTitle  = '💍 تفصيل تكاليف الزواج';
  static const String weddingMahr         = '💍 المهر';
  static const String weddingShebka       = '💎 الشبكة والمصاغ';
  static const String weddingHall         = '🏛️ قاعة الأفراح';
  static const String weddingHoneymoon    = '✈️ شهر العسل';
  static const String weddingApartment    = '🏠 الشقة';
  static const String weddingFurniture    = '🛋️ الأثاث';
  static const String weddingTotal        = 'إجمالي تكاليف الزواج';
  static const String weddingNeedPerMonth = '💡 تحتاج توفير ';
  static const String weddingPerMonthSuf  = ' شهرياً للوصول لهدفك';
  static const String weddingBehindPre    = '⚠️ أنت متأخر بنسبة ';
  static const String weddingBehindSuf    = '% عن هدف توفير الزواج — راجع خطتك';
  static const String weddingOnTrack      = '✅ أنت في المسار الصحيح نحو هدف الزواج';
  static const String weddingAheadPre     = '🌟 رائع! متقدم بـ ';
  static const String weddingAheadSuf     = '% عن خطة التوفير';
  static const String weddingDateMode     = 'حدد تاريخ الزواج';
  static const String weddingMonthMode    = 'حدد عدد الأشهر';

  // ══════════════════════════════════════════════════════
  // MARRIED SCENARIO — couple features
  // ══════════════════════════════════════════════════════

  static const String coupleContribTitle  = '📊 مساهمة كل طرف في الدخل';
  static const String coupleShareReport   = 'مشاركة التقرير مع الشريك';
  static const String coupleBothIncome    = '💑 كلا الزوجين يعملان';
  static const String coupleGoalHome      = '🏠 هدف مشترك — شراء منزل';
  static const String coupleSpendingSync  = 'تنسيق الإنفاق';
  static const String coupleInsightPre    = '💡 باجمع دخلكما ';
  static const String coupleInsightMid    = ' توفرون ';
  static const String coupleInsightSuf    = '% من الدخل المشترك — ممتاز للبناء المشترك!';
  static const String coupleLowSaving     = '⚠️ معدل الادخار المشترك منخفض — راجعا الميزانية معاً';
  static const String coupleModeNote      = '💡 ميزة الحساب المشترك على جهازين قادمة قريباً';
  static const String coupleExportHint    = 'شاركا هذا التقرير بينكما عبر واتساب';

  // ══════════════════════════════════════════════════════
  // FAMILY-SPECIFIC GOAL TYPES
  // ══════════════════════════════════════════════════════

  static const String goalUniversity      = 'الصندوق الجامعي للأبناء';
  static const String goalChildWedding    = 'زواج الأبناء';
  static const String goalHealthInsurance = 'التأمين الصحي العائلي';

  // Hints for family goals
  static const String hintUniversity      = 'تعليم جامعي لأبنائك';
  static const String hintChildWedding    = 'تأمين زواج أبنائك مستقبلاً';
  static const String hintHealthInsurance = 'تأمين صحي شامل للأسرة';

  // ══════════════════════════════════════════════════════
  // CHILDREN EXPENSE TRACKING
  // ══════════════════════════════════════════════════════

  static const String childrenTitle       = '👨‍👩‍👧‍👦 مصاريف الأبناء';
  static const String addChildLabel       = 'إضافة طفل';
  static const String childNameLabel      = 'اسم الطفل';
  static const String childAllowanceLabel = 'مصروف الجيب الشهري';
  static const String childSchoolLabel    = 'رسوم المدرسة السنوية';
  static const String childMonthLabel     = 'الشهري';
  static const String childTotalLabel     = 'إجمالي مصاريف الأبناء';
  static const String childNoKids        = 'لم تضيفي أبناء بعد';
  static const String childNoKidsBody    = 'أضيفي أبناءك لتتبع مصاريفهم بشكل منفصل';

  // ══════════════════════════════════════════════════════
  // SEASONAL BUDGET — مواسم الإنفاق
  // ══════════════════════════════════════════════════════

  static const String seasonTitle         = '📅 مواسم الإنفاق الكثيف';
  static const String seasonEid           = '🌙 العيد';
  static const String seasonRamadan       = '🕌 رمضان';
  static const String seasonSchool        = '🎒 بداية المدارس';
  static const String seasonEidBudget     = 'ميزانية العيد';
  static const String seasonRamadanBudget = 'ميزانية رمضان';
  static const String seasonSchoolBudget  = 'ميزانية المدارس';
  static const String seasonSavingPre     = '💡 تحتاج توفير ';
  static const String seasonSavingMid     = ' شهرياً قبل ';
  static const String seasonSavingSuf     = ' لتغطية هذا الموسم';
  static const String seasonAlertPre      = '⚠️ موسم ';
  static const String seasonAlertSuf      = ' بعد أقل من شهرين — راجعي ميزانيتك';
  static const String seasonNoData        = 'لا توجد مواسم مجدولة';

  // ══════════════════════════════════════════════════════
  // FAMILY SCENARIO — per-child tracking
  // ══════════════════════════════════════════════════════

  static const String childrenTitle        = 'مصاريف الأطفال';
  static const String addChild             = 'إضافة طفل';
  static const String addChildTitle        = 'اسم الطفل';
  static const String childNameHint        = 'مثال: محمد';
  static const String noChildrenYet        = 'أضف أطفالك لتتبع مصاريف كل واحد';
  static const String childrenTotalMonthly = 'إجمالي مصاريف الأطفال شهرياً';
  static const String childAllowance       = 'مصروف الجيب';
  static const String childSchool          = 'مصاريف المدرسة';
  static const String childMedical         = 'ميزانية طبية';

  // Goal types for family
  static const String hintUniversity       = 'صندوق الجامعة للأبناء';
  static const String hintChildWedding     = 'زواج الأبناء (تخطيط طويل المدى)';
  static const String hintHealthInsurance  = 'التأمين الصحي العائلي';

  // ══════════════════════════════════════════════════════
  // DAILY SCREEN — question bar + voice
  // ══════════════════════════════════════════════════════

  static const String dailyQuestion       = 'صرفت اليوم؟';
  static const String dailyQuestionHint   = 'مثال: 150 بقالة أو اضغط 🎤';
  static const String dailySubtitle       = 'سجّل مصاريفك في 30 ثانية 👇';
  static const String voiceNotSupported   = 'الإدخال الصوتي غير متاح على هذا الجهاز';
  static const String voiceParseError     = 'لم أفهم المبلغ — حاول مرة أخرى';
  static const String voiceAddedPre       = '✅ تم تسجيل ';
  static const String voiceAddedMid       = ' ريال في ';
  static const String andConnector        = 'و';

  // ══════════════════════════════════════════════════════
  // RECEIPT SCANNER — OCR
  // ══════════════════════════════════════════════════════

  static const String receiptScan         = 'تصوير الفاتورة';
  static const String receiptScanning     = 'جاري القراءة...';
  static const String receiptCamera       = 'التقاط صورة';
  static const String receiptGallery      = 'اختيار من المعرض';
  static const String receiptFound        = 'تم قراءة الفاتورة ✅';
  static const String receiptConfirmSub   = 'راجع المبلغ والفئة ثم أضف';
  static const String receiptNoAmount     = '⚠️ لم أجد مبلغاً في الصورة — حاول مرة أخرى';
  static const String receiptError        = 'تعذّر قراءة الفاتورة';
  static const String receiptAddBtn       = '✅ إضافة المصروف';
  static const String receiptExpenseName  = 'مصروف من فاتورة';

  // ══════════════════════════════════════════════════════
  // STREAK CARD — rescue + milestones
  // ══════════════════════════════════════════════════════

  static const String streakAtRisk        = '⚠️ خطر انقطاع السلسلة — سجّل الآن';
  static const String streakRescueBtn     = 'استخدم تذكرة الإنقاذ';
  static const String streakTokensLeft    = 'متبقية';
  static const String streakRescuedSuccess= 'تم إنقاذ السلسلة!';
  static const String streakNoTokens      = 'لا تذاكر إنقاذ متبقية هذا الشهر';
  static const String streakDaysSuffix    = ' أيام متواصلة 🔥';
  static const String milestone7          = 'أسبوع كامل من الانضباط المالي!';
  static const String milestone30         = 'شهر كامل! أنت من أفضل 5% من المستخدمين!';
  static const String milestone100        = '100 يوم! أسطورة! هذه عادة مدى الحياة 👑';

  // ══════════════════════════════════════════════════════
  // YESTERDAY COMPARISON
  // ══════════════════════════════════════════════════════

  static const String betterThanYesterday = 'أحسن من أمس بنسبة ';
  static const String worseThanYesterday  = 'أكثر من أمس بنسبة ';

  // ══════════════════════════════════════════════════════
  // GOAL ADDITIONAL (AppStrings already has yearLabel/twoYearsLabel)
  // ══════════════════════════════════════════════════════

  static const String yearLabel           = 'سنة واحدة';
  static const String twoYearsLabel       = 'سنتان';
  static const String descOptHint         = 'وصف (اختياري)';
  static const String badgeLegendary      = '🏆 أسطوري';
  static const String badgeExcellent      = '⭐ متميز';
  static const String streakStart         = 'ابدأ تسجيل مصاريفك يومياً لبناء سلسلتك';
  static const String streakBest          = 'واصل — أنت تسير بشكل رائع!';

}
