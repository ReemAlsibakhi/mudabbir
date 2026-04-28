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

class ExpenseList extends ConsumerWidget {
  final List<Expense> items;
  final String        monthKey;
  const ExpenseList({super.key, required this.items, required this.monthKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const MudEmptyView(
        icon:     '📭',
        title:    'لا توجد مصاريف هذا الشهر',
        subtitle: 'اضغط + لإضافة مصروف جديد',
      );
    }

    // Group by date — newest first
    final byDate = <String, List<Expense>>{};
    for (final e in items) {
      byDate.putIfAbsent(e.date, () => []).add(e);
    }
    final dates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      // ✅ Extra bottom padding so last item clears FAB
      padding:   const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: dates.length,
      itemBuilder: (_, i) {
        final date     = dates[i];
        final dayItems = byDate[date]!;
        final dayTotal = dayItems.fold(0.0, (s, e) => s + e.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            ...dayItems.map((e) => _ExpenseItem(
              expense:  e,
              onDelete: () => _confirmDelete(context, () => ref
                  .read(expensesNotifierProvider(monthKey).notifier)
                  .deleteExpense(e.id)),
            )),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext ctx, VoidCallback onConfirm) async {
    HapticFeedback.mediumImpact();
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface2,
        title:   Text('حذف المصروف', style: AppTextStyles.title),
        content: Text('هل تريد حذف هذا المصروف؟', style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('حذف',
              style: AppTextStyles.body.copyWith(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true) onConfirm();
  }

  String _formatDate(String dateKey) {
    try {
      final parts = dateKey.split('-');
      final d = DateTime(
        int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final now  = DateTime.now();
      final today     = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      if (d == today)     return 'اليوم';
      if (d == yesterday) return 'أمس';
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) { return dateKey; }
  }
}

class _ExpenseItem extends StatelessWidget {
  final Expense      expense;
  final VoidCallback onDelete;
  const _ExpenseItem({required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cat   = getCategoryById(expense.categoryId);
    final color = Color(cat.color);

    return Dismissible(
      key:        Key(expense.id),
      direction:  DismissDirection.startToEnd,
      background: Container(
        margin:      const EdgeInsets.symmetric(vertical: 4),
        padding:     const EdgeInsets.only(right: 20),
        decoration:  BoxDecoration(
          color:        AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(13)),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline_rounded,
              color: AppColors.error, size: 22),
            const SizedBox(width: 8),
            Text('حذف', style: AppTextStyles.body.copyWith(color: AppColors.error)),
            const SizedBox(width: 16),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // handle in dialog
      },
      child: Container(
        margin:  const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:        AppColors.surface1,
          borderRadius: BorderRadius.circular(13),
          border:       Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color:        color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11)),
              child: Center(
                child: Text(cat.icon,
                  style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.name,
                    style: AppTextStyles.bodyBold,
                    maxLines: 1,
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
                  borderRadius: BorderRadius.circular(7)),
                child: const Icon(Icons.close_rounded,
                  size: 14, color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
