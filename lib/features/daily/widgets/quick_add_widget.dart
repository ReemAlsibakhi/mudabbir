import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/categories.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/providers/expense_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../shared/widgets/mud_card.dart';

final _selectedQuickCatProvider = StateProvider<String?>((ref) => null);

class QuickAddWidget extends ConsumerWidget {
  const QuickAddWidget({super.key});

  static const _quickCats = ['food', 'restaurants', 'transport', 'shopping', 'health', 'other'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_selectedQuickCatProvider);

    return MudCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MudSectionTitle('أو اختر الفئة مباشرة'),
          // Quick Categories Grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.2,
            children: _quickCats.map((id) {
              final cat = getCategoryById(id);
              final isSelected = selected == id;
              return GestureDetector(
                onTap: () {
                  ref.read(_selectedQuickCatProvider.notifier).state =
                      isSelected ? null : id;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(cat.color).withOpacity(0.15)
                        : AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Color(cat.color)
                          : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cat.icon, style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text(
                        cat.nameAr.split('و').first,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Color(cat.color)
                              : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          // Quick Amount Input
          if (selected != null) ...[
            const SizedBox(height: 12),
            _QuickAmountInput(categoryId: selected),
          ],
        ],
      ),
    );
  }
}

class _QuickAmountInput extends ConsumerStatefulWidget {
  final String categoryId;
  const _QuickAmountInput({required this.categoryId});

  @override
  ConsumerState<_QuickAmountInput> createState() => _QuickAmountInputState();
}

class _QuickAmountInputState extends ConsumerState<_QuickAmountInput> {
  final _amountCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _loading = false;

  @override
  void dispose() { _amountCtrl.dispose(); _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cat = getCategoryById(widget.categoryId);

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Color(cat.color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${cat.icon} ${cat.nameAr}',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                fontWeight: FontWeight.w600, color: Color(cat.color))),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'المبلغ',
                    filled: true, fillColor: AppColors.surface2,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _nameCtrl,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'وصف (اختياري)',
                    filled: true, fillColor: AppColors.surface2,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('📅 ${MudabbirDateUtils.formatDayAr(_date)}',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 11,
                      color: AppColors.textSecondary)),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => ref.read(_selectedQuickCatProvider.notifier).state = null,
                child: const Text('إلغاء',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                    color: AppColors.textTertiary)),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _loading ? null : _submit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _loading
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('إضافة',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                            fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    final amt = double.tryParse(_amountCtrl.text);
    if (amt == null || amt <= 0) return;
    setState(() => _loading = true);
    final cat = getCategoryById(widget.categoryId);
    await ref.read(expenseActionsProvider).addExpense(
      categoryId: widget.categoryId,
      name: _nameCtrl.text.isNotEmpty ? _nameCtrl.text : cat.nameAr,
      amount: amt,
      date: _date,
    );
    await ref.read(userActionsProvider).updateStreak();
    ref.read(_selectedQuickCatProvider.notifier).state = null;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم تسجيل $amt — ${cat.nameAr}',
            style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
