import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/ui/widgets/mud_gradient_button.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../providers/expenses_notifier.dart';

class AddExpenseSheet extends StatefulWidget {
  final DateTime month;
  final WidgetRef ref;
  const AddExpenseSheet({super.key, required this.month, required this.ref});

  static Future<void> show(BuildContext context, DateTime month, WidgetRef ref) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => AddExpenseSheet(month: month, ref: ref),
      );

  @override
  State<AddExpenseSheet> createState() => _State();
}

class _State extends State<AddExpenseSheet> {
  final _formKey    = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _nameCtrl   = TextEditingController();
  String   _catId   = 'food';
  DateTime _date    = DateTime.now();
  bool     _loading = false;
  String?  _error;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('➕ إضافة مصروف', style: AppTextStyles.title),
          ),
          const SizedBox(height: 16),

          // Category
          DropdownButtonFormField<String>(
            value:        _catId,
            dropdownColor: AppColors.surface2,
            decoration:   const InputDecoration(labelText: 'الفئة'),
            items: variableCategories.map((c) => DropdownMenuItem(
              value: c.id,
              child: Text('${c.icon} ${c.nameAr}',
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
            )).toList(),
            onChanged: (v) => setState(() => _catId = v ?? 'food'),
          ),
          const SizedBox(height: 12),

          // Date picker
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color:        AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Text('📅 ', style: TextStyle(fontSize: 16)),
                  Text(_date.dayFullAr,
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Amount
          TextFormField(
            controller:   _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textDirection: TextDirection.rtl,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d٠-٩.,٫]')),
            ],
            validator: Validators.amount,
            decoration: const InputDecoration(labelText: 'المبلغ', hintText: '0'),
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary, fontSize: 16),
          ),
          const SizedBox(height: 12),

          // Name
          TextFormField(
            controller:   _nameCtrl,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'الوصف (اختياري)',
              hintText:  'مثال: بقالة الخميس',
            ),
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),

          // Error from notifier
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
          ],
          const SizedBox(height: 16),

          MudGradientButton(
            label:   'إضافة',
            onTap:   _submit,
            loading: _loading,
          ),
        ],
      ),
    ),
  );

  Future<void> _pickDate() async {
    final now   = DateTime.now();
    final limit = now.subtract(const Duration(days: 90));
    final picked = await showDatePicker(
      context:     context,
      initialDate: _date,
      firstDate:   limit,
      lastDate:    now,
    );
    // Edge: user dismissed picker → keep existing date
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    final error = await widget.ref
        .read(expensesNotifierProvider(widget.month.monthKey).notifier)
        .addExpense(AddExpenseParams(
          categoryId: _catId,
          name:       _nameCtrl.text.trim(),
          amountRaw:  _amountCtrl.text.trim(),
          date:       _date,
        ));

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      setState(() => _error = error);
    } else {
      context.popScreen();
      context.showSnack('✅ تم تسجيل المصروف', color: AppColors.success);
    }
  }
}
