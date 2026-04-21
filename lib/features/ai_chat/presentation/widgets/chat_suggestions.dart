import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ChatSuggestions extends StatelessWidget {
  final ValueChanged<String> onSelect;
  const ChatSuggestions({super.key, required this.onSelect});

  static const _suggestions = [
    'كيف أوفر أكثر هذا الشهر؟',
    'ما أكبر بند مصروف عندي؟',
    'متى أصل لهدف المنزل؟',
    'هل وضعي المالي جيد؟',
    'اقترح لي ميزانية أسبوعية',
    'كيف أبني صندوق طوارئ؟',
  ];

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection:  Axis.horizontal,
      padding:          const EdgeInsets.symmetric(horizontal: 12),
      itemCount:        _suggestions.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder:      (_, i) => GestureDetector(
        onTap: () => onSelect(_suggestions[i]),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color:        AppColors.surface2,
            borderRadius: BorderRadius.circular(20),
            border:       Border.all(color: AppColors.borderMid),
          ),
          child: Text(_suggestions[i],
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ),
      ),
    ),
  );
}
