// ═══════════════════════════════════════════════════════════
// ReportsScreen — 3 tabs: Monthly, Compare, Goals
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../expenses/presentation/providers/expenses_notifier.dart';
import '../../../goals/presentation/providers/goals_notifier.dart';
import '../providers/reports_provider.dart';
import '../widgets/monthly_report_tab.dart';
import '../widgets/compare_tab.dart';
import '../widgets/goals_report_tab.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});
  @override
  ConsumerState<ReportsScreen> createState() => _State();
}

class _State extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {

  late final TabController _tabs;
  DateTime _month = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final monthKey = _month.monthKey;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header + month nav
            _ReportsHeader(
              month:   _month,
              tabs:    _tabs,
              onPrev: () => setState(() => _month = _month.prevMonth()),
              onNext: () {
                // Edge: no future months
                if (_month.year == DateTime.now().year &&
                    _month.month >= DateTime.now().month) return;
                setState(() => _month = _month.nextMonth());
              },
            ),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  MonthlyReportTab(monthKey: monthKey),
                  CompareTab(currentMonthKey: monthKey),
                  const GoalsReportTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsHeader extends StatelessWidget {
  final DateTime      month;
  final TabController tabs;
  final VoidCallback  onPrev, onNext;

  const _ReportsHeader({
    required this.month, required this.tabs,
    required this.onPrev, required this.onNext,
  });

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surface1,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.textSecondary),
                onPressed: onPrev,
              ),
              Column(
                children: [
                  Text('📈 التقارير', style: AppTextStyles.title),
                  Text(month.monthAr,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentAlt)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: AppColors.textSecondary),
                onPressed: onNext,
              ),
            ],
          ),
        ),
        TabBar(
          controller: tabs,
          tabs: const [
            Tab(text: 'شهري'),
            Tab(text: 'مقارنة'),
            Tab(text: 'الأهداف'),
          ],
          labelStyle:           AppTextStyles.bodyBold.copyWith(fontSize: 12),
          unselectedLabelStyle: AppTextStyles.body.copyWith(fontSize: 12),
          labelColor:           AppColors.accentAlt,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor:       AppColors.accentAlt,
        ),
      ],
    ),
  );
}
