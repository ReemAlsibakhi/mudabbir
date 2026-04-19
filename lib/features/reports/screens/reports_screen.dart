import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/categories.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/providers/expense_provider.dart';
import '../../../data/providers/income_provider.dart';
import '../../../data/providers/goals_provider.dart';
import '../../../shared/widgets/mud_card.dart';

final _reportTabProvider = StateProvider<int>((ref) => 0);

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(_reportTabProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  const Text('📈 التقارير',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(11)),
                    child: Row(
                      children: [
                        _RTab(label: 'شهري',    index: 0, tab: tab),
                        _RTab(label: 'مقارنة',  index: 1, tab: tab),
                        _RTab(label: 'الأهداف', index: 2, tab: tab),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: [
                const _MonthlyReport(),
                const _CompareReport(),
                const _GoalsReport(),
              ][tab],
            ),
          ],
        ),
      ),
    );
  }
}

class _RTab extends ConsumerWidget {
  final String label;
  final int index, tab;
  const _RTab({required this.label, required this.index, required this.tab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = index == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(_reportTabProvider.notifier).state = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? AppColors.surface3 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(label,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600,
                color: active ? AppColors.accent2 : AppColors.textTertiary)),
          ),
        ),
      ),
    );
  }
}

// ─── Monthly Report ─────────────────────────────────
class _MonthlyReport extends ConsumerWidget {
  const _MonthlyReport();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month   = ref.watch(currentMonthProvider);
    final income  = ref.watch(incomeProvider(month));
    final expenses = ref.watch(expensesProvider(month));
    final fixed   = ref.watch(fixedExpensesProvider);

    final tInc  = income?.total ?? 0;
    final tVar  = expenses.fold(0.0, (s, e) => s + e.amount);
    final tFix  = fixed.fold(0.0, (s, e) => s + e.amount);
    final tExp  = tVar + tFix;
    final bal   = tInc - tExp;
    final pct   = tInc > 0 ? (bal / tInc * 100) : 0.0;

    // Category breakdown
    final catData = kExpenseCategories.map((c) {
      final total = expenses.where((e) => e.categoryId == c.id).fold(0.0, (s, e) => s + e.amount);
      return (cat: c, total: total);
    }).where((x) => x.total > 0).toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    // Persona
    final persona = _getPersona(pct.toDouble());

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        // Stats Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            MudStatCard(icon: '📥', label: 'الدخل',
              value: '${tInc.toStringAsFixed(0)} ريال',
              sub: MudabbirDateUtils.formatMonthAr(month),
              valueColor: AppColors.accent2),
            MudStatCard(icon: '📤', label: 'المصروف',
              value: '${tExp.toStringAsFixed(0)} ريال',
              sub: 'ثابت + متغير',
              valueColor: AppColors.red),
            MudStatCard(icon: bal >= 0 ? '💾' : '⚠️',
              label: bal >= 0 ? 'الفائض' : 'العجز',
              value: '${bal.abs().toStringAsFixed(0)} ريال',
              sub: bal >= 0 ? 'قابل للادخار' : 'تجاوز الميزانية',
              valueColor: bal >= 0 ? AppColors.green : AppColors.red),
            MudStatCard(icon: '📊', label: 'نسبة الادخار',
              value: '${pct.toStringAsFixed(1)}%',
              sub: pct >= 20 ? 'ممتاز 🌟' : pct >= 10 ? 'جيد 👍' : 'يحتاج تحسين',
              valueColor: AppColors.gold),
          ],
        ),
        const SizedBox(height: 12),

        // Persona Card
        if (tInc > 0)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.accent.withOpacity(0.12),
                AppColors.accent3.withOpacity(0.06),
              ]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Text(persona['icon']!, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('شخصية أسرتكم هذا الشهر',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textTertiary)),
                      Text(persona['name']!,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 15,
                          fontWeight: FontWeight.w800, color: AppColors.accent2)),
                      const SizedBox(height: 2),
                      Text(persona['desc']!,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 11,
                          color: AppColors.textSecondary, height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Category Breakdown
        MudCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MudSectionTitle('تفصيل المصاريف'),
              if (catData.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('لا توجد مصاريف هذا الشهر',
                      style: TextStyle(fontFamily: 'Cairo', color: AppColors.textTertiary)),
                  ),
                )
              else
                ...catData.map((x) => _CatRow(
                  icon: x.cat.icon, name: x.cat.nameAr,
                  amount: x.total, color: Color(x.cat.color),
                  percent: tVar > 0 ? x.total / tVar : 0,
                )),
            ],
          ),
        ),

        // Insight
        if (tInc > 0)
          MudInsightBox(
            text: bal < 0
                ? '⚠️ أنتم في وضع عجز مالي. يُنصح بمراجعة المصاريف وتقليل البنود غير الضرورية.'
                : pct < 10
                ? '💡 نسبة الادخار ${pct.toStringAsFixed(1)}%. الهدف الصحي هو 20%. '
                  'حاولوا توفير ${(tInc * 0.2).toStringAsFixed(0)} ريال شهرياً.'
                : '✨ وضع مالي جيد! تدخرون ${bal.toStringAsFixed(0)} ريال شهرياً. استمروا!',
            borderColor: bal < 0 ? AppColors.red.withOpacity(0.2) : AppColors.accent.withOpacity(0.15),
          ),
      ],
    );
  }

  Map<String, String> _getPersona(double savingPct) {
    if (savingPct >= 20) return {'icon': '🦁', 'name': 'الأسد المنضبط',
      'desc': 'انضباط مالي استثنائي! أنتم من أفضل الأسر ادخاراً.'};
    if (savingPct >= 15) return {'icon': '🐯', 'name': 'النمر الذكي',
      'desc': 'أداء مالي قوي! مع قليل من التحسين ستصلون للقمة.'};
    if (savingPct >= 10) return {'icon': '🦊', 'name': 'الثعلب الماهر',
      'desc': 'وضع جيد. لديكم مجال للتحسين في المصاريف المتغيرة.'};
    if (savingPct >= 5)  return {'icon': '🐻', 'name': 'الدب المتعلم',
      'desc': 'الوضع يحتاج اهتماماً. ركزوا على تقليل أكبر 3 مصاريف.'};
    if (savingPct >= 0)  return {'icon': '🐢', 'name': 'السلحفاة الصابرة',
      'desc': 'الادخار منخفض. ابدأوا بتخصيص مبلغ ثابت قبل الإنفاق.'};
    return {'icon': '🦔', 'name': 'القنفذ الحذر',
      'desc': 'منطقة ضغط مالي. راجعوا المصاريف الثابتة فوراً.'};
  }
}

class _CatRow extends StatelessWidget {
  final String icon, name;
  final double amount, percent;
  final Color color;

  const _CatRow({
    required this.icon, required this.name,
    required this.amount, required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$icon $name',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
              Text('${amount.toStringAsFixed(0)} ريال',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                  fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          MudProgressBar(progress: percent, color: color),
        ],
      ),
    );
  }
}

// ─── Compare Report ──────────────────────────────────
class _CompareReport extends ConsumerWidget {
  const _CompareReport();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(currentMonthProvider);

    // Get last 3 months
    final months = List.generate(3, (i) {
      final m = month.month - i - 1;
      final y = month.year + (m <= 0 ? -1 : 0);
      final adjustedM = m <= 0 ? m + 12 : m;
      return DateTime(y, adjustedM);
    });

    final currExp = ref.watch(expensesProvider(month)).fold(0.0, (s, e) => s + e.amount);
    final prevExp = ref.watch(expensesProvider(months[0])).fold(0.0, (s, e) => s + e.amount);
    final diff    = currExp - prevExp;
    final diffPct = prevExp > 0 ? (diff / prevExp * 100) : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MudCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مقارنة ${MudabbirDateUtils.formatMonthAr(month)} بـ ${MudabbirDateUtils.formatMonthAr(months[0])}',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Text(
                '${diff > 0 ? "↑" : "↓"} ${diff.abs().toStringAsFixed(0)} ريال',
                style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.w900,
                  color: diff > 0 ? AppColors.red : AppColors.green,
                ),
              ),
              Text(
                '${diffPct.abs().toStringAsFixed(1)}% ${diff > 0 ? "زيادة في الإنفاق" : "تحسن في التحكم المالي 💚"}',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),

        // Category differences
        MudCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MudSectionTitle('تفصيل الفروق'),
              ...kExpenseCategories.map((cat) {
                final currT = ref.watch(expensesProvider(month))
                    .where((e) => e.categoryId == cat.id).fold(0.0, (s, e) => s + e.amount);
                final prevT = ref.watch(expensesProvider(months[0]))
                    .where((e) => e.categoryId == cat.id).fold(0.0, (s, e) => s + e.amount);
                if (currT == 0 && prevT == 0) return const SizedBox.shrink();
                final d = currT - prevT;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Text('${cat.icon} ${cat.nameAr}',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                      const Spacer(),
                      Text('${currT.toStringAsFixed(0)} ريال',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                          fontWeight: FontWeight.w700, color: Color(cat.color))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: d > 0 ? AppColors.red.withOpacity(0.1) : AppColors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${d > 0 ? "↑" : d < 0 ? "↓" : "—"} ${d.abs().toStringAsFixed(0)}',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w700,
                            color: d > 0 ? AppColors.red : d < 0 ? AppColors.green : AppColors.textTertiary),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Goals Report ────────────────────────────────────
class _GoalsReport extends ConsumerWidget {
  const _GoalsReport();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final totalSaved = goals.fold(0.0, (s, g) => s + g.saved);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MudCard(
          child: goals.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('لا توجد أهداف مضافة بعد',
                      style: TextStyle(fontFamily: 'Cairo', color: AppColors.textTertiary)),
                  ),
                )
              : Column(
                  children: [
                    ...goals.map((g) {
                      final type = const [
                        {'id': 'home', 'icon': '🏠'}, {'id': 'car', 'icon': '🚗'},
                        {'id': 'wedding', 'icon': '💍'}, {'id': 'travel', 'icon': '✈️'},
                        {'id': 'education', 'icon': '🎓'}, {'id': 'emergency', 'icon': '🛡️'},
                        {'id': 'business', 'icon': '💼'}, {'id': 'other', 'icon': '⭐'},
                      ].firstWhere((t) => t['id'] == g.type, orElse: () => {'id': 'other', 'icon': '⭐'});

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(type['icon']!, style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Text(g.name,
                                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Text('${(g.progress * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
                                    fontWeight: FontWeight.w800, color: AppColors.accent2)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            MudProgressBar(progress: g.progress, color: AppColors.accent),
                            const SizedBox(height: 4),
                            Text(
                              '${g.saved.toStringAsFixed(0)} / ${g.target.toStringAsFixed(0)} ريال'
                              '${g.monthsLeft > 0 ? ' · ${g.monthsLeft} شهر متبقي' : ''}',
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 10,
                                color: AppColors.textTertiary),
                            ),
                            const Divider(color: AppColors.border, height: 20),
                          ],
                        ),
                      );
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('إجمالي المدخر للأهداف',
                          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 13)),
                        Text('${totalSaved.toStringAsFixed(0)} ريال',
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 18,
                            fontWeight: FontWeight.w900, color: AppColors.green)),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
