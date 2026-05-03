import '../../../../core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PaywallScreen extends StatelessWidget {
  final String lockedFeature;
  final String featureDesc;

  const PaywallScreen({
    super.key,
    required this.lockedFeature,
    required this.featureDesc,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String feature,
    required String desc,
  }) => showModalBottomSheet<bool>(
    context:        context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface2,
    builder: (_) => PaywallScreen(lockedFeature: feature, featureDesc: desc),
  );

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: AppColors.textTertiary,
            borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 24),

        // Lock icon
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            gradient:     AppColors.goldGradient,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Center(child: Text('👑', style: TextStyle(fontSize: 36))),
        ),
        const SizedBox(height: 16),

        Text('$lockedFeature${AppStrings.paywallFeatureSuf}',
          style: AppTextStyles.headline2, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(featureDesc,
          style: AppTextStyles.body, textAlign: TextAlign.center),
        const SizedBox(height: 24),

        // Features list
        ..._premiumFeatures.map((f) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Text('✅', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 10),
              Text(f, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
            ],
          ),
        )),
        const SizedBox(height: 24),

        // Price
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:        AppColors.gold.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border:       Border.all(color: AppColors.gold.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppStrings.paywallPrice,
                style: AppTextStyles.headline2.copyWith(color: AppColors.goldLight)),
              Text(AppStrings.paywallPeriod,
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Subscribe button
        GestureDetector(
          onTap: () {
            // TODO: RevenueCat purchase flow
            Navigator.pop(context, true);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              gradient:     AppColors.goldGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(AppStrings.paywallCta,
              textAlign: TextAlign.center,
              style: AppTextStyles.button.copyWith(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Navigator.pop(context, false),
          child: Center(
            child: Text(AppStrings.paywallNotNow,
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
          ),
        ),
      ],
    ),
  );

  static const _premiumFeatures = [
    AppStrings.paywallAiChat,
    AppStrings.paywallGps,
    AppStrings.paywallPdf,
    AppStrings.paywallCouple,
    AppStrings.paywallTokens,
  ];
}
