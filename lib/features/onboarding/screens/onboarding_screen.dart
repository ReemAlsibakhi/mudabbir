import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _page = 0;

  final List<_Slide> _slides = const [
    _Slide(icon: '🏦', title: 'تعرّف أين يذهب\nراتبك كل شهر', desc: 'مدبّر يساعدك تتحكم في مصاريف أسرتك بذكاء وبساطة — 30 ثانية يومياً فقط'),
    _Slide(icon: '🎯', title: 'حقق أهدافك\nالمالية أسرع', desc: 'منزل، سيارة، إجازة، زواج — مدبّر يحسب لك كم تحتاج توفير كل شهر للوصول لحلمك'),
    _Slide(icon: '🔒', title: 'بياناتك خاصة\n100% على هاتفك', desc: 'لا سيرفر، لا إنترنت، لا أحد يراها — حتى نحن لا نعرف من أنت. بياناتك ملكك فقط.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 22 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page ? AppColors.accent2 : AppColors.surface4,
                    borderRadius: BorderRadius.circular(99),
                  ),
                )),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_slides[_page].icon, style: const TextStyle(fontSize: 80)),
                    const SizedBox(height: 28),
                    Text(
                      _slides[_page].title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.w900, height: 1.3),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _slides[_page].desc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, color: AppColors.textSecondary, height: 1.8),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _next,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Text(
                    _page < _slides.length - 1 ? 'التالي ←' : 'ابدأ الآن 🚀',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _skip,
                child: const Text('تخطى', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textTertiary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _next() {
    if (_page < _slides.length - 1) {
      setState(() => _page++);
    } else {
      _skip();
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const _CountrySelectionScreen()),
    );
  }
}

class _Slide {
  final String icon, title, desc;
  const _Slide({required this.icon, required this.title, required this.desc});
}

// Placeholder — سيتم استبداله بـ CountryScreen الكاملة
class _CountrySelectionScreen extends StatelessWidget {
  const _CountrySelectionScreen();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('اختيار الدولة — قيد الإنشاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.white))));
  }
}
