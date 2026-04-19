// ═══════════════════════════════════════════════════════════
// IncomeForm — Handles all input edge cases
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_card.dart';
import '../../../../shared/ui/widgets/mud_gradient_button.dart';
import '../../domain/entities/income.dart';

typedef OnSaveCallback = void Function(
  String primary,
  String secondary,
  String extra,
);

class IncomeForm extends StatefulWidget {
  final Income         income;
  final OnSaveCallback onSave;

  const IncomeForm({
    super.key,
    required this.income,
    required this.onSave,
  });

  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  final _formKey       = GlobalKey<FormState>();
  final _primaryCtrl   = TextEditingController();
  final _secondaryCtrl = TextEditingController();
  final _extraCtrl     = TextEditingController();
  bool _isDirty        = false;

  @override
  void initState() {
    super.initState();
    _loadFromIncome(widget.income);
    _primaryCtrl.addListener(_markDirty);
    _secondaryCtrl.addListener(_markDirty);
    _extraCtrl.addListener(_markDirty);
  }

  // Edge: income changes externally (month switched)
  @override
  void didUpdateWidget(IncomeForm old) {
    super.didUpdateWidget(old);
    if (old.income.monthKey != widget.income.monthKey) {
      _loadFromIncome(widget.income);
      setState(() => _isDirty = false);
    }
  }

  void _loadFromIncome(Income i) {
    _primaryCtrl.text   = i.primary   > 0 ? i.primary.toStringAsFixed(0)   : '';
    _secondaryCtrl.text = i.secondary > 0 ? i.secondary.toStringAsFixed(0) : '';
    _extraCtrl.text     = i.extra     > 0 ? i.extra.toStringAsFixed(0)     : '';
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  @override
  void dispose() {
    _primaryCtrl.dispose();
    _secondaryCtrl.dispose();
    _extraCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MudCard(
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MudSectionLabel('إدخال الدخل الشهري'),

          _IncomeField(
            label:      '👨 ${widget.income.monthKey.isNotEmpty ? "الدخل الأساسي" : "راتبك الشهري"}',
            controller: _primaryCtrl,
            hint:       'مثال: 8000',
            autofocus:  true,
          ),
          const SizedBox(height: 12),

          _IncomeField(
            label:      '👩 دخل الشريك (اختياري)',
            controller: _secondaryCtrl,
            hint:       '0',
          ),
          const SizedBox(height: 12),

          _IncomeField(
            label:      '💼 دخل إضافي (مكافآت، إيجارات، عمل حر...)',
            controller: _extraCtrl,
            hint:       '0',
          ),
          const SizedBox(height: 16),

          MudGradientButton(
            label:   _isDirty ? '💾 حفظ الدخل' : '✅ محفوظ',
            onTap:   _isDirty ? _submit : () {},
            loading: false,
          ),

          // Edge: unsaved changes warning
          if (_isDirty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '⚠️ لديك تغييرات غير محفوظة',
                style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    ),
  );

  void _submit() {
    // Edge: form might not be valid
    if (!(_formKey.currentState?.validate() ?? false)) return;

    widget.onSave(
      _primaryCtrl.text.trim(),
      _secondaryCtrl.text.trim(),
      _extraCtrl.text.trim(),
    );

    setState(() => _isDirty = false);
  }
}

// ─── Field ─────────────────────────────────────────────────
class _IncomeField extends StatelessWidget {
  final String                  label;
  final TextEditingController   controller;
  final String                  hint;
  final bool                    autofocus;

  const _IncomeField({
    required this.label,
    required this.controller,
    required this.hint,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextFormField(
        controller:   controller,
        autofocus:    autofocus,
        textDirection: TextDirection.rtl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          // Allow digits, dot, comma, Arabic-Indic digits
          FilteringTextInputFormatter.allow(RegExp(r'[\d٠-٩.,]')),
        ],
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(hintText: hint),
        // Edge: empty = valid (means zero income)
        validator: (v) {
          if (v == null || v.trim().isEmpty) return null; // optional
          final n = double.tryParse(
            v.trim()
             .replaceAll(',', '')
             .replaceAll(RegExp(r'[٠-٩]'), (m) => (m.codeUnitAt(0) - 0x0660).toString()),
          );
          if (n == null)  return 'أدخل رقماً صحيحاً';
          if (n < 0)      return 'لا يمكن أن يكون سالباً';
          if (n > 1e9)    return 'الرقم كبير جداً';
          return null;
        },
      ),
    ],
  );
}
