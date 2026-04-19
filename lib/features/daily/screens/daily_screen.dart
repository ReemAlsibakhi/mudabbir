import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/categories.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/providers/expense_provider.dart';
import '../../../data/providers/income_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../shared/widgets/mud_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/voice_input_widget.dart';
import '../widgets/quick_add_widget.dart';
import '../widgets/today_summary.dart';

class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Header ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: _DailyHeader(date: now, userAsync: userAsync),
              ),
            ),

            // ─── Streak ───
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: StreakCard(),
              ),
            ),

            // ─── Voice Input ───
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: VoiceInputWidget(),
              ),
            ),

            // ─── Quick Add ───
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: QuickAddWidget(),
              ),
            ),

            // ─── No Spend Button ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: _NoSpendButton(),
              ),
            ),

            // ─── Today Summary ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: TodaySummary(date: now),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Daily Header ───────────────────────────────────
class _DailyHeader extends StatelessWidget {
  final DateTime date;
  final AsyncValue userAsync;

  const _DailyHeader({required this.date, required this.userAsync});

  @override
  Widget build(BuildContext context) {
    final dayStr = MudabbirDateUtils.formatDayAr(date);
    final greeting = _getGreeting(date.hour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(dayStr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo')),
        const SizedBox(height: 4),
        userAsync.when(
          loading: () => const SizedBox(height: 32),
          error: (_, __) => const SizedBox(height: 32),
          data: (user) {
            final name = user?.name ?? '';
            return RichText(
              text: TextSpan(
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w900),
                children: [
                  TextSpan(text: '$greeting ', style: const TextStyle(color: AppColors.textPrimary)),
                  TextSpan(text: name, style: const TextStyle(
                    foreground: Paint()..shader = const LinearGradient(
                      colors: [AppColors.accent2, AppColors.accent3],
                    ).createShader(Rect.fromLTWH(0, 0, 200, 50)),
                  )),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        const Text('سجّل مصاريف اليوم بسرعة 👇',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Cairo')),
      ],
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'صباح الخير،';
    if (hour < 17) return 'مرحباً،';
    return 'مساء الخير،';
  }
}

// ─── No Spend Button ────────────────────────────────
class _NoSpendButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final actions = ref.read(userActionsProvider);
        await actions.updateStreak();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ ممتاز! يوم بدون مصاريف إضافية 💚',
                style: TextStyle(fontFamily: 'Cairo')),
              backgroundColor: AppColors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.green.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.green.withOpacity(0.25)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('✅', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text('اليوم ما صرفت شيء',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 14,
                fontWeight: FontWeight.w700, color: AppColors.green)),
          ],
        ),
      ),
    );
  }
}
