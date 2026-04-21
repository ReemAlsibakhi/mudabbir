import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../onboarding/domain/entities/onboarding_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_notifier.dart';

class SuggestedQuestions extends ConsumerWidget {
  final ValueChanged<String> onTap;
  const SuggestedQuestions({super.key, required this.onTap});

  static List<String> _questions(LifeStage stage) => switch (stage) {
    LifeStage.single => [
      'كيف أوزع راتبي بذكاء؟',
      'كم أحتاج لصندوق الطوارئ؟',
      'ما أفضل هدف ادخار لي الآن؟',
      'كيف أبدأ في الاستثمار؟',
    ],
    LifeStage.engaged => [
      'كيف نخطط لميزانية الزفاف؟',
      'ما المبلغ المناسب للشبكة؟',
      'كيف نبدأ حياتنا المالية صح؟',
      'كم نحتاج قبل الزواج؟',
    ],
    LifeStage.married => [
      'كيف نوزع الدخل المشترك؟',
      'هل وضعنا المالي جيد هذا الشهر؟',
      'ما أكبر بند مصروف يمكن تقليله؟',
      'كيف نوفر أكثر كزوجين؟',
    ],
    LifeStage.family => [
      'كيف نوفر لتعليم الأطفال؟',
      'هل ميزانية الأسرة متوازنة؟',
      'ما المبلغ الكافي لصندوق الطوارئ؟',
      'كيف نقلل مصاريف المطاعم؟',
    ],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(onboardingRepoProvider).getSaved();
    final stage   = profile?.lifeStage ?? LifeStage.single;
    final qs      = _questions(stage);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('أسئلة مقترحة', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: qs.map((q) => GestureDetector(
              onTap: () => onTap(q),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:        AppColors.surface2,
                  borderRadius: BorderRadius.circular(20),
                  border:       Border.all(color: AppColors.borderMid),
                ),
                child: Text(q,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
