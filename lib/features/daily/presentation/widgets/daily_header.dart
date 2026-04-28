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
    final name     = profile?.name.trim() ?? '';
    final greeting = _greeting(date.hour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Date line
        Text(
          date.dayFullAr,
          style: AppTextStyles.caption.copyWith(
            color:    AppColors.textSecondary.withOpacity(0.65),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 3),
        // Greeting + name — both forced RTL so English name stays on correct side
        RichText(
          textDirection: TextDirection.rtl,
          text: TextSpan(
            style: AppTextStyles.headline2.copyWith(fontSize: 19),
            children: [
              TextSpan(
                text:  '$greeting، ',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              if (name.isNotEmpty)
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline:  TextBaseline.alphabetic,
                  child: ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF34D399)],
                    ).createShader(b),
                    child: Text(
                      name,
                      // Force same direction as parent so name
                      // stays visually connected to greeting
                      textDirection: TextDirection.rtl,
                      style: AppTextStyles.headline2.copyWith(
                        fontSize: 19,
                        color:    Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 1),
        // Subtitle
        Text(
          'سجّل مصاريفك في 30 ثانية 👇',
          style: AppTextStyles.caption.copyWith(
            color:    AppColors.textSecondary.withOpacity(0.55),
            fontSize: 11,
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
