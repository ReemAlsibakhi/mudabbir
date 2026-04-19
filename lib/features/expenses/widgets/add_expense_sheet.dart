import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/categories.dart';
import '../../../core/extensions/datetime_ext.dart';
import '../../../core/utils/validators.dart';
import '../providers/expenses_provider.dart';

/// Bottom sheet لإضافة مصروف متغير يومي
class AddExpenseSheet extends ConsumerStatefulWidget {
  const AddExpenseSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface2,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const AddExpenseSheet(),
  );

  @override
  ConsumerState<AddExpenseSheet> createState() => _State();
}

class _State extends ConsumerState<AddExpenseSheet> {
  final _formKey    = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _nameCtrl   = TextEditingController();
  String   _catId   = 'food';
  DateTime _date    = DateTime.now();
  bool     _loading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, bottomPad + 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text('➕ إضافة مصروف',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              value: _catId,
              dropdownColor: AppColors.surface2,
              decoration: const InputDecoration(labelText: 'الفئة'),
              items: variableCategories.map((c) => DropdownMenuItem(
                value: c.id,
                child: Text('${c.icon} ${c.nameAr}',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
              )).toList(),
              onChanged: (v) => setState(() => _catId = v ?? 'food'),
            ),
            const SizedBox(height: 12),

            // Date picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(children: [
                  const Text('📅 '),
                  Text(_date.dayFullAr,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
                      color: AppColors.textSecondary)),
                ]),
              ),
            ),
            const SizedBox(height: 12),

            // Amount
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.rtl,
              validator: Validators.amount,
              decoration: const InputDecoration(labelText: 'المبلغ', hintText: '0'),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
            ),
            const SizedBox(height: 12),

            // Description
            TextFormField(
              controller: _nameCtrl,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                labelText: 'الوصف (اختياري)',
                hintText: 'مثال: بقالة الخميس',
              ),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Submit
            _SubmitButton(loading: _loading, onTap: _submit),
          ],
        ),
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final cat = getCategoryById(_catId);
    await ref.read(expenseActionsProvider).addExpense(
      categoryId: _catId,
      name: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : cat.nameAr,
      amount: double.parse(_amountCtrl.text),
      date: _date,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('✅ تم تسجيل ${_amountCtrl.text} ريال',
          style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}

class _SubmitButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const _SubmitButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: loading
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('➕ إضافة',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 15,
                  fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    ),
  );
}
