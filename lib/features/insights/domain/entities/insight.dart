import 'package:equatable/equatable.dart';

// ══════════════════════════════════════════════════════════
// InsightType — determines visual priority and color
// ══════════════════════════════════════════════════════════

enum InsightType {
  danger,       // red   — over budget, streak at risk
  warning,      // amber — approaching limit, behind goal
  celebration,  // gold  — milestone reached, streak badge
  motivation,   // blue  — encouragement, on-track
  info,         // gray  — morning greeting, neutral info
}

// ══════════════════════════════════════════════════════════
// Insight — immutable, value object
//
// Each insight has a stable ID so we can:
//   - Avoid showing the same insight twice
//   - Track dismissed insights in Hive
// ══════════════════════════════════════════════════════════

final class Insight extends Equatable {
  /// Stable ID — used to track dismissals and deduplication.
  /// Format: 'rule_id:scope' e.g. 'budget_80:food' or 'goal_50:goal_uuid'
  final String id;

  final InsightType type;

  /// Main text shown to the user — personalized with real data
  final String message;

  /// Optional call-to-action label (e.g. 'راجع التقرير')
  final String? actionLabel;

  /// Optional route to navigate to on action tap
  final String? actionRoute;

  /// Lower number = shown first
  final int priority;

  /// When this insight was generated — used for freshness checks
  final DateTime generatedAt;

  const Insight({
    required this.id,
    required this.type,
    required this.message,
    required this.priority,
    required this.generatedAt,
    this.actionLabel,
    this.actionRoute,
  });

  @override
  List<Object?> get props => [id, type, message, priority];
}

// ══════════════════════════════════════════════════════════
// InsightContext — all data a rule needs, passed as one object
//
// Benefits:
//   - Rules are pure functions (context) → Insight?
//   - Easy to test: just construct a context
//   - Single source of truth for computed values
// ══════════════════════════════════════════════════════════

final class InsightContext {
  final String   userName;
  final String   currency;
  final DateTime now;

  // Income
  final double totalIncome;

  // Expenses
  final double totalVariableExpenses;
  final double totalFixedExpenses;
  final Map<String, double> spendByCategory;  // categoryId → amount this month
  final Map<String, double> lastMonthByCategory; // categoryId → amount last month

  // Goals (active only)
  final List<GoalSnapshot> goals;

  // Streak
  final int    streakCount;
  final bool   streakLoggedToday;
  final bool   streakAtRisk;
  final int    streakRescueTokens;

  // Set of insight IDs dismissed by user (not shown again today)
  final Set<String> dismissedIds;

  const InsightContext({
    required this.userName,
    required this.currency,
    required this.now,
    required this.totalIncome,
    required this.totalVariableExpenses,
    required this.totalFixedExpenses,
    required this.spendByCategory,
    required this.lastMonthByCategory,
    required this.goals,
    required this.streakCount,
    required this.streakLoggedToday,
    required this.streakAtRisk,
    required this.streakRescueTokens,
    required this.dismissedIds,
  });

  // ── Computed helpers ───────────────────────────────────

  double get totalExpenses     => totalVariableExpenses + totalFixedExpenses;
  double get balance           => totalIncome - totalExpenses;
  double get savingRate        =>
      totalIncome > 0 ? (balance / totalIncome * 100) : 0;
  int    get daysInMonth       => DateTime(now.year, now.month + 1, 0).day;
  int    get dayOfMonth        => now.day;
  int    get daysLeft          => daysInMonth - dayOfMonth;
  double get dailyBudget       =>
      totalIncome > 0 ? balance / daysInMonth : 0;
  bool   get isEndOfMonth      => dayOfMonth >= 25;
  bool   get isMorning         => now.hour >= 5 && now.hour < 10;

  /// Spending rate for a category vs proportional share of income
  double categoryUsageRate(String catId) {
    if (totalIncome <= 0) return 0;
    final spent = spendByCategory[catId] ?? 0;
    // Proportional budget: what you "should" spend based on days elapsed
    final dayElapsed = dayOfMonth / daysInMonth;
    final expectedForPace = totalIncome * 0.5 * dayElapsed; // 50% of income for variables
    if (expectedForPace <= 0) return 0;
    return spent / expectedForPace;
  }

  /// Category spend vs same category last month
  double categoryVsLastMonth(String catId) {
    final last = lastMonthByCategory[catId] ?? 0;
    final curr = spendByCategory[catId] ?? 0;
    if (last <= 0) return 0;
    return curr / last;
  }
}

// Lightweight goal snapshot (we don't need the full Goal entity here)
final class GoalSnapshot extends Equatable {
  final String id, name, emoji;
  final double progress;    // 0.0 – 1.0
  final int?   monthsLeft;
  final bool   isCompleted;

  const GoalSnapshot({
    required this.id,
    required this.name,
    required this.emoji,
    required this.progress,
    required this.monthsLeft,
    required this.isCompleted,
  });

  @override List<Object?> get props => [id, progress, isCompleted];
}
