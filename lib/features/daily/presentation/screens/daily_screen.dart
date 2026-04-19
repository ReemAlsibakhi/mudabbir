import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/widgets.dart';
import '../../../expenses/domain/usecases/add_expense_usecase.dart';
import '../../../expenses/presentation/providers/expenses_notifier.dart';
import '../../../expenses/presentation/widgets/add_expense_sheet.dart';
import '../../../onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../../onboarding/presentation/providers/onboarding_notifier.dart';
import '../../presentation/providers/daily_notifier.dart';
import '../widgets/streak_card.dart';
import '../widgets/today_summary.dart';
import '../widgets/quick_add_grid.dart';
import '../widgets/daily_header.dart';

class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: DailyHeader(date: now),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: StreakCard(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _VoiceButton(month: now),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: QuickAddGrid(month: now),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _NoSpendButton(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: TodaySummary(date: now),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Voice / Manual Add Button ─────────────────────────────
class _VoiceButton extends ConsumerWidget {
  final DateTime month;
  const _VoiceButton({required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) => GestureDetector(
    onTap: () => AddExpenseSheet.show(context, month, ref),
    child: Container(
      margin:  const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color:        AppColors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: AppColors.purple.withOpacity(0.3)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🎤', style: TextStyle(fontSize: 20)),
          SizedBox(width: 10),
          Text('اضغط لإضافة مصروف سريع',
            style: TextStyle(fontFamily:'Cairo', fontSize:13,
              fontWeight:FontWeight.w600, color:AppColors.purple)),
        ],
      ),
    ),
  );
}

// ── No-Spend Button ───────────────────────────────────────
class _NoSpendButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => GestureDetector(
    onTap: () async {
      await ref.read(dailyActionsProvider).noSpendToday();
      if (context.mounted) {
        context.showSnack('✅ يوم بدون مصاريف إضافية 💚', color: AppColors.success);
      }
    },
    child: Container(
      margin:  const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color:        AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: AppColors.success.withOpacity(0.25)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('✅', style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Text('اليوم ما صرفت شيء',
            style: TextStyle(fontFamily:'Cairo', fontSize:14,
              fontWeight:FontWeight.w700, color:AppColors.success)),
        ],
      ),
    ),
  );
}
