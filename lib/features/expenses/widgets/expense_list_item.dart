import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/categories.dart';
import '../domain/expense_entity.dart';

class ExpenseListItem extends StatelessWidget {
  final ExpenseEntity expense;
  final VoidCallback onDelete;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cat   = getCategoryById(expense.categoryId);
    final color = Color(cat.color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          _CategoryIcon(icon: cat.icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.name,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
                    fontWeight: FontWeight.w600)),
                Text('${cat.nameAr} · ${expense.date}',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 11,
                    color: AppColors.textTertiary)),
              ],
            ),
          ),
          Text('${expense.amount.toStringAsFixed(0)} ريال',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
              fontWeight: FontWeight.w800, color: color)),
          const SizedBox(width: 8),
          _DeleteButton(onTap: onDelete),
        ],
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String icon;
  final Color color;
  const _CategoryIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 36, height: 36,
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
  );
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.09),
        borderRadius: BorderRadius.circular(7),
      ),
      child: const Icon(Icons.close_rounded, size: 14, color: AppColors.red),
    ),
  );
}
