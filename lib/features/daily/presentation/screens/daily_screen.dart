import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../expenses/presentation/widgets/add_expense_sheet.dart';
import '../../../income/presentation/screens/income_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../providers/daily_notifier.dart';
import '../widgets/balance_card.dart';
import '../widgets/daily_header.dart';
import '../widgets/quick_add_grid.dart';
import '../widgets/streak_card.dart';
import '../widgets/today_summary.dart';

class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header — NOT inside SliverAppBar title ────
            // Avoids clipping issue with multi-line content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Greeting — fills available space
                    Expanded(child: DailyHeader(date: now)),
                    const SizedBox(width: 8),
                    // Action icons — right side in RTL = left visually
                    // AI Chat icon
                    _HeaderIcon(
                      icon:    Icons.smart_toy_outlined,
                      tooltip: 'المستشار الذكي',
                      color:   AppColors.purple,
                      onTap:   () => context.go(AppRoutes.chat),
                    ),
                    const SizedBox(width: 6),
                    _HeaderIcon(
                      icon:    Icons.account_balance_wallet_outlined,
                      tooltip: 'الدخل الشهري',
                      color:   AppColors.accentAlt,
                      onTap:   () => Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) => IncomeScreen(month: now))),
                    ),
                    const SizedBox(width: 8),
                    _HeaderIcon(
                      icon:    Icons.settings_outlined,
                      tooltip: 'الإعدادات',
                      color:   AppColors.textTertiary,
                      onTap:   () => Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen())),
                    ),
                  ],
                ),
              ),
            ),

            // ── Balance Card ─────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(child: BalanceCard(month: now)),
            ),

            // ── Streak Card ───────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: const SliverToBoxAdapter(child: StreakCard()),
            ),

            // ── Quick Add ─────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(child: QuickAddGrid(month: now)),
            ),

            // ── Add Expense Button ────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _AddButton(month: now, ref: ref)),
            ),

            // ── No Spend Button ───────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(child: _NoSpendButton()),
            ),

            // ── Today Summary ─────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              sliver: SliverToBoxAdapter(child: TodaySummary(date: now)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header Icon ───────────────────────────────────────────
class _HeaderIcon extends StatelessWidget {
  final IconData     icon;
  final String       tooltip;
  final Color        color;
  final VoidCallback onTap;
  const _HeaderIcon({
    required this.icon, required this.tooltip,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color:        AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    ),
  );
}

// ── Add Button ────────────────────────────────────────────
class _AddButton extends StatelessWidget {
  final DateTime month;
  final WidgetRef ref;
  const _AddButton({required this.month, required this.ref});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => AddExpenseSheet.show(context, month, ref),
    child: Container(
      margin:  const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient:     AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
          color:      AppColors.accent.withOpacity(0.3),
          blurRadius: 16,
          offset:     const Offset(0, 4),
        )],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color:        Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('🎤', style: TextStyle(fontSize: 14))),
          ),
          const SizedBox(width: 10),
          Text('إضافة مصروف يدوياً',
            style: AppTextStyles.button.copyWith(fontSize: 14)),
        ],
      ),
    ),
  );
}

// ── No Spend Button ───────────────────────────────────────
class _NoSpendButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => GestureDetector(
    onTap: () async {
      await ref.read(dailyActionsProvider).noSpendToday();
      if (context.mounted) {
        context.showSnack('✅ يوم بدون مصاريف — عمل رائع!',
          color: AppColors.success);
      }
    },
    child: Container(
      margin:  const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color:        AppColors.success.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.success.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✅', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text('اليوم ما صرفت شيء',
            style: AppTextStyles.subtitle.copyWith(
              color:    AppColors.success.withOpacity(0.85),
              fontSize: 14)),
        ],
      ),
    ),
  );
}
