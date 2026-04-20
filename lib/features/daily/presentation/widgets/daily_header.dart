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
    final name     = profile?.name.isNotEmpty == true ? profile!.name : '';
    final greeting = _greeting(date.hour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date.dayFullAr,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary.withOpacity(0.65),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        // Simple approach: two Text widgets side by side in a Wrap
        Wrap(
          children: [
            Text(
              '$greeting، ',
              style: AppTextStyles.headline2.copyWith(
                color: AppColors.textPrimary,
                fontSize: 20,
              ),
            ),
            if (name.isNotEmpty)
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF38BDF8), Color(0xFF34D399)],
                ).createShader(bounds),
                child: Text(
                  name,
                  style: AppTextStyles.headline2.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'سجّل مصاريفك في 30 ثانية 👇',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary.withOpacity(0.55),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _greeting(int hour) {
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مرحباً';
    return 'مساء الخير';
  }
}
