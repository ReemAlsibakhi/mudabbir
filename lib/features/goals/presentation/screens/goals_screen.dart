import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/goals_notifier.dart';
import '../providers/goals_state.dart';
import '../widgets/goal_card.dart';
import '../widgets/add_goal_sheet.dart';
import '../widgets/goal_celebration.dart';
import '../../../../shared/ui/widgets/widgets.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalsNotifierProvider);

    // Error + celebration listeners
    ref.listen(goalsNotifierProvider, (_, next) {
      if (next is GoalsLoaded) {
        if (next.error != null) {
          context.showSnack(next.error!, color: AppColors.error);
          ref.read(goalsNotifierProvider.notifier).clearError();
        }
        if (next.completedGoalId != null) {
          final goal = next.goals.firstWhere((g) => g.id == next.completedGoalId, orElse: () => next.goals.first);
          GoalCelebration.show(context, goal.name, goal.type.icon);
          ref.read(goalsNotifierProvider.notifier).clearCompletedGoal();
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: switch (state) {
          GoalsLoading() => const MudLoadingView(message: 'جارٍ تحميل الأهداف...'),
          GoalsError(:final message) => MudErrorView(
              message: message,
              onRetry: () => ref.invalidate(goalsNotifierProvider),
            ),
          GoalsLoaded() => _LoadedContent(state: state),
        },
      ),
      floatingActionButton: state is GoalsLoaded
          ? FloatingActionButton(
              backgroundColor: AppColors.accent,
              onPressed: () => AddGoalSheet.show(context, ref),
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final GoalsLoaded state;
  const _LoadedContent({required this.state});

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🎯 الأهداف المالية', style: AppTextStyles.headline2),
              if (state.goals.isNotEmpty) ...[
                const SizedBox(height: 8),
                _OverallProgress(state: state),
              ],
            ],
          ),
        ),
      ),
      state.isEmpty
          ? SliverFillRemaining(
              child: MudEmptyView(
                icon:     '🎯',
                title:    'لا توجد أهداف بعد',
                subtitle: 'أضف هدفك الأول — منزل، سيارة، إجازة...',
                action:   Builder(
                  builder: (ctx) => ElevatedButton(
                    onPressed: () => AddGoalSheet.show(ctx, null),
                    child: const Text('أضف هدفك الأول'),
                  ),
                ),
              ),
            )
          : SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => GoalCard(goal: state.goals[i]),
                  childCount: state.goals.length,
                ),
              ),
            ),
    ],
  );
}

class _OverallProgress extends StatelessWidget {
  final GoalsLoaded state;
  const _OverallProgress({required this.state});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color:        AppColors.surface2,
      borderRadius: BorderRadius.circular(13),
      border:       Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('إجمالي المدخر', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(
                '${state.totalSaved.toStringAsFixed(0)} ريال',
                style: AppTextStyles.amount.copyWith(fontSize: 18, color: AppColors.success),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value:          state.overallProgress.clamp(0.0, 1.0),
                  minHeight:      7,
                  backgroundColor: AppColors.surface3,
                  valueColor:     const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${(state.overallProgress * 100).toStringAsFixed(0)}%',
              style: AppTextStyles.headline2.copyWith(color: AppColors.accentAlt)),
            Text('${state.activeGoals.length} هدف نشط', style: AppTextStyles.caption),
          ],
        ),
      ],
    ),
  );
}
