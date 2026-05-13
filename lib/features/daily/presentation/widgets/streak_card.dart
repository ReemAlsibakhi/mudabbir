import '../../../../core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../presentation/providers/daily_notifier.dart';

class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    if (streak.count == 0) return _EmptyStreak(ref: ref);
    return _ActiveStreak(streak: streak, ref: ref);
  }
}

class _ActiveStreak extends StatelessWidget {
  final dynamic streak;
  final WidgetRef ref;
  const _ActiveStreak({required this.streak, required this.ref});

  @override
  Widget build(BuildContext context) {
    final badge   = streak.badgeLabel;
    final tokens  = streak.rescueTokens as int;
    final atRisk  = streak.isAtRisk as bool;
    final count   = streak.count as int;

    // 🎉 Milestone celebration
    final milestone = _milestone(count);

    return Container(
      margin:  const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: [Color(0xFF1C1500), Color(0xFF110D00)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: atRisk
              ? AppColors.error.withOpacity(0.4)
              : AppColors.gold.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 0),
            child: Row(
              children: [
                // Flame icon
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color:        AppColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(13),
                    border:       Border.all(color: AppColors.gold.withOpacity(0.15)),
                  ),
                  child: Center(
                    child: Text(
                      atRisk ? '⚠️' : '🔥',
                      style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: '$count',
                            style: const TextStyle(
                              fontFamily: 'Cairo', fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFCD34D),
                              letterSpacing: -0.5),
                          ),
                          TextSpan(
                            text: AppStrings.streakDaysSuffix,
                            style: TextStyle(
                              fontFamily: 'Cairo', fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.goldLight.withOpacity(0.6)),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        atRisk
                            ? AppStrings.streakAtRisk
                            : streak.statusMessage as String,
                        style: TextStyle(
                          fontFamily: 'Cairo', fontSize: 11,
                          color: atRisk
                              ? AppColors.error.withOpacity(0.8)
                              : AppColors.gold.withOpacity(0.55)),
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
                    child: Text(badge,
                      style: const TextStyle(
                        fontFamily: 'Cairo', fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFCD34D)),
                    ),
                  ),
              ],
            ),
          ),

          // ✅ Milestone celebration bar
          if (milestone != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:        AppColors.gold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border:       Border.all(color: AppColors.gold.withOpacity(0.15)),
              ),
              child: Text(milestone,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFCD34D)),
              ),
            ),

          // ✅ Rescue Token button — shown when at risk AND has tokens
          if (atRisk && tokens > 0)
            GestureDetector(
              onTap: () async {
                final ok = await ref.read(streakProvider.notifier).useRescueToken();
                if (context.mounted) {
                  context.showSnack(
                    ok
                        ? '🛡️ ${AppStrings.streakRescuedSuccess}'
                        : AppStrings.streakNoTokens,
                    color: ok ? AppColors.success : AppColors.error,
                  );
                }
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    Color(0xFFF59E0B), Color(0xFFD97706)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '🛡️ ${AppStrings.streakRescueBtn} ($tokens ${AppStrings.streakTokensLeft})',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
                ),
              ),
            )
          else
            const SizedBox(height: 12),
        ],
      ),
    );
  }

  String? _milestone(int count) {
    if (count == 7)   return '🎉 ${AppStrings.milestone7}';
    if (count == 30)  return '🏆 ${AppStrings.milestone30}';
    if (count == 100) return '👑 ${AppStrings.milestone100}';
    return null;
  }
}

class _EmptyStreak extends StatelessWidget {
  final WidgetRef ref;
  const _EmptyStreak({required this.ref});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color:        AppColors.surface2,
      borderRadius: BorderRadius.circular(14),
      border:       Border.all(color: AppColors.border),
    ),
    child: Row(children: [
      const Text('🔥', style: TextStyle(fontSize: 20)),
      const SizedBox(width: 10),
      Text(AppStrings.streakStart,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textTertiary, fontSize: 13)),
    ]),
  );
}
