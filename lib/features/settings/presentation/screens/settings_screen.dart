import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_card.dart';
import '../../../onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../../onboarding/presentation/providers/onboarding_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(onboardingRepoProvider).getSaved();
    final country = profile != null ? getCountryById(profile.countryId) : kCountries.first;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('⚙️ الإعدادات', style: AppTextStyles.headline2),
            const SizedBox(height: 16),

            // Profile card
            if (profile != null)
              MudCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MudSectionLabel('ملفك الشخصي'),
                    _InfoRow(label: '👤 الاسم',     value: profile.name),
                    _InfoRow(label: '🌍 الدولة',    value: '${country.flag} ${country.nameAr} (${country.currency})'),
                    _InfoRow(label: '👥 مرحلة الحياة', value: '${profile.lifeStage.icon} ${profile.lifeStage.nameAr}'),
                  ],
                ),
              ),

            // Countries
            MudCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MudSectionLabel('🌍 تغيير الدولة'),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 8,
                      crossAxisSpacing: 8, childAspectRatio: 2.8,
                    ),
                    itemCount: kCountries.length,
                    itemBuilder: (_, i) {
                      final c   = kCountries[i];
                      final sel = c.id == (profile?.countryId ?? 'sa');
                      return GestureDetector(
                        onTap: () => _changeCountry(context, ref, c.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color:        sel ? AppColors.accent.withOpacity(0.12) : AppColors.surface2,
                            borderRadius: BorderRadius.circular(9),
                            border:       Border.all(
                              color: sel ? AppColors.accent : AppColors.border,
                              width: sel ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(c.flag, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(c.nameAr,
                                  style: AppTextStyles.caption.copyWith(
                                    color: sel ? AppColors.accentAlt : AppColors.textSecondary),
                                  overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Privacy
            MudCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MudSectionLabel('🔒 الخصوصية'),
                  ...[
                    '✅ بياناتك محفوظة على هاتفك فقط',
                    '✅ لا سيرفر، لا إنترنت، لا تتبع',
                    '✅ حتى نحن لا نعرف من أنت',
                    '✅ يمكنك مسح كل شيء في أي وقت',
                  ].map((t) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(t, style: AppTextStyles.body),
                  )),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _confirmReset(context, ref),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:        AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border:       Border.all(color: AppColors.error.withOpacity(0.2)),
                      ),
                      child: Text('🗑️ حذف جميع البيانات',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyBold.copyWith(color: AppColors.error)),
                    ),
                  ),
                ],
              ),
            ),

            // About
            MudCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MudSectionLabel('ℹ️ عن مدبّر'),
                  Text('📱 مدبّر — إدارة المصروف العائلي العربي', style: AppTextStyles.body),
                  Text('🌍 22 دولة عربية', style: AppTextStyles.body),
                  Text('💡 30 ثانية يومياً تغير وضعك المالي', style: AppTextStyles.body),
                  const SizedBox(height: 6),
                  Text('الإصدار 1.0.0', style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeCountry(BuildContext context, WidgetRef ref, String id) async {
    final repo    = ref.read(onboardingRepoProvider);
    final profile = repo.getSaved();
    if (profile == null) return;
    await repo.save(profile.copyWith(countryId: id));
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface2,
        title:   Text('حذف البيانات', style: AppTextStyles.title),
        content: Text('سيتم حذف جميع بياناتك نهائياً. هذا الإجراء لا يمكن التراجع عنه.',
          style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: AppTextStyles.body.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(onboardingRepoProvider).reset();
      // In real app: clear all boxes + navigate to onboarding
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body),
        Text(value,  style: AppTextStyles.bodyBold),
      ],
    ),
  );
}
