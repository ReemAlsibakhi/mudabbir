import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/countries.dart';
import '../../../data/providers/user_provider.dart';
import '../../../shared/widgets/mud_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text('⚙️ الإعدادات',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w800)),
            ),

            // Country
            MudCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MudSectionTitle('🌍 الدولة والعملة'),
                  userAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (user) {
                      final selected = user?.countryId ?? 'sa';
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.8,
                        children: kCountries.map((c) {
                          final isActive = c.id == selected;
                          return GestureDetector(
                            onTap: () async {
                              final profile = ref.read(userProvider).valueOrNull;
                              if (profile != null) {
                                profile.countryId = c.id;
                                await profile.save();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.accent.withOpacity(0.12) : AppColors.surface2,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isActive ? AppColors.accent : AppColors.border,
                                  width: isActive ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(c.flag, style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(c.nameAr,
                                      style: TextStyle(fontFamily: 'Cairo', fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isActive ? AppColors.accent2 : AppColors.textSecondary),
                                      overflow: TextOverflow.ellipsis),
                                  ),
                                  Text(c.currency,
                                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 10,
                                      color: AppColors.textTertiary)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
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
                  const MudSectionTitle('🔒 الخصوصية والأمان'),
                  const _PrivacyItem(icon: '✅', text: 'بياناتك محفوظة على هاتفك فقط'),
                  const _PrivacyItem(icon: '✅', text: 'لا سيرفر، لا إنترنت، لا تتبع'),
                  const _PrivacyItem(icon: '✅', text: 'حتى نحن لا نعرف من أنت'),
                  const _PrivacyItem(icon: '✅', text: 'يمكنك مسح كل شيء في أي وقت'),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _confirmClear(context, ref),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.red.withOpacity(0.2)),
                      ),
                      child: const Center(
                        child: Text('🗑️ حذف جميع البيانات',
                          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700,
                            color: AppColors.red, fontSize: 14)),
                      ),
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
                  const MudSectionTitle('ℹ️ عن مدبّر'),
                  const _AboutRow(text: '📱 مدبّر — إدارة المصروف العائلي'),
                  const _AboutRow(text: '🌍 مصمم للأسرة العربية — 22 دولة'),
                  const _AboutRow(text: '💡 30 ثانية يومياً تغير وضعك المالي'),
                  const SizedBox(height: 8),
                  const Text('الإصدار 1.0.0 — 2025',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textTertiary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface2,
        title: const Text('حذف البيانات', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل أنت متأكد من حذف جميع البيانات نهائياً؟',
          style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: AppColors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear all Hive boxes
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف جميع البيانات',
          style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating),
      );
    }
  }
}

class _PrivacyItem extends StatelessWidget {
  final String icon, text;
  const _PrivacyItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$icon $text',
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String text;
  const _AboutRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(text,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
          color: AppColors.textSecondary, height: 1.6)),
    );
  }
}
