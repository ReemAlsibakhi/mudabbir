import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_gradient_button.dart';
import '../../../expenses/domain/usecases/add_expense_usecase.dart';
import '../../presentation/providers/daily_notifier.dart';

final _selectedCatProvider  = StateProvider<String?>((ref) => null);
final _amountCtrlProvider   = StateProvider<TextEditingController>((ref) {
  final ctrl = TextEditingController();
  ref.onDispose(ctrl.dispose);
  return ctrl;
});

class QuickAddGrid extends ConsumerWidget {
  final DateTime month;
  const QuickAddGrid({super.key, required this.month});

  static const _topCats = ['food','restaurants','transport','shopping','health','other'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_selectedCatProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('إضافة سريعة', style: AppTextStyles.label),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap:     true,
          physics:        const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8, crossAxisSpacing: 8,
          childAspectRatio: 1.3,
          children: _topCats.map((id) {
            final cat = getCategoryById(id);
            final isActive = selected == id;
            final catColor = Color(cat.color);
            return GestureDetector(
              onTap: () => ref.read(_selectedCatProvider.notifier).state =
                  isActive ? null : id,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color:        isActive ? catColor.withOpacity(0.12) : AppColors.surface1,
                  borderRadius: BorderRadius.circular(14),
                  border:       Border.all(
                    color: isActive ? catColor.withOpacity(0.4) : AppColors.border,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cat.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 5),
                    Text(
                      cat.nameAr.split('و').first.trim(),
                      style: AppTextStyles.caption.copyWith(
                        color: isActive ? catColor : AppColors.textTertiary,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (selected != null) ...[
          const SizedBox(height: 10),
          _AmountInput(categoryId: selected, month: month),
        ],
        const SizedBox(height: 10),
      ],
    );
  }
}

class _AmountInput extends ConsumerStatefulWidget {
  final String categoryId;
  final DateTime month;
  const _AmountInput({required this.categoryId, required this.month});

  @override
  ConsumerState<_AmountInput> createState() => _State();
}

class _State extends ConsumerState<_AmountInput> {
  final _amountCtrl = TextEditingController();
  final _nameCtrl   = TextEditingController();
  DateTime _date    = DateTime.now();
  bool _loading     = false;

  @override
  void dispose() { _amountCtrl.dispose(); _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cat   = getCategoryById(widget.categoryId);
    final color = Color(cat.color);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('${cat.icon} ${cat.nameAr}',
                style: AppTextStyles.bodyBold.copyWith(color: color, fontSize: 12)),
              const Spacer(),
              GestureDetector(
                onTap: () => ref.read(_selectedCatProvider.notifier).state = null,
                child: Icon(Icons.close_rounded, size: 16, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller:   _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textDirection: TextDirection.rtl,
                  autofocus:    true,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText:       'المبلغ',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextField(
                  controller:    _nameCtrl,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText:       'وصف (اختياري)',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MudGradientButton(
            label: 'إضافة',
            onTap: _submit,
            loading: _loading,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final amt = double.tryParse(_amountCtrl.text.trim());
    if (amt == null || amt <= 0) return;
    setState(() => _loading = true);
    final cat = getCategoryById(widget.categoryId);
    final error = await ref.read(dailyActionsProvider).addExpenseAndLog(
      AddExpenseParams(
        categoryId: widget.categoryId,
        name: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : cat.nameAr,
        amountRaw: _amountCtrl.text.trim(),
        date: DateTime.now(),
      ),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error == null) {
      ref.read(_selectedCatProvider.notifier).state = null;
      context.showSnack('✅ تم تسجيل ${amt.toStringAsFixed(0)} ريال',
        color: AppColors.success);
    } else {
      context.showSnack(error, color: AppColors.error);
    }
  }
}
