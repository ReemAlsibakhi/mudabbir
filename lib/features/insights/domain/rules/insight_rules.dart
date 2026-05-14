import '../../../../core/constants/categories.dart';
import '../../../../core/extensions/double_ext.dart';
import '../entities/insight.dart';

// ══════════════════════════════════════════════════════════
// InsightRules — pure functions (context) → Insight?
//
// CONTRACT:
//   • Each rule returns ONE Insight or null
//   • Rules never throw — they return null on failure
//   • Rules never access Hive or any external state
//   • All data comes via InsightContext
// ══════════════════════════════════════════════════════════

abstract final class InsightRules {
  // Run all rules and return sorted, de-duplicated list
  static List<Insight> evaluate(InsightContext ctx, {int maxResults = 3}) {
    final all = <Insight>[
      _morningGreeting(ctx),
      _streakAtRisk(ctx),
      _streakMilestone(ctx),
      _lowSavingRate(ctx),
      _categorySpike(ctx, 'restaurants'),
      _categorySpike(ctx, 'shopping'),
      _categorySpike(ctx, 'entertainment'),
      _budgetWarning(ctx),
      _goalMilestone(ctx),
      _goalBehind(ctx),
      _monthEndSummary(ctx),
      _positiveBalance(ctx),
    ]
        .whereType<Insight>()                    // remove nulls
        .where((i) => !ctx.dismissedIds.contains(i.id)) // remove dismissed
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));

    return all.take(maxResults).toList();
  }

  // ── 1. Morning Greeting ──────────────────────────────────
  // Trigger: app opened between 5am–10am, not logged today
  // Priority: 5 (low urgency — informational)

  static Insight? _morningGreeting(InsightContext ctx) {
    if (!ctx.isMorning) return null;

    final balance = ctx.balance;
    final msg     = balance > 0
        ? 'صباح الخير يا ${ctx.userName}! 🌅\n'
          'المتاح اليوم: ${balance.fmt()} ${ctx.currency}'
        : 'صباح الخير يا ${ctx.userName}! 🌅\n'
          'تابع ميزانيتك اليوم واستمر في التسجيل';

    return Insight(
      id:          'morning:${ctx.now.day}',
      type:        InsightType.info,
      message:     msg,
      priority:    5,
      generatedAt: ctx.now,
    );
  }

  // ── 2. Streak At Risk ─────────────────────────────────────
  // Trigger: streakAtRisk = true (didn't log yesterday or today)
  // Priority: 1 (highest urgency)

  static Insight? _streakAtRisk(InsightContext ctx) {
    if (!ctx.streakAtRisk || ctx.streakCount == 0) return null;
    final tokens = ctx.streakRescueTokens;
    final msg    = tokens > 0
        ? '⚠️ سلسلتك الـ${ctx.streakCount} يوم في خطر!\n'
          'سجّل الآن أو استخدم تذكرة الإنقاذ ($tokens متبقية)'
        : '⚠️ سلسلتك الـ${ctx.streakCount} يوم في خطر!\n'
          'سجّل مصروفاً أو اضغط "ما صرفت اليوم" الآن';

    return Insight(
      id:          'streak_risk:${ctx.now.day}',
      type:        InsightType.danger,
      message:     msg,
      priority:    1,
      actionLabel: 'سجّل الآن',
      generatedAt: ctx.now,
    );
  }

  // ── 3. Streak Milestone ───────────────────────────────────
  // Trigger: streak reaches 7, 30, or 100 days (first time)
  // Priority: 4

  static Insight? _streakMilestone(InsightContext ctx) {
    final count = ctx.streakCount;
    if (!_isMilestone(count)) return null;

    final emoji = count >= 100 ? '👑' : count >= 30 ? '🏆' : '🎉';
    final msg   = '$emoji $count يوماً متواصلاً!\n'
        '${_milestoneText(count)}';

    return Insight(
      id:          'streak_milestone:$count',
      type:        InsightType.celebration,
      message:     msg,
      priority:    4,
      generatedAt: ctx.now,
    );
  }

  static bool _isMilestone(int n) => n == 7 || n == 30 || n == 100;

  static String _milestoneText(int n) => switch (n) {
    7   => 'أسبوع كامل من الانضباط المالي — رائع!',
    30  => 'شهر كامل! أنت من أفضل 5% من المستخدمين',
    100 => 'أسطورة! 100 يوم — هذه عادة مدى الحياة',
    _   => '',
  };

  // ── 4. Low Saving Rate ────────────────────────────────────
  // Trigger: savingRate < 10% and income > 0
  // Priority: 2

  static Insight? _lowSavingRate(InsightContext ctx) {
    if (ctx.totalIncome <= 0) return null;
    if (ctx.savingRate >= 10) return null;
    if (ctx.dayOfMonth < 10) return null; // too early in month to judge

    final rate = ctx.savingRate.toStringAsFixed(1);
    return Insight(
      id:          'low_saving:${ctx.now.year}${ctx.now.month}',
      type:        InsightType.warning,
      message:     '📉 نسبة ادخارك هذا الشهر $rate% فقط\n'
                   'الهدف 20% — راجع مصاريفك الثابتة الكبيرة أولاً',
      priority:    2,
      actionLabel: 'راجع التقرير',
      actionRoute: '/reports',
      generatedAt: ctx.now,
    );
  }

  // ── 5. Category Spike ─────────────────────────────────────
  // Trigger: category spend this month > 150% vs last month
  // Priority: 2

  static Insight? _categorySpike(InsightContext ctx, String catId) {
    final ratio = ctx.categoryVsLastMonth(catId);
    if (ratio < 1.5) return null;

    final cat    = getCategoryById(catId);
    final curr   = ctx.spendByCategory[catId] ?? 0;
    final last   = ctx.lastMonthByCategory[catId] ?? 0;
    if (curr < 100 || last < 100) return null; // ignore tiny amounts

    final pct = ((ratio - 1) * 100).toStringAsFixed(0);
    return Insight(
      id:          'cat_spike:$catId:${ctx.now.year}${ctx.now.month}',
      type:        InsightType.warning,
      message:     '${cat.icon} إنفاقك على ${cat.nameAr} '
                   'ارتفع $pct% هذا الشهر\n'
                   'تريد تحديد حد شهري لهذه الفئة؟',
      priority:    2,
      actionLabel: 'راجع المصاريف',
      actionRoute: '/expenses',
      generatedAt: ctx.now,
    );
  }

  // ── 6. Budget Warning ────────────────────────────────────
  // Trigger: totalExpenses > 80% of income and days > 10
  // Priority: 1

  static Insight? _budgetWarning(InsightContext ctx) {
    if (ctx.totalIncome <= 0) return null;
    if (ctx.dayOfMonth < 10) return null;

    final usedPct = ctx.totalExpenses / ctx.totalIncome;
    if (usedPct < 0.80) return null;

    final pct = (usedPct * 100).toStringAsFixed(0);
    return Insight(
      id:          'budget_80:${ctx.now.year}${ctx.now.month}',
      type:        InsightType.danger,
      message:     '🔴 استخدمت $pct% من دخلك الشهري\n'
                   'باقي ${ctx.daysLeft} أيام — راجع المصاريف الاختيارية',
      priority:    1,
      actionLabel: 'راجع المصاريف',
      actionRoute: '/expenses',
      generatedAt: ctx.now,
    );
  }

  // ── 7. Goal Milestone ────────────────────────────────────
  // Trigger: goal crosses 25%, 50%, or 75% progress
  // Priority: 4

  static Insight? _goalMilestone(InsightContext ctx) {
    for (final g in ctx.goals) {
      if (g.isCompleted) continue;
      final milestone = _goalMilestoneLevel(g.progress);
      if (milestone == null) continue;

      final pct = (g.progress * 100).toStringAsFixed(0);
      return Insight(
        id:          'goal_${milestone.toInt()}:${g.id}',
        type:        InsightType.celebration,
        message:     '${g.emoji} أنت في $pct% من هدف "${g.name}"\n'
                     '${g.monthsLeft != null ? "بمعدلك ستصل خلال ${g.monthsLeft} شهراً" : "واصل!"}',
        priority:    4,
        actionLabel: 'راجع الأهداف',
        actionRoute: '/goals',
        generatedAt: ctx.now,
      );
    }
    return null;
  }

  static double? _goalMilestoneLevel(double p) {
    if (p >= 0.74 && p <= 0.76) return 75;
    if (p >= 0.49 && p <= 0.51) return 50;
    if (p >= 0.24 && p <= 0.26) return 25;
    return null;
  }

  // ── 8. Goal Behind ────────────────────────────────────────
  // Trigger: goal has monthly target but saved < target this month
  // Priority: 3

  static Insight? _goalBehind(InsightContext ctx) {
    for (final g in ctx.goals) {
      if (g.isCompleted) return null;
      if (g.monthsLeft == null) continue;
      // We don't have per-goal monthly saving here — use progress proxy:
      // If progress is very low (< 5%) and goal is more than 1 month old,
      // assume behind
      if (g.progress < 0.05 && g.monthsLeft != null && g.monthsLeft! > 11) {
        return Insight(
          id:          'goal_behind:${g.id}:${ctx.now.year}${ctx.now.month}',
          type:        InsightType.warning,
          message:     '${g.emoji} لم تبدأ بعد في هدف "${g.name}"\n'
                       'تحتاج البدء في الادخار لتصل للهدف',
          priority:    3,
          actionLabel: 'أضف ادخاراً',
          actionRoute: '/goals',
          generatedAt: ctx.now,
        );
      }
    }
    return null;
  }

  // ── 9. Month End Summary ─────────────────────────────────
  // Trigger: day >= 25
  // Priority: 5

  static Insight? _monthEndSummary(InsightContext ctx) {
    if (!ctx.isEndOfMonth) return null;
    if (ctx.totalIncome <= 0) return null;

    final saved   = ctx.balance;
    final rate    = ctx.savingRate.toStringAsFixed(1);
    final emoji   = saved > 0 ? '✅' : '⚠️';
    final message = saved > 0
        ? '$emoji نهاية الشهر تقترب — وفّرت ${saved.fmt()} ${ctx.currency}\n'
          'نسبة ادخارك: $rate% — استمر!'
        : '$emoji نهاية الشهر — الميزانية في العجز\n'
          'راجع المصاريف وخطط لشهر أفضل';

    return Insight(
      id:          'month_end:${ctx.now.year}${ctx.now.month}',
      type:        saved > 0 ? InsightType.motivation : InsightType.warning,
      message:     message,
      priority:    5,
      actionLabel: 'التقرير الكامل',
      actionRoute: '/reports',
      generatedAt: ctx.now,
    );
  }

  // ── 10. Positive Balance Encouragement ───────────────────
  // Trigger: saving rate >= 20%, show after day 15
  // Priority: 6 (lowest)

  static Insight? _positiveBalance(InsightContext ctx) {
    if (ctx.dayOfMonth < 15) return null;
    if (ctx.savingRate < 20)  return null;
    if (ctx.totalIncome <= 0) return null;

    return Insight(
      id:          'positive:${ctx.now.year}${ctx.now.month}',
      type:        InsightType.motivation,
      message:     '🌟 أداء ممتاز يا ${ctx.userName}!\n'
                   'نسبة ادخارك ${ctx.savingRate.toStringAsFixed(1)}% '
                   '— أنت من أفضل المستخدمين هذا الشهر',
      priority:    6,
      generatedAt: ctx.now,
    );
  }
}
