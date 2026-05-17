import '../../../../core/constants/app_strings.dart';
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
import '../widgets/seasonal_budget_card.dart';
import '../widgets/children_expense_card.dart';
import '../widgets/daily_question_bar.dart';
import '../../../insights/presentation/widgets/insights_section.dart';
import '../widgets/receipt_scanner.dart';
import '../widgets/voice_add_sheet.dart';

class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      tooltip: AppStrings.aiAssistant,
                      color:   AppColors.purple,
                      onTap:   () => context.go(AppRoutes.chat),
                    ),
                    const SizedBox(width: 6),
                    _HeaderIcon(
                      icon:    Icons.account_balance_wallet_outlined,
                      tooltip: AppStrings.incomeTooltip,
                      color:   AppColors.accentAlt,
                      onTap:   () => Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) => IncomeScreen(month: now))),
                    ),
                    const SizedBox(width: 8),
                    _HeaderIcon(
                      icon:    Icons.settings_outlined,
                      tooltip: AppStrings.settingsTooltip,
                      color:   AppColors.textTertiary,
                      onTap:   () => Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen())),
                    ),
                  ],
                ),
              ),
            ),

            // ── Insights Section (rule-based intelligence) ──
            const InsightsSection(),

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

            // ── Seasonal Budget (family only) ─────────────
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(child: SeasonalBudgetCard()),
            ),

            // ── Children Expenses (family only) ──────────────
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(child: ChildrenExpenseCard()),
            ),

            // ── Quick Add ─────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(child: QuickAddGrid(month: now)),
            ),

            // ── Action buttons: manual + voice + camera ─
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _ActionBar(month: now, ref: ref)),
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

// ══════════════════════════════════════════════════════════
// _ActionBar — 3 clear buttons: manual | voice | camera
// ══════════════════════════════════════════════════════════
class _ActionBar extends StatelessWidget {
  final DateTime month;
  final WidgetRef ref;
  const _ActionBar({required this.month, required this.ref});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      // ── Row: Manual (large) + Voice (square) + Camera (square) ──
      Row(
        children: [
          // Manual add — takes most space
          Expanded(
            flex: 3,
            child: _ActionBtn(
              gradient: AppColors.primary,
              icon:     '✍️',
              label:    AppStrings.addManuallyBtn,
              onTap:    () => AddExpenseSheet.show(context, month, ref),
            ),
          ),
          const SizedBox(width: 10),
          // Voice add — square
          _VoiceActionBtn(month: month),
          const SizedBox(width: 10),
          // Camera OCR — square
          _CameraActionBtn(month: month),
        ],
      ),
      const SizedBox(height: 8),
    ],
  );
}

// ── Manual button ─────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final LinearGradient gradient;
  final String icon, label;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.gradient, required this.icon,
    required this.label, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height:  56,
      decoration: BoxDecoration(
        gradient:     gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
          color:      AppColors.accent.withOpacity(0.25),
          blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon,  style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.button.copyWith(fontSize: 15)),
        ],
      ),
    ),
  );
}

// ── Voice button — has its own state for speech ───────────
class _VoiceActionBtn extends ConsumerStatefulWidget {
  final DateTime month;
  const _VoiceActionBtn({required this.month});

  @override
  ConsumerState<_VoiceActionBtn> createState() => _VoiceActionBtnState();
}

class _VoiceActionBtnState extends ConsumerState<_VoiceActionBtn> {
  // Embed the DailyQuestionBar logic directly in this button
  void _openVoice() =>
      VoiceAddSheet.show(context, widget.month);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _openVoice,
    child: Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        color:        AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Text('🎤', style: TextStyle(fontSize: 24))),
    ),
  );
}

// ── Camera button ─────────────────────────────────────────
class _CameraActionBtn extends StatelessWidget {
  final DateTime month;
  const _CameraActionBtn({required this.month});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      builder:            (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: ReceiptScanner(month: month))),
    child: Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        color:        AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Text('📷', style: TextStyle(fontSize: 24))),
    ),
  );
}

// ── Voice input sheet — opens from bottom ─────────────────
class _VoiceInputSheet extends StatelessWidget {
  final DateTime month;
  const _VoiceInputSheet({required this.month});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color:        AppColors.surface1,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    padding: EdgeInsets.only(
      left: 0, right: 0, top: 0,
      bottom: MediaQuery.of(context).viewInsets.bottom,
    ),
    child: DailyQuestionBar(month: month),
  );
}

// ── No Spend Button ───────────────────────────────────────
class _NoSpendButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => GestureDetector(
    onTap: () async {
      await ref.read(dailyActionsProvider).noSpendToday();
      if (context.mounted) {
        context.showSnack(AppStrings.noSpendDay,
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
          Text(AppStrings.noSpendBtn,
            style: AppTextStyles.subtitle.copyWith(
              color:    AppColors.success.withOpacity(0.85),
              fontSize: 14)),
        ],
      ),
    ),
  );
}
