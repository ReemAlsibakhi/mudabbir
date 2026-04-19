import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/widgets.dart';
import '../../../expenses/presentation/widgets/add_expense_sheet.dart';
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
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── Header ──────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverToBoxAdapter(child: DailyHeader(date: now)),
            ),

            // ── Balance Card ─────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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

            // ── Add / Voice Button ─────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _AddVoiceButton(month: now),
              ),
            ),

            // ── No Spend Button ──────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _NoSpendButton(),
              ),
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

class _AddVoiceButton extends ConsumerWidget {
  final DateTime month;
  const _AddVoiceButton({required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) => GestureDetector(
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
              child: Text('🎤', style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 10),
          Text('إضافة مصروف',
            style: AppTextStyles.button.copyWith(fontSize: 15)),
        ],
      ),
    ),
  );
}

class _NoSpendButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => GestureDetector(
    onTap: () async {
      await ref.read(dailyActionsProvider).noSpendToday();
      if (context.mounted) {
        context.showSnack('✅ يوم بدون مصاريف إضافية 💚',
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
              color: AppColors.success.withOpacity(0.85),
              fontSize: 14,
            )),
        ],
      ),
    ),
  );
}
