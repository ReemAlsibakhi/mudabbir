import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_card.dart';
import '../../../onboarding/domain/entities/onboarding_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_notifier.dart';

// ══════════════════════════════════════════════════════════
// SeasonalBudgetCard — مواسم الإنفاق الكثيف
// يظهر للأسرة فقط عند اقتراب المناسبات
// ══════════════════════════════════════════════════════════

enum Season { ramadan, eid, school }

extension SeasonExt on Season {
  String get icon    => switch (this) {
    Season.ramadan => '🕌',
    Season.eid     => '🌙',
    Season.school  => '🎒',
  };
  String get titleKey => switch (this) {
    Season.ramadan => AppStrings.seasonRamadan,
    Season.eid     => AppStrings.seasonEid,
    Season.school  => AppStrings.seasonSchool,
  };
  String get budgetKey => switch (this) {
    Season.ramadan => AppStrings.seasonRamadanBudget,
    Season.eid     => AppStrings.seasonEidBudget,
    Season.school  => AppStrings.seasonSchoolBudget,
  };
  Color get color => switch (this) {
    Season.ramadan => const Color(0xFF6366F1),
    Season.eid     => const Color(0xFFF59E0B),
    Season.school  => const Color(0xFF10B981),
  };
}

// Detect upcoming season from current date
Season? _upcomingSeason(DateTime now) {
  final m = now.month;
  final d = now.day;
  // School season: August 15 – September 15
  if ((m == 8 && d >= 15) || (m == 9 && d <= 15)) return Season.school;
  // Eid Al-Adha roughly June-July (Hijri — approximation)
  if (m == 6 || (m == 7 && d <= 10)) return Season.eid;
  // Ramadan roughly March-April (Hijri — approximation)
  if (m == 3 || (m == 4 && d <= 10)) return Season.ramadan;
  return null;
}

class SeasonalBudgetCard extends ConsumerStatefulWidget {
  const SeasonalBudgetCard({super.key});

  @override
  ConsumerState<SeasonalBudgetCard> createState() => _State();
}

class _State extends ConsumerState<SeasonalBudgetCard> {
  final Map<Season, TextEditingController> _ctrls = {
    for (final s in Season.values) s: TextEditingController(),
  };
  Season? _selected;

  @override
  void initState() {
    super.initState();
    _selected = _upcomingSeason(DateTime.now());
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(onboardingRepoProvider).getSaved();
    // Only show for family
    if (profile?.lifeStage != LifeStage.family) return const SizedBox.shrink();

    return MudCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📅', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(AppStrings.seasonTitle, style: AppTextStyles.bodyBold),
            ],
          ),
          const SizedBox(height: 12),

          // Season tabs
          Row(
            children: Season.values.map((s) {
              final active = _selected == s;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selected = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: active
                          ? s.color.withOpacity(0.12)
                          : AppColors.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: active ? s.color : AppColors.border,
                        width: active ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(s.icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 3),
                        Text(s.titleKey,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color:      active ? s.color : AppColors.textTertiary,
                            fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          if (_selected != null) ...[
            const SizedBox(height: 14),
            _SeasonDetail(season: _selected!, ctrl: _ctrls[_selected!]!),
          ],
        ],
      ),
    );
  }
}

class _SeasonDetail extends StatelessWidget {
  final Season                season;
  final TextEditingController ctrl;
  const _SeasonDetail({required this.season, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final budget = double.tryParse(ctrl.text) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(season.budgetKey,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller:   ctrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textDirection: TextDirection.rtl,
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText:      '0',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                  suffixIcon: budget > 0
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(budget.fmt(),
                            style: AppTextStyles.bodyBold.copyWith(
                              color: season.color, fontSize: 12)))
                      : null,
                ),
              ),
            ),
          ],
        ),
        if (budget > 0) ...[
          const SizedBox(height: 8),
          // Daily budget insight
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:        season.color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              '${season.icon} ${(budget / 30).toStringAsFixed(0)} ريال يومياً خلال الموسم',
              style: AppTextStyles.caption.copyWith(color: season.color),
            ),
          ),
        ],

        const SizedBox(height: 10),
        // Sub-items per season
        ..._subItems(season),
      ],
    );
  }

  List<Widget> _subItems(Season s) {
    final items = switch (s) {
      Season.eid    => ['👗 ملابس العيد', '🎁 عيدية الأطفال', '🍖 أضحية', '🚗 وقود وزيارات'],
      Season.ramadan=> ['🌙 سحور وإفطار', '🤲 زكاة وصدقات', '🎁 هدايا', '💡 كهرباء إضافية'],
      Season.school => ['📚 كتب وأدوات', '👔 زي مدرسي', '🎒 حقيبة', '🚌 اشتراك المواصلات'],
    };
    return items.map((item) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        const SizedBox(width: 4),
        Text(item, style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary, height: 1.7)),
      ]),
    )).toList();
  }
}
