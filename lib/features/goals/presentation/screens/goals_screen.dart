import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/widgets.dart';
import '../providers/goals_notifier.dart';
import '../providers/goals_state.dart';
import '../widgets/goal_card.dart';
import '../widgets/add_goal_sheet.dart';
import '../widgets/goal_completion_overlay.dart';
import '../widgets/goals_summary.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalsNotifierProvider);

    // Error listener
    ref.listen(goalsNotifierProvider, (_, next) {
      if (next is GoalsLoaded && next.errorMessage != null) {
        context.showSnack(next.errorMessage!, color: AppColors.error);
        ref.read(goalsNotifierProvider.notifier).clearError();
      }
    });

    // Completion listener
    ref.listen(goalsNotifierProvider, (_, next) {
      if (next is GoalsLoaded && next.justCompletedGoalId != null) {
        final goal = next.goals
            .where((g) => g.id == next.justCompletedGoalId)
            .firstOrNull;
        if (goal != null && context.mounted) {
          GoalCompletionOverlay.show(context, goal);
          ref.read(goalsNotifierProvider.notifier).clearCompletion();
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: switch (state) {
          GoalsLoading() => const MudLoadingView(),
          GoalsError(:final message) => MudErrorView(message: message),
          GoalsLoaded() => _GoalsContent(state: state),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        onPressed:       () => AddGoalSheet.show(context, ref),
        icon:            const Icon(Icons.add, color: Colors.white),
        label:           Text('هدف جديد', style: AppTextStyles.button.copyWith(fontSize: 13)),
      ),
    );
  }
}

class _GoalsContent extends ConsumerWidget {
  final GoalsLoaded state;
  const _GoalsContent({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isEmpty) {
      return MudEmptyView(
        icon:     '🎯',
        title:    'لا توجد أهداف بعد',
        subtitle: 'أضف هدفك الأول وابدأ رحلة التوفير',
        action:   ElevatedButton(
          onPressed: () => AddGoalSheet.show(context, ref),
          child: const Text('أضف هدفك الأول'),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🎯 الأهداف المالية', style: AppTextStyles.headline2),
                const SizedBox(height: 12),
                GoalsSummary(
                  totalSaved:  state.totalSaved,
                  totalTarget: state.totalTarget,
                  activeCount: state.activeGoals.length,
                  doneCount:   state.doneGoals.length,
                ),
              ],
            ),
          ),
        ),
        // Active goals
        if (state.activeGoals.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount:    state.activeGoals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 0),
              itemBuilder:  (_, i) => GoalCard(goal: state.activeGoals[i]),
            ),
          ),
        // Completed goals
        if (state.doneGoals.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text('✅ مكتملة',
                style: AppTextStyles.label.copyWith(color: AppColors.success)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList.separated(
              itemCount: state.doneGoals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 0),
              itemBuilder: (_, i) => GoalCard(
                goal:      state.doneGoals[i],
                completed: true,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
