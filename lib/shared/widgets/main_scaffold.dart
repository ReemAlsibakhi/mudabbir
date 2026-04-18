import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_theme.dart';
import '../../features/daily/screens/daily_screen.dart';
import '../../features/income/screens/income_screen.dart';
import '../../features/expenses/screens/expenses_screen.dart';
import '../../features/goals/screens/goals_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

final currentPageProvider = StateProvider<int>((ref) => 0);

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  static const List<_NavItem> _navItems = [
    _NavItem(icon: '🌙', label: 'اليوم',    index: 0),
    _NavItem(icon: '💰', label: 'الدخل',    index: 1),
    _NavItem(icon: '💸', label: 'المصروف',  index: 2),
    _NavItem(icon: '🎯', label: 'الأهداف',  index: 3),
    _NavItem(icon: '📈', label: 'التقارير', index: 4),
    _NavItem(icon: '⚙️', label: 'إعدادات', index: 5),
  ];

  static const List<Widget> _pages = [
    DailyScreen(),
    IncomeScreen(),
    ExpensesScreen(),
    GoalsScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentPage,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface1,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: _navItems.map((item) {
                final isActive = currentPage == item.index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ref.read(currentPageProvider.notifier).state = item.index,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isActive ? AppColors.accent2 : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String icon;
  final String label;
  final int index;
  const _NavItem({required this.icon, required this.label, required this.index});
}
