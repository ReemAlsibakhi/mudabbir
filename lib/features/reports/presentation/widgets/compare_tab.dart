import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_card.dart';
import '../../../../shared/ui/widgets/mud_empty_view.dart';
import '../../../../shared/ui/widgets/mud_progress_bar.dart';
import '../providers/reports_provider.dart';

class CompareTab extends ConsumerWidget {
  final String currentMonthKey;
  const CompareTab({super.key, required this.currentMonthKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final months = ref.watch(last3MonthsProvider(currentMonthKey));

    if (months.every((m) => !m.hasData)) {
      return const MudEmptyView(
        icon:     '📊',
        title:    'لا توجد بيانات للمقارنة بعد',
        subtitle: 'سجّل مصاريف شهرين على الأقل',
      );
    }

    final curr    = months[0];
    final prev    = months.length > 1 ? months[1] : null;
    final diff    = prev != null ? curr.totalExpenses - prev.totalExpenses : 0.0;
    final diffPct = (prev != null && prev.totalExpenses > 0)
        ? (diff / prev.totalExpenses * 100) : 0.0;
    final improved = diff <= 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [

        // ── Headline comparison ───────────────────────
        if (prev != null && prev.hasData)
          MudCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مقارنة ${_monthLabel(curr.monthKey)} '
                  'بـ ${_monthLabel(prev.monthKey)}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${improved ? "↓" : "↑"} ${diff.abs().fmt()}',
                      style: AppTextStyles.headline1.copyWith(
                        color: improved ? AppColors.success : AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${diffPct.abs().toStringAsFixed(1)}% '
                        '${improved ? "تحسن 💚" : "زيادة في الإنفاق"}',
                        style: AppTextStyles.body.copyWith(
                          color: improved ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // ── Last 3 months bars ────────────────────────
        MudCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel('الإنفاق — آخر 3 أشهر'),
              ...months.where((m) => m.hasData).map((m) {
                final maxExp = months
                    .map((x) => x.totalExpenses)
                    .fold(0.0, (a, b) => a > b ? a : b);
                final pct       = maxExp > 0 ? m.totalExpenses / maxExp : 0.0;
                final isCurrent = m.monthKey == currentMonthKey;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_monthLabel(m.monthKey),
                            style: AppTextStyles.body.copyWith(
                              fontWeight: isCurrent
                                  ? FontWeight.w700 : FontWeight.w400,
                              color: isCurrent
                                  ? AppColors.accentAlt : AppColors.textSecondary,
                            )),
                          Text(m.totalExpenses.fmt(),
                            style: AppTextStyles.bodyBold.copyWith(
                              color: isCurrent
                                  ? AppColors.error : AppColors.textSecondary,
                            )),
                        ],
                      ),
                      const SizedBox(height: 4),
                      MudProgressBar(
                        value: pct.clamp(0.0, 1.0),
                        color: isCurrent
                            ? AppColors.error : AppColors.textTertiary,
                        height: 8,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // ── Summary diff ──────────────────────────────
        if (prev != null && prev.hasData)
          MudCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel('ملخص الفروق'),
                _DiffRow(label: 'إجمالي الإنفاق',
                  curr: curr.totalExpenses, prev: prev.totalExpenses),
                _DiffRow(label: 'المصاريف المتغيرة',
                  curr: curr.totalVariable, prev: prev.totalVariable),
                _DiffRow(label: 'المصاريف الثابتة',
                  curr: curr.totalFixed, prev: prev.totalFixed),
                _DiffRow(label: 'الادخار',
                  curr: curr.balance, prev: prev.balance,
                  higherIsBetter: true),
              ],
            ),
          ),
      ],
    );
  }

  String _monthLabel(String key) {
    try {
      final parts = key.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1])).monthAr;
    } catch (_) { return key; }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 2),
    child: Text(text.toUpperCase(), style: AppTextStyles.label),
  );
}

class _DiffRow extends StatelessWidget {
  final String label;
  final double curr, prev;
  final bool   higherIsBetter;

  const _DiffRow({
    required this.label,
    required this.curr,
    required this.prev,
    this.higherIsBetter = false,
  });

  @override
  Widget build(BuildContext context) {
    final diff      = curr - prev;
    final improved  = higherIsBetter ? diff >= 0 : diff <= 0;
    final diffColor = diff == 0
        ? AppColors.textTertiary
        : improved ? AppColors.success : AppColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(curr.fmt(),
            style: AppTextStyles.bodyBold.copyWith(color: AppColors.accentAlt)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color:        diffColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              diff == 0 ? '—' : '${diff > 0 ? "+" : ""}${diff.fmt()}',
              style: AppTextStyles.caption.copyWith(
                color: diffColor, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
