import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_card.dart';
import '../../../../shared/ui/widgets/mud_empty_view.dart';
import '../../../../shared/ui/widgets/mud_progress_bar.dart';
import '../../../goals/presentation/providers/goals_notifier.dart';
import '../../../goals/presentation/providers/goals_state.dart';

class GoalsReportTab extends ConsumerWidget {
  const GoalsReportTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalsNotifierProvider);

    return switch (state) {
      GoalsLoading() => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
      GoalsError(:final message) => MudEmptyView(icon: '⚠️', title: message),
      GoalsLoaded() => _GoalsContent(state: state),
    };
  }
}

class _GoalsContent extends StatelessWidget {
  final GoalsLoaded state;
  const _GoalsContent({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isEmpty) {
      return const MudEmptyView(
        icon:     '🎯',
        title:    'لا توجد أهداف بعد',
        subtitle: 'أضف أهدافاً مالية لتتبع تقدمها هنا',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // Summary header
        MudCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SummaryItem(
                    icon:  '🎯',
                    label: 'أهداف نشطة',
                    value: '${state.activeGoals.length}',
                    color: AppColors.accentAlt,
                  ),
                  _SummaryItem(
                    icon:  '✅',
                    label: 'مكتملة',
                    value: '${state.doneGoals.length}',
                    color: AppColors.success,
                  ),
                  _SummaryItem(
                    icon:  '💰',
                    label: 'إجمالي مدخر',
                    value: state.totalSaved.fmt(),
                    color: AppColors.warning,
                  ),
                ],
              ),
              if (state.totalTarget > 0) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('التقدم الكلي', style: AppTextStyles.caption),
                    Text(
                      '${(state.totalSaved / state.totalTarget * 100).toStringAsFixed(1)}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                MudProgressBar(
                  value: (state.totalSaved / state.totalTarget).clamp(0, 1),
                  color: AppColors.success, height: 8,
                ),
              ],
            ],
          ),
        ),

        // All goals list
        ...state.goals.map((g) {
          final monthsLeft = g.monthsLeft;
          return MudCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(g.type.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.name, style: AppTextStyles.bodyBold,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(g.type.nameAr, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (g.isCompleted ? AppColors.success : AppColors.accent)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        g.isCompleted ? '✅ مكتمل' : '${(g.progress * 100).toStringAsFixed(0)}%',
                        style: AppTextStyles.caption.copyWith(
                          color: g.isCompleted ? AppColors.success : AppColors.accentAlt,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                MudProgressBar(
                  value: g.progress,
                  color: g.isCompleted ? AppColors.success : AppColors.accent,
                  height: 7,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${g.saved.fmt()} مدخر',
                      style: AppTextStyles.caption.copyWith(color: AppColors.success)),
                    Text('من ${g.target.fmt()}',
                      style: AppTextStyles.caption),
                  ],
                ),
                if (!g.isCompleted && monthsLeft != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '💡 بمعدلك الحالي: $monthsLeft شهر للوصول للهدف',
                    style: AppTextStyles.caption.copyWith(color: AppColors.accentAlt),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String icon, label, value;
  final Color  color;
  const _SummaryItem({
    required this.icon, required this.label,
    required this.value, required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(icon, style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 3),
      Text(value,
        style: AppTextStyles.subtitle.copyWith(color: color, fontSize: 17)),
      Text(label, style: AppTextStyles.caption),
    ],
  );
}
