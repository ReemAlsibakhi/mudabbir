import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_gradient_button.dart';
import '../providers/onboarding_notifier.dart';

class BudgetSetupStep extends ConsumerStatefulWidget {
  const BudgetSetupStep({super.key});
  @override
  ConsumerState<BudgetSetupStep> createState() => _State();
}

class _State extends ConsumerState<BudgetSetupStep> {
  final _primaryCtrl   = TextEditingController();
  final _secondaryCtrl = TextEditingController();
  final _extraCtrl     = TextEditingController();

  @override
  void dispose() {
    _primaryCtrl.dispose(); _secondaryCtrl.dispose(); _extraCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final draft    = state.draft;
    final country  = getCountryById(draft.countryId);
    final hasPartner = draft.lifeStage.hasPartner;

    final totalIncome = (double.tryParse(_primaryCtrl.text) ?? 0) +
        (double.tryParse(_secondaryCtrl.text) ?? 0) +
        (double.tryParse(_extraCtrl.text) ?? 0);

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💰 ما دخلك الشهري؟', style: AppTextStyles.headline2),
            const SizedBox(height: 6),
            Text('سنوزع ميزانيتك تلقائياً — يمكنك تعديلها لاحقاً',
              style: AppTextStyles.body),
            const SizedBox(height: 20),

            _IncomeField(
              label:      '${draft.lifeStage.incomeLabel1}',
              hint:       'مثال: 8000 ${country.currency}',
              controller: _primaryCtrl,
              onChanged:  (_) => _updateIncome(),
            ),
            if (hasPartner) ...[
              const SizedBox(height: 12),
              _IncomeField(
                label:      'دخل الزوجة (اختياري)',
                hint:       '0',
                controller: _secondaryCtrl,
                onChanged:  (_) => _updateIncome(),
              ),
            ],
            const SizedBox(height: 12),
            _IncomeField(
              label:      'دخل إضافي (مكافآت، إيجارات...)',
              hint:       '0',
              controller: _extraCtrl,
              onChanged:  (_) => _updateIncome(),
            ),

            if (totalIncome > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:        AppColors.success.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border:       Border.all(color: AppColors.success.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('إجمالي الدخل الشهري',
                      style: AppTextStyles.caption),
                    Text('${totalIncome.toStringAsFixed(0)} ${country.currency}',
                      style: AppTextStyles.headline2.copyWith(color: AppColors.success)),
                    const SizedBox(height: 6),
                    Text(
                      'هدف الادخار الموصى به (20%) = '
                      '${(totalIncome * 0.2).toStringAsFixed(0)} ${country.currency}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.accentAlt),
                    ),
                  ],
                ),
              ),
            ],

            if (state.error != null) ...[
              const SizedBox(height: 8),
              Text(state.error!,
                style: AppTextStyles.caption.copyWith(color: AppColors.error)),
            ],
            const SizedBox(height: 16),

            MudGradientButton(
              label:   '🚀 ابدأ مع مدبّر',
              onTap:   _complete,
              loading: state.isSaving,
            ),

            // Skip budget — allowed
            const SizedBox(height: 8),
            GestureDetector(
              onTap: state.isSaving ? null : _completeWithoutBudget,
              child: Center(
                child: Text('تخطى الآن — سأضيفه لاحقاً',
                  style: AppTextStyles.caption),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateIncome() {
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    notifier.setIncome(
      primary:   double.tryParse(_primaryCtrl.text)   ?? 0,
      secondary: double.tryParse(_secondaryCtrl.text) ?? 0,
      extra:     double.tryParse(_extraCtrl.text)     ?? 0,
    );
  }

  Future<void> _complete() async {
    _updateIncome();
    await ref.read(onboardingNotifierProvider.notifier).complete();
  }

  Future<void> _completeWithoutBudget() async {
    ref.read(onboardingNotifierProvider.notifier).setIncome(primary: 0);
    await ref.read(onboardingNotifierProvider.notifier).complete();
  }
}

class _IncomeField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _IncomeField({
    required this.label, required this.hint,
    required this.controller, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        onChanged:  onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textDirection: TextDirection.rtl,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,٠-٩٫]'))],
        style: AppTextStyles.body.copyWith(color: AppColors.textPrimary, fontSize: 16),
        decoration: InputDecoration(hintText: hint),
      ),
    ],
  );
}
