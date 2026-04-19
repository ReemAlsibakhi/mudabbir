import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_gradient_button.dart';
import '../providers/onboarding_notifier.dart';
import '../../domain/entities/onboarding_data.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  static const _slides = [
    (icon:'🏦', title:'تعرّف أين يذهب\nراتبك كل شهر',
     desc:'مدبّر يساعدك تتحكم في مصاريف أسرتك بذكاء وبساطة — 30 ثانية يومياً فقط'),
    (icon:'🎯', title:'حقق أهدافك\nالمالية أسرع',
     desc:'منزل، سيارة، إجازة، زواج — مدبّر يحسب لك كم تحتاج توفير كل شهر'),
    (icon:'🔒', title:'بياناتك خاصة\n100% على هاتفك',
     desc:'لا سيرفر، لا إنترنت، لا أحد يراها — حتى نحن لا نعرف من أنت'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);

    ref.listen(onboardingProvider, (_, next) {
      if (next.error != null) {
        context.showSnack(next.error!, color: AppColors.error);
        ref.read(onboardingProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: switch (state.step) {
            0 => _PromoPage(key: const ValueKey(0)),
            1 => _CountryPage(key: const ValueKey(1)),
            2 => _LifeStagePage(key: const ValueKey(2)),
            3 => _NamePage(key: const ValueKey(3), loading: state.isLoading),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}

// ─── Promo ─────────────────────────────────────────────────
class _PromoPage extends ConsumerStatefulWidget {
  const _PromoPage({super.key});

  @override
  ConsumerState<_PromoPage> createState() => _PromoState();
}

class _PromoState extends ConsumerState<_PromoPage> {
  int _slide = 0;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width:  i == _slide ? 22 : 6, height: 6,
            decoration: BoxDecoration(
              color:        i == _slide ? AppColors.accentAlt : AppColors.surface4,
              borderRadius: BorderRadius.circular(99),
            ),
          )),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(OnboardingScreen._slides[_slide].icon,
                style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 24),
              Text(OnboardingScreen._slides[_slide].title,
                textAlign: TextAlign.center,
                style: AppTextStyles.headline1.copyWith(height: 1.3)),
              const SizedBox(height: 12),
              Text(OnboardingScreen._slides[_slide].desc,
                textAlign: TextAlign.center,
                style: AppTextStyles.body),
            ],
          ),
        ),
        MudGradientButton(
          label: _slide < 2 ? 'التالي ←' : 'ابدأ الآن 🚀',
          onTap: () {
            if (_slide < 2) setState(() => _slide++);
            else ref.read(onboardingProvider.notifier).nextStep();
          },
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => ref.read(onboardingProvider.notifier).nextStep(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text('تخطى', style: AppTextStyles.caption),
          ),
        ),
      ],
    ),
  );
}

// ─── Country ───────────────────────────────────────────────
class _CountryPage extends ConsumerWidget {
  const _CountryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🌍 من أي دولة أنت؟', style: AppTextStyles.headline2),
          const SizedBox(height: 6),
          Text('سنضبط العملة والإعدادات تلقائياً', style: AppTextStyles.caption),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 3,
              ),
              itemCount: kCountries.length,
              itemBuilder: (_, i) {
                final c   = kCountries[i];
                final sel = c.id == state.countryId;
                return GestureDetector(
                  onTap: () => ref.read(onboardingProvider.notifier).selectCountry(c.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color:        sel ? AppColors.accent.withOpacity(0.12) : AppColors.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border:       Border.all(color: sel ? AppColors.accent : AppColors.border, width: sel ? 1.5 : 1),
                    ),
                    child: Row(children: [
                      Text(c.flag, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(c.nameAr,
                        style: AppTextStyles.caption.copyWith(
                          color: sel ? AppColors.accentAlt : AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis)),
                    ]),
                  ),
                );
              },
            ),
          ),
          MudGradientButton(label: 'التالي ←', onTap: () => ref.read(onboardingProvider.notifier).nextStep()),
        ],
      ),
    );
  }
}

// ─── Life Stage ────────────────────────────────────────────
class _LifeStagePage extends ConsumerWidget {
  const _LifeStagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ما وضعك الحالي؟', style: AppTextStyles.headline2),
          const SizedBox(height: 6),
          Text('نخصص التطبيق بالكامل بناءً على وضعك', style: AppTextStyles.caption),
          const SizedBox(height: 20),
          ...LifeStage.values.map((s) {
            final sel = s == state.lifeStage;
            return GestureDetector(
              onTap: () => ref.read(onboardingProvider.notifier).selectLifeStage(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:        sel ? AppColors.accent.withOpacity(0.12) : AppColors.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border:       Border.all(color: sel ? AppColors.accent : AppColors.border, width: sel ? 1.5 : 1),
                ),
                child: Row(children: [
                  Text(s.icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.nameAr, style: AppTextStyles.subtitle.copyWith(
                        color: sel ? AppColors.accentAlt : AppColors.textPrimary)),
                      Text(s.desc,   style: AppTextStyles.caption),
                    ],
                  )),
                  if (sel) const Icon(Icons.check_circle_rounded, color: AppColors.accentAlt, size: 20),
                ]),
              ),
            );
          }),
          const Spacer(),
          MudGradientButton(label: 'التالي ←', onTap: () => ref.read(onboardingProvider.notifier).nextStep()),
        ],
      ),
    );
  }
}

// ─── Name ──────────────────────────────────────────────────
class _NamePage extends ConsumerStatefulWidget {
  final bool loading;
  const _NamePage({super.key, required this.loading});

  @override
  ConsumerState<_NamePage> createState() => _NameState();
}

class _NameState extends ConsumerState<_NamePage> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('👋', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 16),
        Text('ما اسمك؟', style: AppTextStyles.headline1),
        const SizedBox(height: 6),
        Text('نستخدمه فقط لمخاطبتك داخل التطبيق',
          style: AppTextStyles.caption),
        const SizedBox(height: 24),
        TextField(
          controller:    _ctrl,
          autofocus:     true,
          textDirection: TextDirection.rtl,
          maxLength:     30,
          onChanged:     (v) => ref.read(onboardingProvider.notifier).setName(v),
          style:         AppTextStyles.headline2,
          decoration:    const InputDecoration(hintText: 'اسمك هنا...', counterText: ''),
        ),
        const Spacer(),
        MudGradientButton(
          label:   'ابدأ مع مدبّر 🚀',
          loading: widget.loading,
          enabled: ref.watch(onboardingProvider).canFinish,
          onTap:   () async {
            final ok = await ref.read(onboardingProvider.notifier).finish();
            // Navigation handled by router in app.dart
          },
        ),
      ],
    ),
  );
}
