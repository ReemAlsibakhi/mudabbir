import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_empty_view.dart';
import '../../domain/entities/expense.dart';
import '../providers/expenses_notifier.dart';

class ExpenseList extends ConsumerWidget {
  final List<Expense> items;
  final String        monthKey;
  const ExpenseList({super.key, required this.items, required this.monthKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const MudEmptyView(
        icon: '📭',
        title: 'لا توجد مصاريف هذا الشهر',
        subtitle: 'اضغط + لإضافة مصروف جديد',
      );
    }

    // Group by date
    final byDate = <String, List<Expense>>{};
    for (final e in items) {
      byDate.putIfAbsent(e.date, () => []).add(e);
    }
    final dates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: dates.length,
      itemBuilder: (_, i) {
        final date      = dates[i];
        final dayItems  = byDate[date]!;
        final dayTotal  = dayItems.fold(0.0, (s, e) => s + e.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDate(date), style: AppTextStyles.label),
                  Text(dayTotal.fmt(), style: AppTextStyles.caption.copyWith(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            // Items
            ...dayItems.map((e) => _ExpenseItem(
              expense:  e,
              onDelete: () => ref
                  .read(expensesNotifierProvider(monthKey).notifier)
                  .deleteExpense(e.id),
            )),
          ],
        );
      },
    );
  }

  String _formatDate(String dateKey) {
    try {
      final parts = dateKey.split('-');
      if (parts.length != 3) return dateKey;
      final d = DateTime(
        int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      return d.isAtSameMomentAs(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
          ? 'اليوم'
          : d.isAtSameMomentAs(
              DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 1))
          ? 'أمس'
          : dateKey;
    } catch (_) {
      return dateKey;
    }
  }
}

class _ExpenseItem extends StatelessWidget {
  final Expense       expense;
  final VoidCallback  onDelete;
  const _ExpenseItem({required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cat   = getCategoryById(expense.categoryId);
    final color = Color(cat.color);

    return Container(
      margin:  const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color:        color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.name, style: AppTextStyles.bodyBold, maxLines: 1,
                  overflow: TextOverflow.ellipsis),
                Text(cat.nameAr, style: AppTextStyles.caption),
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
                color:        AppColors.error.withOpacity(0.09),
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
