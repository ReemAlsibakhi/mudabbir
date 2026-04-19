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
    if (streak.count == 0) return const _EmptyStreak();
    return _ActiveStreak(streak: streak);
  }
}

class _ActiveStreak extends StatelessWidget {
  final streak;
  const _ActiveStreak({required this.streak});

  @override
  Widget build(BuildContext context) {
    final badge = streak.badgeLabel;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: [Color(0xFF1C1500), Color(0xFF110D00)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Flame icon box
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color:        AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
              border:       Border.all(color: AppColors.gold.withOpacity(0.15)),
            ),
            child: const Center(
              child: Text('🔥', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${streak.count}',
                        style: const TextStyle(
                          fontFamily: 'Cairo', fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFCD34D),
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextSpan(
                        text: '  يوم متواصل',
                        style: TextStyle(
                          fontFamily: 'Cairo', fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.goldLight.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  streak.statusMessage,
                  style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 11,
                    color: AppColors.gold.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
          // Badge
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color:        AppColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
                border:       Border.all(color: AppColors.gold.withOpacity(0.2)),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFCD34D),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyStreak extends StatelessWidget {
  const _EmptyStreak();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color:        AppColors.surface2,
      borderRadius: BorderRadius.circular(14),
      border:       Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        const Text('🔥', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Text(
          'ابدأ سلسلتك اليوم!',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textTertiary, fontSize: 13),
        ),
      ],
    ),
  );
}
