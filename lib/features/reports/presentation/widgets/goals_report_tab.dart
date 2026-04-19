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
    if (state is! GoalsLoaded || state.isEmpty) {
      return const MudEmptyView(icon:'🎯', title:'لا توجد أهداف بعد');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MudCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const MudSectionLabel('إجمالي مدخرات الأهداف'),
            Text(state.totalSaved.fmt(),
              style: AppTextStyles.headline1.copyWith(color: AppColors.success)),
            Text('من ${state.totalTarget.fmt()} (${state.goals.length} هدف)',
              style: AppTextStyles.body),
            const SizedBox(height: 10),
            MudProgressBar(
              value:  state.totalTarget > 0 ? state.totalSaved / state.totalTarget : 0,
              color:  AppColors.success, height: 9),
          ]),
        ),
        ...state.goals.map((g) => MudCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(g.type.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(child: Text(g.name, style: AppTextStyles.bodyBold,
                maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text('${(g.progress * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.bodyBold.copyWith(color: AppColors.accentAlt)),
            ]),
            const SizedBox(height: 8),
            MudProgressBar(value: g.progress, color: AppColors.accent),
            const SizedBox(height: 6),
            Text('${g.saved.fmt()} / ${g.target.fmt()}'
              '${g.monthsLeft != null ? " · ${g.monthsLeft} شهر متبقي" : ""}',
              style: AppTextStyles.caption),
          ]),
        )),
      ],
    );
  }
}
