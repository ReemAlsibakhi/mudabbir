abstract final class AppConstants {
  static const String appName    = 'مدبّر';
  static const String appVersion = '1.0.0';

  // Hive boxes
  static const String userBox          = 'user_profile';
  static const String incomeBox        = 'income';
  static const String dailyExpensesBox = 'daily_expenses';
  static const String fixedExpensesBox = 'fixed_expenses';
  static const String goalsBox         = 'goals';
  static const String settingsBox      = 'settings';

  // Freemium
  static const int freeGoalsLimit   = 1;
  static const int freeFixedLimit   = 5;
  static const int freeVoiceLimit   = 10;
  static const int premiumRescueTokens = 3;
}
