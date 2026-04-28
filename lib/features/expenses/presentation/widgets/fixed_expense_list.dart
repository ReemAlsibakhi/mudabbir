import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_empty_view.dart';
import '../../domain/entities/expense.dart';
import '../providers/expenses_notifier.dart';

class FixedExpenseList extends ConsumerWidget {
  final List<FixedExpense> items;
  final String             monthKey;
  const FixedExpenseList({super.key, required this.items, required this.monthKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const MudEmptyView(
        icon:     '📅',
        title:    'لا توجد مصاريف ثابتة',
        subtitle: 'أضف إيجارك وفواتيرك لتتبعها تلقائياً كل شهر',
      );
    }

    final total = items.fold(0.0, (s, e) => s + e.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        ...items.map((e) => Dismissible(
          key:       Key(e.id),
          direction: DismissDirection.startToEnd,
          background: Container(
            margin:     const EdgeInsets.symmetric(vertical: 4),
            padding:    const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color:        AppColors.error.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13)),
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Text('حذف', style: TextStyle(fontFamily:'Cairo', color: AppColors.error)),
                const SizedBox(width: 12),
              ],
            ),
          ),
          confirmDismiss: (_) async {
            HapticFeedback.mediumImpact();
            return await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppColors.surface2,
                title:   const Text('حذف الثابت', style: TextStyle(fontFamily:'Cairo')),
                content: const Text('هل تريد حذف هذا المصروف الثابت؟', style: TextStyle(fontFamily:'Cairo')),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false),
                    child: const Text('إلغاء', style: TextStyle(fontFamily:'Cairo'))),
                  TextButton(onPressed: () => Navigator.pop(context, true),
                    child: const Text('حذف', style: TextStyle(fontFamily:'Cairo', color: AppColors.error))),
                ],
              ),
            ) ?? false;
          },
          onDismissed: (_) => ref
              .read(expensesNotifierProvider(monthKey).notifier)
              .deleteFixedExpense(e.id),
          child: _FixedItem(
            expense:  e,
            onDelete: () => ref
                .read(expensesNotifierProvider(monthKey).notifier)
                .deleteFixedExpense(e.id),
          ),
        )),
        // Total
        Container(
          margin:  const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:        AppColors.surface2,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('إجمالي الثابت الشهري', style: AppTextStyles.subtitle),
              Text(total.fmt(),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FixedItem extends StatelessWidget {
  final FixedExpense  expense;
  final VoidCallback  onDelete;
  const _FixedItem({required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cat          = getCategoryById(expense.categoryId);
    final color        = Color(cat.color);
    final daysUntilDue = expense.daysUntilDue();
    final isDueSoon    = daysUntilDue != null && daysUntilDue <= 3;

    return Container(
      margin:  const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(
          color: isDueSoon ? AppColors.warning.withOpacity(0.4) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.name, style: AppTextStyles.bodyBold),
                Row(
                  children: [
                    Text('${cat.nameAr} · تلقائي كل شهر',
                      style: AppTextStyles.caption),
                    // Due soon badge
                    if (isDueSoon) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color:        AppColors.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          daysUntilDue! == 0 ? 'اليوم' : 'بعد $daysUntilDue أيام',
                          style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(expense.amount.fmt(),
            style: AppTextStyles.bodyBold.copyWith(color: color)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.09),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
