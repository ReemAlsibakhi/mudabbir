import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_card.dart';
import '../../../expenses/presentation/providers/expenses_notifier.dart';
import '../../../onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../../onboarding/presentation/providers/onboarding_notifier.dart';

class TodaySummary extends ConsumerWidget {
  final DateTime date;
  const TodaySummary({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expState  = ref.watch(expensesNotifierProvider(date.monthKey));
    final profile   = ref.watch(onboardingRepoProvider).getSaved();
    final currency  = profile?.countryId != null
        ? ref.watch(onboardingRepoProvider).getSaved()?.countryId ?? 'sa'
        : 'sa';
    final todayKey  = date.dateKey;

    if (expState is! ExpensesLoaded) return const SizedBox.shrink();

    final todayItems = expState.expenses.where((e) => e.date == todayKey).toList();
    final todayTotal = todayItems.fold(0.0, (s, e) => s + e.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MudSectionLabel('ملخص اليوم'),
        MudCard(
          child: todayItems.isEmpty
              ? const Center(
                  child: Column(children: [
                    SizedBox(height: 8),
                    Text('☀️', style: TextStyle(fontSize: 36)),
                    SizedBox(height: 8),
                    Text('لم تسجل أي مصروف اليوم بعد',
                      style: TextStyle(fontFamily:'Cairo', fontSize:13,
                        color: AppColors.textSecondary)),
                    SizedBox(height: 8),
                  ]))
              : Column(children: [
                  ...todayItems.map((e) {
                    final cat   = getCategoryById(e.categoryId);
                    final color = Color(cat.color);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 16))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(e.name, style: AppTextStyles.bodyBold, maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                          Text(cat.nameAr, style: AppTextStyles.caption),
                        ])),
                        Text(e.amount.fmt(),
                          style: AppTextStyles.bodyBold.copyWith(color: color)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => ref
                              .read(expensesNotifierProvider(date.monthKey).notifier)
                              .deleteExpense(e.id),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.09),
                              borderRadius: BorderRadius.circular(7)),
                            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
                          ),
                        ),
                      ]),
                    );
                  }),
                  const Divider(color: AppColors.border, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('مجموع اليوم',
                        style: TextStyle(fontFamily:'Cairo', fontSize:14, fontWeight:FontWeight.w700)),
                      Text(todayTotal.fmt(),
                        style: AppTextStyles.headline2.copyWith(color: AppColors.error, fontSize: 20)),
                    ],
                  ),
                ]),
        ),
      ],
    );
  }
}
