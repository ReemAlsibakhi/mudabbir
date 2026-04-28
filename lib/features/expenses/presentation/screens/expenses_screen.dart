import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/widgets.dart';
import '../providers/expenses_notifier.dart';
import '../providers/expenses_state.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/add_fixed_expense_sheet.dart';
import '../widgets/expense_list.dart';
import '../widgets/fixed_expense_list.dart';
import '../widgets/expenses_summary_bar.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  final DateTime month;
  const ExpensesScreen({super.key, required this.month});

  @override
  ConsumerState<ExpensesScreen> createState() => _State();
}

class _State extends ConsumerState<ExpensesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = widget.month;
    _tabs  = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {})); // rebuild FAB label on tab change
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final monthKey = _month.monthKey;
    final state    = ref.watch(expensesNotifierProvider(monthKey));

    ref.listen(expensesNotifierProvider(monthKey), (_, next) {
      if (next is ExpensesLoaded && next.errorMessage != null) {
        context.showSnack(next.errorMessage!, color: AppColors.error);
        ref.read(expensesNotifierProvider(monthKey).notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              month:  _month,
              tabs:   _tabs,
              onPrev: () => setState(() => _month = _month.prevMonth()),
              onNext: () {
                final now = DateTime.now();
                if (_month.year == now.year && _month.month >= now.month) return;
                setState(() => _month = _month.nextMonth());
              },
            ),
            Expanded(
              child: switch (state) {
                ExpensesLoading() => const MudLoadingView(),
                ExpensesError(:final message) =>
                    MudErrorView(message: message, onRetry: () {}),
                ExpensesLoaded() => _Content(
                  state: state, month: _month, tabs: _tabs),
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        onPressed: () {
          if (_tabs.index == 0) {
            AddFixedExpenseSheet.show(context, _month.monthKey, ref);
          } else {
            AddExpenseSheet.show(context, _month, ref);
          }
        },
        icon:  const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          _tabs.index == 0 ? 'إضافة ثابت' : 'إضافة مصروف',
          style: AppTextStyles.button.copyWith(fontSize: 13)),
      ),
    );
  }
}

// ── Header with month navigation ──────────────────────────
class _Header extends StatelessWidget {
  final DateTime      month;
  final TabController tabs;
  final VoidCallback  onPrev, onNext;

  const _Header({
    required this.month, required this.tabs,
    required this.onPrev, required this.onNext,
  });

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surface1,
    child: Column(
      children: [
        // Title + month navigation
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
          child: Row(
            children: [
              // ✅ Month prev button
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
                tooltip: 'الشهر السابق',
                onPressed: onPrev,
              ),
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Text('💸 المصروف', style: AppTextStyles.title),
                      Text(month.monthAr,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentAlt)),
                    ],
                  ),
                ),
              ),
              // ✅ Month next button
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded,
                  color: AppColors.textSecondary),
                tooltip: 'الشهر التالي',
                onPressed: onNext,
              ),
            ],
          ),
        ),
        // Tabs
        TabBar(
          controller: tabs,
          tabs: const [
            Tab(text: '📅 ثابت شهري'),
            Tab(text: '📆 متغير يومي'),
          ],
          labelStyle:           AppTextStyles.bodyBold.copyWith(fontSize: 13),
          unselectedLabelStyle: AppTextStyles.body.copyWith(fontSize: 13),
          labelColor:           AppColors.accentAlt,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor:       AppColors.accentAlt,
          indicatorSize:        TabBarIndicatorSize.tab,
        ),
      ],
    ),
  );
}

// ── Content ────────────────────────────────────────────────
class _Content extends StatelessWidget {
  final ExpensesLoaded state;
  final DateTime       month;
  final TabController  tabs;

  const _Content({required this.state, required this.month, required this.tabs});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ExpensesSummaryBar(
        totalFixed:    state.totalFixed,
        totalVariable: state.totalVariable,
      ),
      Expanded(
        child: TabBarView(
          controller: tabs,
          children: [
            FixedExpenseList(items: state.fixedExpenses, monthKey: month.monthKey),
            ExpenseList(items: state.expenses, monthKey: month.monthKey),
          ],
        ),
      ),
    ],
  );
}
