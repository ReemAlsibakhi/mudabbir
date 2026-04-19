import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/onboarding_notifier.dart';

class NameStep extends ConsumerStatefulWidget {
  const NameStep({super.key});
  @override
  ConsumerState<NameStep> createState() => _State();
}

class _State extends ConsumerState<NameStep> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(onboardingNotifierProvider).draft.name;
    _ctrl = TextEditingController(text: existing);
    _ctrl.addListener(() =>
        ref.read(onboardingNotifierProvider.notifier).setName(_ctrl.text));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('👋 ما اسمك؟', style: AppTextStyles.headline2),
          const SizedBox(height: 6),
          Text('سنناديك به في كل رسائل مدبّر', style: AppTextStyles.body),
          const SizedBox(height: 28),
          TextField(
            controller: _ctrl,
            autofocus:  true,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.headline2,
            decoration: const InputDecoration(
              hintText: 'مثال: خالد أو نورة',
              hintStyle: TextStyle(fontFamily: 'Cairo', color: AppColors.textTertiary, fontSize: 20),
            ),
          ),
          const Spacer(),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(state.error!,
                style: AppTextStyles.caption.copyWith(color: AppColors.error)),
            ),
          Row(
            children: [
              IconButton(
                onPressed: notifier.prevStep,
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: state.canProceedFromName ? notifier.nextStep : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient:     state.canProceedFromName ? AppColors.primary : null,
                      color:        state.canProceedFromName ? null : AppColors.surface3,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('التالي ←', textAlign: TextAlign.center,
                      style: AppTextStyles.button.copyWith(
                        color: state.canProceedFromName ? Colors.white : AppColors.textTertiary)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
