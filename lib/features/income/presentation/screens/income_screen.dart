// ═══════════════════════════════════════════════════════════
// IncomeScreen — UI only, delegates everything to notifier
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/income_notifier.dart';
import '../providers/income_state.dart';
import '../widgets/income_form.dart';
import '../widgets/income_summary_card.dart';
import '../widgets/income_savings_tip.dart';
import '../../domain/entities/income.dart';

class IncomeScreen extends ConsumerWidget {
  final DateTime month;
  const IncomeScreen({super.key, required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(incomeNotifierProvider(month.monthKey));

    return Scaffold(
      body: SafeArea(
        child: switch (state) {
          IncomeLoading()      => const _LoadingView(),
          IncomeError(:final message) => _ErrorView(message: message),
          IncomeLoaded()       => _IncomeContent(state: state, month: month),
        },
      ),
    );
  }
}

// ─── Loading ───────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: AppColors.accent),
  );
}

// ─── Error ─────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.popScreen(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    ),
  );
}

// ─── Loaded ────────────────────────────────────────────────
class _IncomeContent extends ConsumerWidget {
  final IncomeLoaded state;
  final DateTime month;
  const _IncomeContent({required this.state, required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show error banner if exists
    ref.listen(
      incomeNotifierProvider(month.monthKey),
      (_, next) {
        if (next is IncomeLoaded && next.saveError != null) {
          context.showSnack(next.saveError!, color: AppColors.error);
          ref.read(incomeNotifierProvider(month.monthKey).notifier).clearError();
        }
        if (next is IncomeLoaded && next.saveSuccess) {
          context.showSnack('✅ تم حفظ الدخل', color: AppColors.success);
        }
      },
    );

    return CustomScrollView(
      slivers: [
        _IncomeAppBar(month: month, isSaving: state.isSaving),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              IncomeForm(
                income: state.income,
                onSave: (p, s, e) => ref
                    .read(incomeNotifierProvider(month.monthKey).notifier)
                    .save(primaryRaw: p, secondaryRaw: s, extraRaw: e),
              ),
              const SizedBox(height: 8),
              IncomeSummaryCard(income: state.income),
              const SizedBox(height: 8),
              IncomeSavingsTip(income: state.income),
            ]),
          ),
        ),
      ],
    );
  }
}

class _IncomeAppBar extends ConsumerWidget {
  final DateTime month;
  final bool     isSaving;
  const _IncomeAppBar({required this.month, required this.isSaving});

  @override
  Widget build(BuildContext context, WidgetRef ref) => SliverAppBar(
    pinned: true,
    title: Column(
      children: [
        Text('💰 الدخل الشهري', style: AppTextStyles.title),
        Text(month.monthAr,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
      ],
    ),
    actions: [
      if (isSaving)
        const Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentAlt),
          ),
        ),
      IconButton(
        icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        onPressed: () {
          // previous month
        },
      ),
      IconButton(
        icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
        onPressed: () {
          // next month — guard: no future months
          final now = DateTime.now();
          if (month.year > now.year || (month.year == now.year && month.month >= now.month)) return;
        },
      ),
    ],
  );
}
