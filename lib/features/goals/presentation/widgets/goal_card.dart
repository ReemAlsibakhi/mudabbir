import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_card.dart';
import '../../../../shared/ui/widgets/mud_gradient_button.dart';
import '../providers/goals_notifier.dart';
import '../../domain/entities/goal.dart';
import '../../domain/usecases/add_savings_usecase.dart';

class GoalCard extends ConsumerStatefulWidget {
  final Goal goal;
  const GoalCard({super.key, required this.goal});

  @override
  ConsumerState<GoalCard> createState() => _State();
}

class _State extends ConsumerState<GoalCard> {
  final _ctrl = TextEditingController();
  bool _adding = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final g     = widget.goal;
    final color = g.isCompleted ? AppColors.success : AppColors.accent;

    return MudCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(g.type.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.name, style: AppTextStyles.subtitle),
                    Text(g.type.nameAr, style: AppTextStyles.caption),
                  ],
                ),
              ),
              if (!g.isCompleted)
                GestureDetector(
                  onTap: () => ref.read(goalsNotifierProvider.notifier).deleteGoal(g.id),
                  child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.textTertiary),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value:          g.progress,
              minHeight:      9,
              backgroundColor: AppColors.surface3,
              valueColor:     AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('مدخر: ${g.saved.fmt()} ريال',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              Text('${(g.progress * 100).toStringAsFixed(1)}%',
                style: AppTextStyles.bodyBold.copyWith(color: color)),
              Text('الهدف: ${g.target.fmt()} ريال', style: AppTextStyles.caption),
            ],
          ),

          // Insight
          if (!g.isCompleted) ...[
            const SizedBox(height: 10),
            _GoalInsight(goal: g),
          ] else
            _CompletedBanner(goalName: g.name),

          // Add savings
          if (!g.isCompleted) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:   _ctrl,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                    decoration: const InputDecoration(hintText: 'أضف مبلغ للهدف'),
                  ),
                ),
                const SizedBox(width: 8),
                MudGradientButton(
                  label:   'إضافة',
                  width:   80,
                  loading: _adding,
                  onTap:   _addSavings,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addSavings() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _adding = true);

    await ref.read(goalsNotifierProvider.notifier).addSavings(
      AddSavingsParams(goalId: widget.goal.id, amountRaw: _ctrl.text),
    );

    if (mounted) {
      _ctrl.clear();
      setState(() => _adding = false);
    }
  }
}

class _GoalInsight extends StatelessWidget {
  final Goal goal;
  const _GoalInsight({required this.goal});

  @override
  Widget build(BuildContext context) {
    final lines = <String>[];
    lines.add('💡 المتبقي: ${goal.remaining.toStringAsFixed(0)} ريال');
    if (goal.monthsLeft > 0) lines.add('⏱️ بمعدلك الحالي: ${goal.monthsLeft} شهر');
    // What-if: save 50% more per month
    if (goal.hasMonthlyPlan) {
      final faster = goal.monthsLeftWith(goal.monthlyTarget * 0.5);
      if (faster < goal.monthsLeft) {
        lines.add('⚡ لو زدت 50% شهرياً: $faster شهر فقط!');
      }
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:        AppColors.accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(9),
        border:       Border.all(color: AppColors.accent.withOpacity(0.12)),
      ),
      child: Text(lines.join('\n'),
        style: AppTextStyles.caption.copyWith(
          color:  AppColors.textSecondary, height: 1.7)),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  final String goalName;
  const _CompletedBanner({required this.goalName});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color:        AppColors.success.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      border:       Border.all(color: AppColors.success.withOpacity(0.2)),
    ),
    child: const Center(
      child: Text('🎉 تم تحقيق الهدف! مبروك!',
        style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700,
          color: AppColors.success)),
    ),
  );
}
