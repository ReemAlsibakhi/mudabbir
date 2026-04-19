import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/providers/user_provider.dart';

class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (user) {
        final count = user?.streakCount ?? 0;
        final best = int.tryParse(user?.bestStreak ?? '0') ?? 0;
        final msg = _streakMessage(count);
        final badge = _streakBadge(count);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gold.withOpacity(0.12), AppColors.orange.withOpacity(0.06)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gold.withOpacity(0.22)),
          ),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('$count',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                            color: AppColors.gold, fontFamily: 'Cairo')),
                        const SizedBox(width: 6),
                        const Text('يوم متواصل',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                      ],
                    ),
                    Text(msg,
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontFamily: 'Cairo')),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badge['color'],
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(badge['label']!,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: Colors.white, fontFamily: 'Cairo')),
                ),
            ],
          ),
        );
      },
    );
  }

  String _streakMessage(int count) {
    if (count == 0) return 'ابدأ سلسلتك اليوم!';
    if (count < 7) return 'استمر! ${count} أيام متواصلة 💪';
    if (count < 30) return 'رائع! أنت من أفضل المستخدمين 🌟';
    return 'أسطوري! $count يوم بدون انقطاع 🏆';
  }

  Map<String, dynamic>? _streakBadge(int count) {
    if (count >= 30) return {'label': '🏆 أسطوري', 'color': AppColors.gold};
    if (count >= 7)  return {'label': '⭐ متميز',  'color': AppColors.accent};
    return null;
  }
}
