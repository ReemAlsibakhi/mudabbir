import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PromoSlide extends StatefulWidget {
  final VoidCallback onNext;
  const PromoSlide({super.key, required this.onNext});

  @override
  State<PromoSlide> createState() => _State();
}

class _State extends State<PromoSlide> {
  int _slide = 0;

  static const _slides = [
    (icon: '🏦', title: 'تعرّف أين يذهب\nراتبك كل شهر',
     desc:  'مدبّر يساعدك تتحكم في مصاريف أسرتك بذكاء — 30 ثانية يومياً فقط'),
    (icon: '🎯', title: 'حقق أهدافك\nالمالية أسرع',
     desc:  'منزل، سيارة، إجازة — مدبّر يحسب كم تحتاج توفير كل شهر'),
    (icon: '🔒', title: 'بياناتك خاصة\n100% على هاتفك',
     desc:  'لا سيرفر، لا إنترنت، لا أحد يراها. بياناتك ملكك فقط.'),
  ];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _slide ? 22 : 6, height: 6,
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
              Text(_slides[_slide].icon, style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 28),
              Text(
                _slides[_slide].title,
                textAlign: TextAlign.center,
                style: AppTextStyles.headline1.copyWith(height: 1.3),
              ),
              const SizedBox(height: 14),
              Text(
                _slides[_slide].desc,
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
        _NextButton(
          label: _slide < 2 ? 'التالي →' : 'ابدأ الآن 🚀',
          onTap: _next,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: widget.onNext,
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Text('تخطى', style: TextStyle(
              fontFamily: 'Cairo', fontSize: 13, color: AppColors.textTertiary)),
          ),
        ),
      ],
    ),
  );

  void _next() {
    if (_slide < 2) {
      setState(() => _slide++);
    } else {
      widget.onNext();
    }
  }
}

class _NextButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NextButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient:     AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow:    [BoxShadow(
          color: AppColors.accent.withOpacity(0.3), blurRadius: 16, offset: const Offset(0,6))],
      ),
      child: Text(label, textAlign: TextAlign.center,
        style: AppTextStyles.button.copyWith(fontSize: 17)),
    ),
  );
}
