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

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monthKey = widget.month.monthKey;
    final state    = ref.watch(expensesNotifierProvider(monthKey));

    // Listen for errors → show snackbar
    ref.listen(expensesNotifierProvider(monthKey), (_, next) {
      if (next is ExpensesLoaded && next.errorMessage != null) {
        context.showSnack(next.errorMessage!, color: AppColors.error);
        ref.read(expensesNotifierProvider(monthKey).notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(month: widget.month, tabs: _tabs),
            Expanded(
              child: switch (state) {
                ExpensesLoading() => const MudLoadingView(),
                ExpensesError(:final message) =>
                    MudErrorView(message: message, onRetry: () {}),
                ExpensesLoaded() => _Content(
                  state:    state,
                  month:    widget.month,
                  tabs:     _tabs,
                ),
              },
            ),
          ],
        ),
      ),
      floatingActionButton: _AddButton(month: widget.month, tabs: _tabs),
    );
  }
}

// ── Header ─────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final DateTime       month;
  final TabController  tabs;
  const _Header({required this.month, required this.tabs});

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surface1,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('💸 المصروف', style: AppTextStyles.headline2),
              Text(month.monthAr,
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        TabBar(
          controller: tabs,
          tabs: const [
            Tab(text: '📅 ثابت شهري'),
            Tab(text: '📆 متغير يومي'),
          ],
          labelStyle:         AppTextStyles.bodyBold,
          unselectedLabelStyle: AppTextStyles.body,
          labelColor:         AppColors.accentAlt,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor:     AppColors.accentAlt,
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
            FixedExpenseList(
              items:    state.fixedExpenses,
              monthKey: month.monthKey,
            ),
            ExpenseList(
              items:    state.expenses,
              monthKey: month.monthKey,
            ),
          ],
        ),
      ),
    ],
  );
}

// ── FAB ────────────────────────────────────────────────────
class _AddButton extends ConsumerWidget {
  final DateTime      month;
  final TabController tabs;
  const _AddButton({required this.month, required this.tabs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFixed = tabs.index == 0;
    return FloatingActionButton.extended(
      backgroundColor: AppColors.accent,
      onPressed: () {
        if (isFixed) {
          AddFixedExpenseSheet.show(context, month.monthKey, ref);
        } else {
          AddExpenseSheet.show(context, month, ref);
        }
      },
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        isFixed ? 'إضافة ثابت' : 'إضافة مصروف',
        style: AppTextStyles.button.copyWith(fontSize: 13),
      ),
    );
  }
}
