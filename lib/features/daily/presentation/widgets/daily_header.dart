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
    final profile = ref.watch(onboardingRepoProvider).getSaved();
    final name    = profile?.name ?? '';
    final hour    = date.hour;
    final greeting = hour < 12 ? 'صباح الخير،'
                   : hour < 17 ? 'مرحباً،'
                   : 'مساء الخير،';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(date.dayFullAr,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: AppTextStyles.headline2,
            children: [
              TextSpan(text: '$greeting '),
              TextSpan(
                text: name,
                style: AppTextStyles.headline2.copyWith(
                  foreground: Paint()..shader = const LinearGradient(
                    colors: [AppColors.accentAlt, AppColors.accentGreen],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 40)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text('سجّل مصاريف اليوم في 30 ثانية 👇',
          style: AppTextStyles.body),
      ],
    );
  }
}
