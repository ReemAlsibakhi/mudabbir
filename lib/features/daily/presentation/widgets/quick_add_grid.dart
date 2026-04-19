import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_card.dart';
import '../../../../shared/ui/widgets/mud_gradient_button.dart';
import '../../../expenses/domain/usecases/add_expense_usecase.dart';
import '../../presentation/providers/daily_notifier.dart';

final _selectedCatProvider = StateProvider.autoDispose<String?>((ref) => null);

class QuickAddGrid extends ConsumerWidget {
  final DateTime month;
  const QuickAddGrid({super.key, required this.month});

  static const _quickCats = ['food', 'restaurants', 'transport', 'shopping', 'health', 'other'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_selectedCatProvider);

    return MudCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MudSectionLabel('أو اختر الفئة مباشرة'),
          GridView.count(
            crossAxisCount: 3, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.2,
            children: _quickCats.map((id) {
              final cat = getCategoryById(id);
              final sel = selected == id;
              return GestureDetector(
                onTap: () => ref.read(_selectedCatProvider.notifier).state = sel ? null : id,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color:        sel ? Color(cat.color).withOpacity(0.15) : AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(
                      color: sel ? Color(cat.color) : AppColors.border,
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(cat.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(cat.nameAr.split('و').first,
                      style: AppTextStyles.label.copyWith(
                        color: sel ? Color(cat.color) : AppColors.textSecondary),
                      textAlign: TextAlign.center, maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  ]),
                ),
              );
            }).toList(),
          ),
          if (selected != null) ...[
            const SizedBox(height: 12),
            _QuickAmountInput(categoryId: selected!, month: month),
          ],
        ],
      ),
    );
  }
}

class _QuickAmountInput extends ConsumerStatefulWidget {
  final String   categoryId;
  final DateTime month;
  const _QuickAmountInput({required this.categoryId, required this.month});
  @override ConsumerState<_QuickAmountInput> createState() => _State();
}

class _State extends ConsumerState<_QuickAmountInput> {
  final _amtCtrl  = TextEditingController();
  final _nameCtrl = TextEditingController();
  DateTime _date  = DateTime.now();
  bool _loading   = false;
  String? _error;

  @override void dispose() { _amtCtrl.dispose(); _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cat = getCategoryById(widget.categoryId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Color(cat.color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
          child: Text('${cat.icon} ${cat.nameAr}',
            style: AppTextStyles.bodyBold.copyWith(color: Color(cat.color))),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: TextField(
            controller: _amtCtrl, autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textDirection: TextDirection.rtl,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary, fontSize: 16),
            onChanged: (_) { if (_error != null) setState(() => _error = null); },
            decoration: const InputDecoration(hintText: 'المبلغ',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
          )),
          const SizedBox(width: 8),
          Expanded(child: TextField(
            controller: _nameCtrl, textDirection: TextDirection.rtl,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'وصف (اختياري)',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
          )),
        ]),
        if (_error != null)
          Padding(padding: const EdgeInsets.only(top: 6),
            child: Text(_error!, style: AppTextStyles.caption.copyWith(color: AppColors.error))),
        const SizedBox(height: 10),
        Row(children: [
          GestureDetector(
            onTap: () => ref.read(_selectedCatProvider.notifier).state = null,
            child: const Padding(padding: EdgeInsets.all(8),
              child: Text('إلغاء', style: TextStyle(fontFamily:'Cairo',
                fontSize: 12, color: AppColors.textTertiary))),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _loading ? null : _submit,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient:     _loading ? null : AppColors.primary,
                color:        _loading ? AppColors.surface3 : null,
                borderRadius: BorderRadius.circular(10)),
              child: _loading
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('إضافة', style: AppTextStyles.button.copyWith(fontSize: 13)),
            ),
          ),
        ]),
      ],
    );
  }

  Future<void> _submit() async {
    final amt = double.tryParse(_amtCtrl.text.trim());
    if (amt == null || amt <= 0) {
      setState(() => _error = 'أدخل مبلغاً صحيحاً');
      return;
    }
    setState(() { _loading = true; _error = null; });

    final cat   = getCategoryById(widget.categoryId);
    final error = await ref.read(dailyActionsProvider).addExpenseAndLog(
      AddExpenseParams(
        categoryId: widget.categoryId,
        name:       _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : cat.nameAr,
        amountRaw:  _amtCtrl.text.trim(),
        date:       _date,
      ),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      setState(() => _error = error);
    } else {
      ref.read(_selectedCatProvider.notifier).state = null;
      context.showSnack('✅ تم تسجيل ${amt.toStringAsFixed(0)} — ${cat.nameAr}',
        color: AppColors.success);
    }
  }
}
