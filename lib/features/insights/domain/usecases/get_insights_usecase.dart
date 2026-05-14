import '../../../../core/extensions/datetime_ext.dart';
import '../../../daily/domain/repositories/streak_repository.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../goals/domain/repositories/goal_repository.dart';
import '../../../income/domain/repositories/income_repository.dart';
import '../../../onboarding/domain/repositories/onboarding_repository.dart';
import '../entities/insight.dart';
import '../repositories/insight_repository.dart';
import '../rules/insight_rules.dart';

// ══════════════════════════════════════════════════════════
// GetInsightsUseCase — builds InsightContext and runs rules
// All repos are Hive-backed (synchronous reads) — no await
// ══════════════════════════════════════════════════════════

final class GetInsightsUseCase {
  final IncomeRepository     _incomeRepo;
  final ExpenseRepository    _expenseRepo;
  final GoalRepository       _goalRepo;
  final OnboardingRepository _onboardingRepo;
  final StreakRepository     _streakRepo;
  final InsightRepository    _insightRepo;

  const GetInsightsUseCase({
    required IncomeRepository     incomeRepo,
    required ExpenseRepository    expenseRepo,
    required GoalRepository       goalRepo,
    required OnboardingRepository onboardingRepo,
    required StreakRepository     streakRepo,
    required InsightRepository    insightRepo,
  })  : _incomeRepo     = incomeRepo,
        _expenseRepo    = expenseRepo,
        _goalRepo       = goalRepo,
        _onboardingRepo = onboardingRepo,
        _streakRepo     = streakRepo,
        _insightRepo    = insightRepo;

  List<Insight> call({int maxResults = 3}) {
    final now      = DateTime.now();
    final curKey   = now.monthKey;
    final prevKey  = now.prevMonth().monthKey;

    // ── Profile ─────────────────────────────────────────
    final profile  = _onboardingRepo.getSaved();
    final name     = (profile?.name.trim().isEmpty ?? true)
        ? 'صديقي' : profile!.name.trim();
    final currency = _resolveCurrency(profile?.countryId ?? 'sa');

    // ── Income ────────────────────────────────────────────
    final income   = _incomeRepo.getByMonth(curKey);

    // ── Variable expenses ─────────────────────────────────
    final curExpenses  = _expenseRepo.getByMonth(curKey);
    final prevExpenses = _expenseRepo.getByMonth(prevKey);
    final varTotal     = curExpenses.fold(0.0, (s, e) => s + e.amount);
    final fixedTotal   = _expenseRepo.totalFixed();

    // ── Category maps ─────────────────────────────────────
    final spendByCat  = _groupByCategory(curExpenses);
    final prevByCat   = _groupByCategory(prevExpenses);

    // ── Goals ─────────────────────────────────────────────
    final goals = _goalRepo
        .getAll()
        .where((g) => !g.isCompleted)
        .map((g) => GoalSnapshot(
              id:          g.id,
              name:        g.name,
              emoji:       g.type.icon,
              progress:    g.progress,
              monthsLeft:  g.monthsLeft,
              isCompleted: g.isCompleted,
            ))
        .toList();

    // ── Streak ────────────────────────────────────────────
    final streak = _streakRepo.get();

    // ── Dismissed IDs ─────────────────────────────────────
    final dismissed = _insightRepo.getDismissedIds();

    // ── Assemble context ──────────────────────────────────
    final ctx = InsightContext(
      userName:              name,
      currency:              currency,
      now:                   now,
      totalIncome:           income.total,
      totalVariableExpenses: varTotal,
      totalFixedExpenses:    fixedTotal,
      spendByCategory:       spendByCat,
      lastMonthByCategory:   prevByCat,
      goals:                 goals,
      streakCount:           streak.count,
      streakLoggedToday:     streak.loggedToday,
      streakAtRisk:          streak.isAtRisk,
      streakRescueTokens:    streak.rescueTokens,
      dismissedIds:          dismissed,
    );

    return InsightRules.evaluate(ctx, maxResults: maxResults);
  }

  // ── Helpers ───────────────────────────────────────────────

  Map<String, double> _groupByCategory(List<dynamic> expenses) {
    final map = <String, double>{};
    for (final e in expenses) {
      final catId  = e.categoryId as String;
      final amount = e.amount    as double;
      map[catId] = (map[catId] ?? 0) + amount;
    }
    return map;
  }

  static String _resolveCurrency(String countryId) {
    const currencies = {
      'sa': 'ريال',   'ae': 'درهم',  'kw': 'دينار', 'bh': 'دينار',
      'qa': 'ريال',   'om': 'ريال',  'eg': 'جنيه',  'jo': 'دينار',
      'lb': 'ليرة',  'iq': 'دينار', 'sy': 'ليرة',  'ye': 'ريال',
      'ma': 'درهم',   'dz': 'دينار', 'tn': 'دينار', 'ly': 'دينار',
      'sd': 'جنيه',   'so': 'شلن',   'ps': 'شيكل',  'mr': 'أوقية',
      'km': 'فرنك',   'dj': 'فرنك',
    };
    return currencies[countryId] ?? 'ريال';
  }
}
