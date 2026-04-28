import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_card.dart';
import '../../../ai_chat/presentation/providers/chat_notifier.dart';
import '../../../ai_chat/presentation/screens/api_key_setup_screen.dart';
import '../../../freemium/domain/entities/subscription.dart';
import '../../../freemium/presentation/providers/subscription_provider.dart';
import '../../../freemium/presentation/screens/paywall_screen.dart';
import '../../../onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../../onboarding/domain/entities/onboarding_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile      = ref.watch(onboardingRepoProvider).getSaved();
    final sub          = ref.watch(subscriptionProvider);
    final hasApiKey    = ref.watch(apiKeyProvider).isNotEmpty;
    final country      = profile != null ? getCountryById(profile.countryId) : kCountries.first;

    return Scaffold(
      appBar: AppBar(
        title: Text('⚙️ الإعدادات', style: AppTextStyles.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // ── Profile ─────────────────────────────────────────
            if (profile != null)
              MudCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MudSectionLabel('الملف الشخصي'),
                    _ProfileHeader(profile: profile, country: country, sub: sub),
                    const Divider(color: AppColors.border, height: 20),
                    _InfoRow(label: '🌍 الدولة',       value: '${country.flag} ${country.nameAr}'),
                    _InfoRow(label: '💱 العملة',       value: country.currency),
                    _LifeStageRow(profile: profile),
                  ],
                ),
              ),

            // ── Subscription ─────────────────────────────────────
            MudCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MudSectionLabel('الاشتراك'),
                  if (sub.isFree) ...[
                    _SettingsTile(
                      icon: '👑', title: 'ترقية للنسخة المميزة',
                      subtitle: 'AI Chat + GPS + PDF + وضع الزوجين',
                      accent: true,
                      onTap: () => PaywallScreen.show(context,
                        feature: 'النسخة المميزة',
                        desc:    'احصل على كل الميزات بـ 9.99 ريال/شهر',
                      ),
                    ),
                  ] else ...[
                    _SettingsTile(
                      icon: '✅', title: 'مشترك — نسخة مميزة',
                      subtitle: sub.expiresAt != null
                          ? 'ينتهي في ${_formatDate(sub.expiresAt!)}'
                          : 'اشتراك نشط',
                    ),
                  ],
                ],
              ),
            ),

            // ── AI Chat ──────────────────────────────────────────
            MudCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MudSectionLabel('المستشار الذكي'),
                  _SettingsTile(
                    icon: '🤖', title: 'Claude API Key',
                    subtitle: hasApiKey ? '✅ مضبوط — المستشار جاهز' : '❌ لم يُضبط بعد',
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ApiKeySetupScreen())),
                  ),
                  if (hasApiKey)
                    _SettingsTile(
                      icon: '💬', title: 'فتح المستشار الذكي',
                      onTap: () => context.go(AppRoutes.chat),
                    ),
                ],
              ),
            ),

            // ── Country picker ───────────────────────────────────
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
                      crossAxisSpacing: 8, childAspectRatio: 2.8),
                    itemCount: kCountries.length,
                    itemBuilder: (_, i) {
                      final c   = kCountries[i];
                      final sel = c.id == (profile?.countryId ?? 'sa');
                      return GestureDetector(
                        onTap: () => _changeCountry(ref, c.id, profile),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color:        sel ? AppColors.accent.withOpacity(0.12) : AppColors.surface2,
                            borderRadius: BorderRadius.circular(9),
                            border:       Border.all(
                              color: sel ? AppColors.accent : AppColors.border,
                              width: sel ? 1.5 : 1),
                          ),
                          child: Row(
                            children: [
                              Text(c.flag, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(c.nameAr,
                                  style: AppTextStyles.caption.copyWith(
                                    color: sel ? AppColors.accentAlt : AppColors.textSecondary),
                                  overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Notifications ────────────────────────────────────
            MudCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MudSectionLabel('الإشعارات'),
                  _SettingsTile(
                    icon: '🔔', title: 'إشعار الصباح (9:00)',
                    subtitle: 'تذكير بتسجيل المصاريف',
                    trailing: _Switch(value: true, onChanged: (_) {}),
                  ),
                  _SettingsTile(
                    icon: '🌙', title: 'ملخص المساء (9:00)',
                    subtitle: 'مراجعة يومية سريعة',
                    trailing: _Switch(value: true, onChanged: (_) {}),
                  ),
                ],
              ),
            ),

            // ── Privacy ──────────────────────────────────────────
            MudCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MudSectionLabel('الخصوصية والأمان'),
                  ...[
                    '✅ بياناتك على هاتفك فقط',
                    '✅ لا سيرفر، لا إنترنت مطلوب',
                    '✅ لا إعلانات أبداً',
                    '✅ يمكنك حذف كل شيء في أي وقت',
                  ].map((t) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(t, style: AppTextStyles.body.copyWith(fontSize: 13)))),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _confirmReset(context, ref),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:        AppColors.error.withOpacity(0.07),
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
                  const MudSectionLabel('عن مدبّر'),
                  Text('الإصدار 2.0.0', style: AppTextStyles.body),
                  Text('22 دولة عربية · 4 مراحل حياة', style: AppTextStyles.body),
                  Text('مفتوح المصدر — github.com/ReemAlsibakhi/mudabbir',
                    style: AppTextStyles.caption.copyWith(color: AppColors.accentAlt)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';

  Future<void> _changeCountry(WidgetRef ref, String id, dynamic profile) async {
    if (profile == null) return;
    final repo = ref.read(onboardingRepoProvider);
    await repo.save(profile.copyWith(countryId: id));
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface2,
        title:   Text('حذف البيانات', style: AppTextStyles.title),
        content: Text('سيتم حذف جميع بياناتك نهائياً. لا يمكن التراجع.',
          style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: AppTextStyles.body.copyWith(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true) await ref.read(onboardingRepoProvider).reset();
  }
}

// ── Sub-widgets ────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final dynamic profile, country;
  final Subscription sub;
  const _ProfileHeader({required this.profile, required this.country, required this.sub});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          gradient:     AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(child: Text(profile.lifeStage.icon,
          style: const TextStyle(fontSize: 22))),
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(profile.name,
            style: AppTextStyles.title),
          const SizedBox(height: 2),
          Text('${profile.lifeStage.nameAr} · ${country.nameAr}',
            style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color:        sub.isPremium
                  ? AppColors.gold.withOpacity(0.12)
                  : AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              sub.isPremium ? '👑 مميز' : '🆓 مجاني',
              style: AppTextStyles.caption.copyWith(
                color: sub.isPremium ? AppColors.goldLight : AppColors.accentAlt,
                fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ],
  );
}

class _SettingsTile extends StatelessWidget {
  final String    icon, title;
  final String?   subtitle;
  final VoidCallback? onTap;
  final Widget?   trailing;
  final bool      accent;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin:   const EdgeInsets.only(bottom: 8),
      padding:  const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color:        accent
            ? AppColors.gold.withOpacity(0.07)
            : AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(
          color: accent
              ? AppColors.gold.withOpacity(0.2)
              : AppColors.border),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyBold.copyWith(
                  color: accent ? AppColors.goldLight : AppColors.textPrimary)),
                if (subtitle != null)
                  Text(subtitle!, style: AppTextStyles.caption),
              ],
            ),
          ),
          trailing ?? (onTap != null
              ? Icon(Icons.chevron_left_rounded,
                  color: AppColors.textTertiary, size: 18)
              : const SizedBox.shrink()),
        ],
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body),
        Text(value, style: AppTextStyles.bodyBold),
      ],
    ),
  );
}

class _LifeStageRow extends ConsumerWidget {
  final dynamic profile;
  const _LifeStageRow({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) => GestureDetector(
    onTap: () => _showPicker(context, ref),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('👥 مرحلة الحياة', style: AppTextStyles.body),
          Row(
            children: [
              Text('${profile.lifeStage.icon} ${profile.lifeStage.nameAr}',
                style: AppTextStyles.bodyBold),
              const SizedBox(width: 4),
              const Icon(Icons.edit_outlined, size: 14, color: AppColors.textTertiary),
            ],
          ),
        ],
      ),
    ),
  );

  void _showPicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface2,
        title: Text('تغيير مرحلة الحياة', style: AppTextStyles.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LifeStage.values.map((stage) => ListTile(
            leading:  Text(stage.icon, style: const TextStyle(fontSize: 24)),
            title:    Text(stage.nameAr,
              style: AppTextStyles.bodyBold),
            subtitle: Text(stage.desc, style: AppTextStyles.caption),
            selected:       profile.lifeStage == stage,
            selectedTileColor: AppColors.accent.withOpacity(0.08),
            shape:    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onTap: () async {
              Navigator.pop(context);
              final repo = ref.read(onboardingRepoProvider);
              await repo.save(profile.copyWith(lifeStage: stage));
            },
          )).toList(),
        ),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Switch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Switch(
    value:             value,
    onChanged:         onChanged,
    activeColor:       AppColors.accent,
    activeTrackColor:  AppColors.accent.withOpacity(0.3),
    inactiveThumbColor: AppColors.textTertiary,
    inactiveTrackColor: AppColors.surface3,
  );
}
