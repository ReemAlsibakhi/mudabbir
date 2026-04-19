import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../onboarding/presentation/providers/onboarding_notifier.dart';

class DailyHeader extends ConsumerWidget {
  final DateTime date;
  const DailyHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile  = ref.watch(onboardingRepoProvider).getSaved();
    final name     = profile?.name ?? '';
    final greeting = _greeting(date.hour);

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date.dayFullAr,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary.withOpacity(0.7),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: AppTextStyles.headline1.copyWith(letterSpacing: -0.5),
              children: [
                TextSpan(text: '$greeting، '),
                WidgetSpan(
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF06D6A0)],
                    ).createShader(bounds),
                    child: Text(
                      name,
                      style: AppTextStyles.headline1.copyWith(
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'سجّل مصاريفك في 30 ثانية 👇',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(int hour) {
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مرحباً';
    return 'مساء الخير';
  }
}
