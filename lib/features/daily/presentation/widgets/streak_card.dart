import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../presentation/providers/daily_notifier.dart';

class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);

    return Container(
      margin:  const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.warning.withOpacity(0.12),
          AppColors.orange.withOpacity(0.06),
        ]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          _FlameIcon(isAtRisk: streak.isAtRisk),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('${streak.count}',
                    style: AppTextStyles.headline2.copyWith(color: AppColors.warning)),
                  const SizedBox(width: 6),
                  Text('يوم متواصل', style: AppTextStyles.body),
                ]),
                Text(streak.statusMessage, style: AppTextStyles.caption),
                if (streak.bestCount > 0 && streak.bestCount != streak.count)
                  Text('أفضل سلسلة: ${streak.bestCount} يوم',
                    style: AppTextStyles.label),
              ],
            ),
          ),
          if (streak.badgeLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning, borderRadius: BorderRadius.circular(99)),
              child: Text(streak.badgeLabel!,
                style: AppTextStyles.label.copyWith(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}

class _FlameIcon extends StatefulWidget {
  final bool isAtRisk;
  const _FlameIcon({required this.isAtRisk});
  @override State<_FlameIcon> createState() => _FlameState();
}
class _FlameState extends State<_FlameIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => ScaleTransition(
    scale: _anim,
    child: Text(widget.isAtRisk ? '⚠️' : '🔥',
      style: const TextStyle(fontSize: 30)),
  );
}
