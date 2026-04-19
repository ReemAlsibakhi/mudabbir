import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/ui/widgets/mud_gradient_button.dart';
import '../providers/expenses_notifier.dart';
import '../../domain/usecases/add_fixed_expense_usecase.dart';

class AddFixedSheet extends ConsumerStatefulWidget {
  const AddFixedSheet({super.key});

  static Future<void> show(BuildContext ctx, WidgetRef ref) =>
      showModalBottomSheet(
        context:        ctx,
        isScrollControlled: true,
        builder:        (_) => const AddFixedSheet(),
      );

  @override
  ConsumerState<AddFixedSheet> createState() => _State();
}

class _State extends ConsumerState<AddFixedSheet> {
  final _form    = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amtCtrl  = TextEditingController();
  String _catId   = 'rent';
  bool   _loading = false;

  @override
  void dispose() { _nameCtrl.dispose(); _amtCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, inset + 16),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(
              width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: AppColors.textTertiary, borderRadius: BorderRadius.circular(99)),
            )),
            Text('📅 إضافة مصروف ثابت', style: AppTextStyles.title),
            const SizedBox(height: 6),
            Text('يُضاف تلقائياً كل شهر', style: AppTextStyles.caption),
            const SizedBox(height: 14),

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
              validator: Validators.name,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'الاسم', hintText: 'مثال: إيجار الشقة'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amtCtrl, keyboardType: TextInputType.number,
              textDirection: TextDirection.rtl, validator: Validators.amount,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'المبلغ الشهري', hintText: '0'),
            ),
            const SizedBox(height: 16),
            MudGradientButton(label: '➕ إضافة — يُضاف كل شهر تلقائياً', loading: _loading, onTap: _submit),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final monthKey = ref.read(selectedMonthProvider).toString().substring(0, 7);
    final success = await ref
        .read(expensesNotifierProvider(monthKey).notifier)
        .addFixedExpense(AddFixedExpenseParams(
          categoryId: _catId, name: _nameCtrl.text, amountRaw: _amtCtrl.text,
        ));
    if (!mounted) return;
    setState(() => _loading = false);
    if (success) { context.popScreen(); context.showSnack('✅ تمت الإضافة', color: AppColors.success); }
  }
}
