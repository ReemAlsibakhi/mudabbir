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

class IncomeScreen extends ConsumerStatefulWidget {
  final DateTime month;
  const IncomeScreen({super.key, required this.month});

  @override
  ConsumerState<IncomeScreen> createState() => _State();
}

class _State extends ConsumerState<IncomeScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = widget.month;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(incomeNotifierProvider(_month.monthKey));

    ref.listen(incomeNotifierProvider(_month.monthKey), (_, next) {
      if (!mounted) return;
      if (next is IncomeLoaded && next.saveError != null) {
        context.showSnack(next.saveError!, color: AppColors.error);
        ref.read(incomeNotifierProvider(_month.monthKey).notifier).clearError();
      }
      if (next is IncomeLoaded && next.saveSuccess) {
        context.showSnack('✅ تم حفظ الدخل', color: AppColors.success);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: switch (state) {
          IncomeLoading()                => const _LoadingView(),
          IncomeError(:final message)    => _ErrorView(message: message),
          IncomeLoaded()                 => _IncomeContent(
              state: state,
              month: _month,
              onPrev: () => setState(() => _month = _month.prevMonth()),
              onNext: () {
                final now = DateTime.now();
                if (_month.year == now.year && _month.month >= now.month) return;
                setState(() => _month = _month.nextMonth());
              },
              onSave: (p, s, e) => ref
                  .read(incomeNotifierProvider(_month.monthKey).notifier)
                  .save(primaryRaw: p, secondaryRaw: s, extraRaw: e),
            ),
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
          Text(message, textAlign: TextAlign.center, style: AppTextStyles.body),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('رجوع'),
          ),
        ],
      ),
    ),
  );
}

// ─── Content ───────────────────────────────────────────────
class _IncomeContent extends StatelessWidget {
  final IncomeLoaded state;
  final DateTime     month;
  final VoidCallback onPrev, onNext;
  final void Function(String, String, String) onSave;

  const _IncomeContent({
    required this.state,  required this.month,
    required this.onPrev, required this.onNext,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      // ── AppBar with BACK button ──────────────────────
      SliverAppBar(
        pinned:      true,
        // ✅ Leading = back button (goes to previous screen)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Text('💰 الدخل الشهري', style: AppTextStyles.title),
            Text(month.monthAr,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          // ✅ Month navigation — prev/next
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary),
            tooltip: 'الشهر السابق',
            onPressed: onPrev,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded,
              color: AppColors.textSecondary),
            tooltip: 'الشهر التالي',
            onPressed: onNext,
          ),
          if (state.isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.accentAlt),
              ),
            ),
        ],
      ),
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            IncomeForm(income: state.income, onSave: onSave),
            const SizedBox(height: 8),
            IncomeSummaryCard(income: state.income),
            const SizedBox(height: 8),
            IncomeSavingsTip(income: state.income),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    ],
  );
}
