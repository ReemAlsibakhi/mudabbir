import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/categories.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/providers/expense_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../shared/widgets/mud_card.dart';

class TodaySummary extends ConsumerWidget {
  final DateTime date;
  const TodaySummary({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider(date));
    final todayKey = MudabbirDateUtils.dateKey(date);
    final todayExpenses = expenses.where((e) => e.date == todayKey).toList();
    final total = todayExpenses.fold(0.0, (s, e) => s + e.amount);
    final userAsync = ref.watch(userProvider);
    final currency = 'ريال'; // will come from user settings

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MudSectionTitle('ملخص اليوم'),
        MudCard(
          child: todayExpenses.isEmpty
              ? const Column(
                  children: [
                    SizedBox(height: 8),
                    Text('☀️', style: TextStyle(fontSize: 36)),
                    SizedBox(height: 8),
                    Text('لم تسجل أي مصروف اليوم بعد',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                        color: AppColors.textSecondary)),
                    SizedBox(height: 8),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                )
              : Column(
                  children: [
                    ...todayExpenses.map((e) {
                      final cat = getCategoryById(e.categoryId);
                      return _ExpenseItem(
                        icon: cat.icon,
                        name: e.name,
                        catName: cat.nameAr,
                        amount: e.amount,
                        color: Color(cat.color),
                        currency: currency,
                        onDelete: () => ref.read(expenseActionsProvider).deleteExpense(e.id),
                      );
                    }),
                    const Divider(color: AppColors.border, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('مجموع اليوم',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 14,
                            fontWeight: FontWeight.w700)),
                        Text('${total.toStringAsFixed(0)} $currency',
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 18,
                            fontWeight: FontWeight.w900, color: AppColors.red)),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  final String icon, name, catName, currency;
  final double amount;
  final Color color;
  final VoidCallback onDelete;

  const _ExpenseItem({
    required this.icon, required this.name, required this.catName,
    required this.amount, required this.color, required this.currency,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontFamily: 'Cairo',
                  fontSize: 13, fontWeight: FontWeight.w600)),
                Text(catName, style: const TextStyle(fontFamily: 'Cairo',
                  fontSize: 11, color: AppColors.textTertiary)),
              ],
            ),
          ),
          Text('${amount.toStringAsFixed(0)} $currency',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 14,
              fontWeight: FontWeight.w800, color: color)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.close, size: 14, color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}
