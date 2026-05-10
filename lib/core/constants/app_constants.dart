abstract final class AppConstants {
  // ── Supabase — Couple Mode ──────────────────────────────
  // Get these from supabase.com → your project → Settings → API
  // See ios/SETUP_SUPABASE.md for full setup guide
  static const String supabaseUrl     = '';  // TODO: paste your URL
  static const String supabaseAnonKey = '';  // TODO: paste your anon key

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
