import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_card.dart';
import '../../../../shared/ui/widgets/mud_progress_bar.dart';
import '../../../onboarding/domain/entities/onboarding_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_notifier.dart';
import '../../domain/entities/income.dart';

class IncomeSummaryCard extends ConsumerWidget {
  final Income income;
  const IncomeSummaryCard({super.key, required this.income});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile    = ref.watch(onboardingRepoProvider).getSaved();
    final lifeStage  = profile?.lifeStage ?? LifeStage.single;
    final hasPartner = lifeStage.hasPartner;

    if (!income.hasIncome) return const SizedBox.shrink();

    return MudCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MudSectionLabel(AppStrings.incomeTotalLabel),
          const SizedBox(height: 4),

          // ── Total ────────────────────────────────────────
          Text(
            income.total.fmt(),
            style: AppTextStyles.headline2.copyWith(
              color: AppColors.success, fontSize: 26),
          ),
          const SizedBox(height: 12),

          // ── Rows ─────────────────────────────────────────
          _Row(label: AppStrings.incomePrimLabel,
            value: income.primary, show: true),
          if (hasPartner)
            _Row(label: AppStrings.incomePartLabel,
              value: income.secondary, show: income.hasPartner),
          _Row(label: AppStrings.incomeExtraLabel,
            value: income.extra, show: income.hasExtra),

          // ✅ COUPLE SPLIT — breakdown for married/family
          if (hasPartner && income.primary > 0 && income.secondary > 0) ...[
            const SizedBox(height: 14),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 10),
            _CoupleSplit(income: income, lifeStage: lifeStage),
          ],
        ],
      ),
    );
  }
}

// ── Individual row ────────────────────────────────────────
class _Row extends StatelessWidget {
  final String label;
  final double value;
  final bool   show;
  const _Row({required this.label, required this.value, required this.show});

  @override
  Widget build(BuildContext context) {
    if (!show || value <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body.copyWith(fontSize: 13)),
          Text(value.fmt(),
            style: AppTextStyles.bodyBold.copyWith(
              color: AppColors.accentAlt, fontSize: 14)),
        ],
      ),
    );
  }
}

// ✅ Couple contribution split widget
class _CoupleSplit extends StatelessWidget {
  final Income    income;
  final LifeStage lifeStage;
  const _CoupleSplit({required this.income, required this.lifeStage});

  @override
  Widget build(BuildContext context) {
    final total    = income.primary + income.secondary;
    final husbPct  = total > 0 ? income.primary / total : 0.5;
    final wifePct  = 1 - husbPct;
    final husbLabel = lifeStage == LifeStage.family
        ? AppStrings.incomeHusbandRole
        : AppStrings.incomeHusbandMarried;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.coupleContribTitle,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary)),
        const SizedBox(height: 8),

        // Visual bar split
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: [
              // Husband bar
              Flexible(
                flex: (husbPct * 100).round(),
                child: Container(
                  height: 10,
                  color: AppColors.accent,
                ),
              ),
              // Wife bar
              Flexible(
                flex: (wifePct * 100).round(),
                child: Container(
                  height: 10,
                  color: AppColors.accentAlt,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Husband
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color:  AppColors.accent,
                      shape:  BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('${(husbPct * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.bodyBold.copyWith(
                      color: AppColors.accent, fontSize: 13)),
                ]),
                Text(husbLabel,
                  style: AppTextStyles.caption.copyWith(fontSize: 10)),
              ],
            ),
            // Wife
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(children: [
                  Text('${(wifePct * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.bodyBold.copyWith(
                      color: AppColors.accentAlt, fontSize: 13)),
                  const SizedBox(width: 4),
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color:  AppColors.accentAlt,
                      shape:  BoxShape.circle,
                    ),
                  ),
                ]),
                Text(AppStrings.incomeWifeOpt,
                  style: AppTextStyles.caption.copyWith(fontSize: 10)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
