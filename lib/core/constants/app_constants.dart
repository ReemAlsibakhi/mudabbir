// ═══════════════════════════════════════
// MUDABBIR — ثوابت التطبيق
// ═══════════════════════════════════════

class AppConstants {
  // App Info
  static const String appName = 'مدبّر';
  static const String appVersion = '1.0.0';

  // Hive Boxes
  static const String userBox = 'user_profile';
  static const String incomeBox = 'income';
  static const String fixedExpensesBox = 'fixed_expenses';
  static const String dailyExpensesBox = 'daily_expenses';
  static const String goalsBox = 'goals';
  static const String bnplBox = 'bnpl_items';
  static const String settingsBox = 'settings';
  static const String streakBox = 'streak';

  // Shared Prefs Keys
  static const String keyOnboarded = 'onboarded';
  static const String keyCountry = 'country';
  static const String keyLifeStage = 'life_stage';
  static const String keyUserName = 'user_name';
  static const String keyCurrency = 'currency';
  static const String keyTheme = 'theme';

  // Freemium Limits
  static const int freeGoalsLimit = 1;
  static const int freeFixedExpensesLimit = 5;
  static const int freeVoiceInputLimit = 10;
  static const int freeRescueTokensPerMonth = 1;
  static const int premiumRescueTokensPerMonth = 3;

  // Streak
  static const int streakWarningHour = 20; // 8 PM warning

  // Notifications
  static const int morningNotifHour = 9;
  static const int eveningNotifHour = 21;
}
