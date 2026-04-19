import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_gradient_button.dart';
import '../../domain/usecases/add_fixed_expense_usecase.dart';
import '../providers/expenses_notifier.dart';

class AddFixedExpenseSheet extends StatefulWidget {
  final String    monthKey;
  final WidgetRef ref;
  const AddFixedExpenseSheet({super.key, required this.monthKey, required this.ref});

  static Future<void> show(BuildContext ctx, String monthKey, WidgetRef ref) =>
      showModalBottomSheet(
        context: ctx, isScrollControlled: true,
        builder: (_) => AddFixedExpenseSheet(monthKey: monthKey, ref: ref),
      );

  @override
  State<AddFixedExpenseSheet> createState() => _State();
}

class _State extends State<AddFixedExpenseSheet> {
  final _formKey    = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _nameCtrl   = TextEditingController();
  String  _catId    = 'rent';
  int?    _dueDay;
  bool    _loading  = false;
  String? _error;

  @override
  void dispose() { _amountCtrl.dispose(); _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 16, right: 16, top: 8,
      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
    ),
    child: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('📅 إضافة مصروف ثابت', style: AppTextStyles.title),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _catId, dropdownColor: AppColors.surface2,
            decoration: const InputDecoration(labelText: 'النوع'),
            items: fixedCategories.map((c) => DropdownMenuItem(
              value: c.id,
              child: Text('${c.icon} ${c.nameAr}',
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
            )).toList(),
            onChanged: (v) => setState(() => _catId = v ?? 'rent'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameCtrl, textDirection: TextDirection.rtl,
            validator: (v) => (v?.trim().isEmpty ?? true) ? 'الاسم مطلوب' : null,
            decoration: const InputDecoration(labelText: 'الاسم', hintText: 'مثال: إيجار الشقة'),
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textDirection: TextDirection.rtl,
            validator: (v) => (v?.trim().isEmpty ?? true) ? 'المبلغ مطلوب' : null,
            decoration: const InputDecoration(labelText: 'المبلغ الشهري', hintText: '0'),
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          // Due day selector
          DropdownButtonFormField<int?>(
            value: _dueDay, dropdownColor: AppColors.surface2,
            decoration: const InputDecoration(labelText: 'يوم الاستحقاق (اختياري)'),
            items: [
              const DropdownMenuItem(value: null, child: Text('غير محدد', style: TextStyle(fontFamily: 'Cairo'))),
              ...List.generate(28, (i) => DropdownMenuItem(
                value: i + 1,
                child: Text('اليوم ${i + 1}', style: const TextStyle(fontFamily: 'Cairo')),
              )),
            ],
            onChanged: (v) => setState(() => _dueDay = v),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
          ],
          const SizedBox(height: 16),
          MudGradientButton(
            label: 'إضافة — يتكرر كل شهر تلقائياً',
            onTap: _submit, loading: _loading,
          ),
        ],
      ),
    ),
  );

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    final error = await widget.ref
        .read(expensesNotifierProvider(widget.monthKey).notifier)
        .addFixedExpense(AddFixedExpenseParams(
          categoryId:    _catId,
          name:          _nameCtrl.text.trim(),
          amountRaw:     _amountCtrl.text.trim(),
          dueDayOfMonth: _dueDay,
        ));

    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      setState(() => _error = error);
    } else {
      context.popScreen();
      context.showSnack('✅ تمت الإضافة — سيتكرر كل شهر', color: AppColors.success);
    }
  }
}
