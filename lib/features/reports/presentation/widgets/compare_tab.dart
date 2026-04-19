import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_card.dart';
import '../../../../shared/ui/widgets/mud_empty_view.dart';
import '../../domain/entities/monthly_report.dart';
import '../providers/reports_provider.dart';

class CompareTab extends ConsumerWidget {
  final String currentMonthKey;
  const CompareTab({super.key, required this.currentMonthKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final months = ref.watch(last3MonthsProvider(currentMonthKey));

    // Edge: no data at all
    if (months.every((m) => !m.hasData)) {
      return const MudEmptyView(
        icon:     '📊',
        title:    'لا توجد بيانات للمقارنة بعد',
        subtitle: 'سجّل مصاريف شهرين على الأقل',
      );
    }

    final curr = months[0]; // current month
    final prev = months.length > 1 ? months[1] : null; // previous month

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
                        '${improved ? "تحسن في التحكم المالي 💚" : "زيادة في الإنفاق"}',
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
              const MudSectionLabel('الإنفاق — آخر 3 أشهر'),
              ...months.where((m) => m.hasData).map((m) {
                final maxExp = months
                    .map((x) => x.totalExpenses)
                    .fold(0.0, (a, b) => a > b ? a : b);
                final pct = maxExp > 0 ? m.totalExpenses / maxExp : 0.0;
                final isCurrent = m.monthKey == currentMonthKey;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _monthLabel(m.monthKey),
                            style: AppTextStyles.body.copyWith(
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                              color: isCurrent ? AppColors.accentAlt : AppColors.textSecondary,
                            ),
                          ),
                          Text(m.totalExpenses.fmt(),
                            style: AppTextStyles.bodyBold.copyWith(
                              color: isCurrent ? AppColors.error : AppColors.textSecondary,
                            )),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value:           pct.clamp(0.0, 1.0),
                          minHeight:       8,
                          backgroundColor: AppColors.surface3,
                          valueColor:      AlwaysStoppedAnimation(
                            isCurrent ? AppColors.error : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // ── Category differences ──────────────────────
        if (prev != null && prev.hasData)
          MudCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MudSectionLabel('الفروق بالفئات'),
                ...kExpenseCategories.map((cat) {
                  final currAmt = ref.watch(
                    monthlyReportProvider(curr.monthKey)).totalVariable;
                  final prevAmt = ref.watch(
                    monthlyReportProvider(prev.monthKey)).totalVariable;
                  // For simplicity show total diff — in real app per-category
                  return const SizedBox.shrink();
                }),
                // Simple diff view per month
                _CategoryDiff(
                  currentKey: curr.monthKey,
                  prevKey:    prev.monthKey,
                  ref:        ref,
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _monthLabel(String key) {
    try {
      final parts = key.split('-');
      final d = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      return d.monthAr;
    } catch (_) { return key; }
  }
}

class _CategoryDiff extends ConsumerWidget {
  final String currentKey, prevKey;
  final WidgetRef ref;
  const _CategoryDiff({
    required this.currentKey, required this.prevKey, required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef r) {
    final currReport = r.watch(monthlyReportProvider(currentKey));
    final prevReport = r.watch(monthlyReportProvider(prevKey));

    return Column(
      children: [
        _DiffRow(
          label: 'إجمالي الإنفاق',
          curr: currReport.totalExpenses,
          prev: prevReport.totalExpenses,
        ),
        _DiffRow(
          label: 'المصاريف المتغيرة',
          curr: currReport.totalVariable,
          prev: prevReport.totalVariable,
        ),
        _DiffRow(
          label: 'المصاريف الثابتة',
          curr: currReport.totalFixed,
          prev: prevReport.totalFixed,
        ),
        _DiffRow(
          label: 'الادخار',
          curr: currReport.balance,
          prev: prevReport.balance,
          higherIsBetter: true,
        ),
      ],
    );
  }
}

class _DiffRow extends StatelessWidget {
  final String label;
  final double curr, prev;
  final bool   higherIsBetter;
  const _DiffRow({
    required this.label, required this.curr, required this.prev,
    this.higherIsBetter = false,
  });

  @override
  Widget build(BuildContext context) {
    final diff      = curr - prev;
    final improved  = higherIsBetter ? diff >= 0 : diff <= 0;
    final diffColor = diff == 0 ? AppColors.textTertiary
        : improved ? AppColors.success : AppColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.body)),
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
              diff == 0 ? '—'
                  : '${diff > 0 ? "+" : ""}${diff.fmt()}',
              style: AppTextStyles.caption.copyWith(
                color: diffColor, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
