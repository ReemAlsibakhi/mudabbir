import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_gradient_button.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  final String? featureName;
  const PaywallScreen({super.key, this.featureName});

  @override
  ConsumerState<PaywallScreen> createState() => _State();
}

class _State extends ConsumerState<PaywallScreen> {
  bool _loading = false;

  static const _features = [
    (icon: '🤖', title: 'مدبّر الذكي',     desc: 'محادثة مالية شخصية بالذكاء الاصطناعي'),
    (icon: '📱', title: 'قراءة SMS البنكي', desc: 'تسجيل تلقائي من رسائل البنك'),
    (icon: '👫', title: 'وضع الزوجين',     desc: 'ميزانية مشتركة مع شريك الحياة'),
    (icon: '🔥', title: '3 رموز إنقاذ',    desc: 'أنقذ سلسلتك 3 مرات شهرياً'),
    (icon: '🎯', title: 'أهداف غير محدودة', desc: 'أضف كل أهدافك بدون قيود'),
    (icon: '📊', title: 'تقارير متقدمة',   desc: 'مقارنة شهرية + تصدير PDF'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            const SizedBox(height: 20),
            Container(
              width:  70, height: 70,
              decoration: BoxDecoration(
                gradient:     AppColors.goldGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(
                  color:      AppColors.gold.withOpacity(0.35),
                  blurRadius: 20,
                )],
              ),
              child: const Center(child: Text('👑', style: TextStyle(fontSize: 34))),
            ),
            const SizedBox(height: 16),
            Text('مدبّر المميز',
              style: AppTextStyles.headline1.copyWith(color: AppColors.goldLight)),
            const SizedBox(height: 6),
            Text(
              widget.featureName != null
                  ? 'لاستخدام ${widget.featureName}\nتحتاج الاشتراك المميز'
                  : 'احصل على تجربة مالية كاملة',
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 28),

            // Features grid
            ..._features.map((f) => Container(
              margin:  const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color:        AppColors.surface1,
                borderRadius: BorderRadius.circular(14),
                border:       Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Text(f.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.title, style: AppTextStyles.bodyBold),
                        Text(f.desc,  style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 18),
                ],
              ),
            )),

            const SizedBox(height: 24),

            // Price
            Container(
              padding:     const EdgeInsets.all(16),
              decoration:  BoxDecoration(
                gradient:     AppColors.goldGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('9.99 ريال / شهر',
                    style: AppTextStyles.headline2.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('أقل من كوب قهوة يومياً ☕',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            MudGradientButton(
              label:   '🚀 ابدأ الآن — 7 أيام مجاناً',
              onTap:   _subscribe,
              loading: _loading,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => context.pop(),
              child: Text('ربما لاحقاً',
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
            ),
            const SizedBox(height: 20),
            Text('يمكنك الإلغاء في أي وقت من إعدادات متجر التطبيقات',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(fontSize: 10)),
          ],
        ),
      ),
    ),
  );

  Future<void> _subscribe() async {
    setState(() => _loading = true);
    // RevenueCat integration in full Phase 2
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('قريباً — سيتوفر الدفع قريباً 🚀',
          style: TextStyle(fontFamily: 'Cairo')),
      ));
    }
  }
}
