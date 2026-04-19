import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/ui/widgets/mud_gradient_button.dart';
import '../providers/goals_notifier.dart';
import '../../domain/entities/goal.dart';
import '../../domain/usecases/add_goal_usecase.dart';

class AddGoalSheet extends ConsumerStatefulWidget {
  const AddGoalSheet({super.key});

  static Future<void> show(BuildContext ctx, WidgetRef? _) =>
      showModalBottomSheet(
        context: ctx, isScrollControlled: true,
        builder: (_) => const AddGoalSheet(),
      );

  @override
  ConsumerState<AddGoalSheet> createState() => _State();
}

class _State extends ConsumerState<AddGoalSheet> {
  final _form       = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _savedCtrl  = TextEditingController();
  final _moCtrl     = TextEditingController();
  GoalType        _type    = GoalType.home;
  GoalInputMode   _mode    = GoalInputMode.byDuration;
  int             _months  = 12;
  bool            _loading = false;
  String?         _insight;

  @override
  void dispose() {
    _nameCtrl.dispose(); _targetCtrl.dispose();
    _savedCtrl.dispose(); _moCtrl.dispose();
    super.dispose();
  }

  void _calcInsight() {
    final target = double.tryParse(_targetCtrl.text.replaceAll(',', ''));
    final saved  = double.tryParse(_savedCtrl.text.replaceAll(',', '')) ?? 0;
    if (target == null || target <= 0) { setState(() => _insight = null); return; }
    final rem = (target - saved).clamp(0, double.infinity);
    if (_mode == GoalInputMode.byDuration) {
      setState(() => _insight = _months > 0
          ? 'تحتاج توفير ${(rem / _months).toStringAsFixed(0)} ريال شهرياً'
          : null);
    } else {
      final mo = double.tryParse(_moCtrl.text.replaceAll(',', ''));
      setState(() => _insight = mo != null && mo > 0
          ? 'ستصل لهدفك في ${(rem / mo).ceil()} شهر'
          : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, inset + 16),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(
                width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.textTertiary, borderRadius: BorderRadius.circular(99)),
              )),
              Text('✨ هدف مالي جديد', style: AppTextStyles.title),
              const SizedBox(height: 14),

              // Type selector
              _TypeSelector(selected: _type, onChanged: (t) => setState(() => _type = t)),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameCtrl, textDirection: TextDirection.rtl,
                validator: Validators.name,
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'اسم الهدف',
                  hintText:  'مثال: ${_type.nameAr}',
                ),
              ),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(child: TextFormField(
                  controller: _targetCtrl, keyboardType: TextInputType.number,
                  textDirection: TextDirection.rtl, validator: Validators.amount,
                  onChanged: (_) => _calcInsight(),
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'المبلغ المستهدف', hintText: '0'),
                )),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(
                  controller: _savedCtrl, keyboardType: TextInputType.number,
                  textDirection: TextDirection.rtl,
                  onChanged: (_) => _calcInsight(),
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'مدخر حالياً', hintText: '0'),
                )),
              ]),
              const SizedBox(height: 12),

              // Mode tabs
              _ModeTab(mode: _mode, onChanged: (m) { setState(() => _mode = m); _calcInsight(); }),
              const SizedBox(height: 12),

              if (_mode == GoalInputMode.byDuration)
                DropdownButtonFormField<int>(
                  value: _months, dropdownColor: AppColors.surface2,
                  decoration: const InputDecoration(labelText: 'المدة المطلوبة'),
                  items: [6,12,18,24,36,48,60,84,120].map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(_label(m), style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
                  )).toList(),
                  onChanged: (v) { setState(() => _months = v ?? 12); _calcInsight(); },
                )
              else
                TextFormField(
                  controller: _moCtrl, keyboardType: TextInputType.number,
                  textDirection: TextDirection.rtl,
                  onChanged: (_) => _calcInsight(),
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'الادخار الشهري', hintText: '0'),
                ),

              if (_insight != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:        AppColors.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border:       Border.all(color: AppColors.accent.withOpacity(0.15)),
                  ),
                  child: Text(_insight!, style: AppTextStyles.body),
                ),
              ],
              const SizedBox(height: 16),
              MudGradientButton(label: 'إضافة الهدف', loading: _loading, onTap: _submit),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  String _label(int m) {
    if (m < 12)  return '$m أشهر';
    if (m == 12) return 'سنة';
    if (m == 24) return 'سنتان';
    return '${m ~/ 12} سنوات';
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    final success = await ref.read(goalsNotifierProvider.notifier).addGoal(
      AddGoalParams(
        type:           _type,
        name:           _nameCtrl.text,
        targetRaw:      _targetCtrl.text,
        savedRaw:       _savedCtrl.text,
        mode:           _mode,
        durationMonths: _mode == GoalInputMode.byDuration ? _months : null,
        monthlyRaw:     _mode == GoalInputMode.byMonthly  ? _moCtrl.text : null,
      ),
    );

    if (!mounted) return;
    setState(() => _loading = false);
    if (success) { context.popScreen(); context.showSnack('✅ تمت إضافة الهدف', color: AppColors.success); }
  }
}

class _TypeSelector extends StatelessWidget {
  final GoalType type;
  final ValueChanged<GoalType> onChanged;
  const _TypeSelector({required this.type, required this.onChanged});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8, runSpacing: 8,
    children: GoalType.values.map((t) {
      final sel = t == type;
      return GestureDetector(
        onTap: () => onChanged(t),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color:        sel ? AppColors.accent.withOpacity(0.15) : AppColors.surface2,
            borderRadius: BorderRadius.circular(10),
            border:       Border.all(color: sel ? AppColors.accent : AppColors.border, width: sel ? 1.5 : 1),
          ),
          child: Text('${t.icon} ${t.nameAr}', style: AppTextStyles.caption.copyWith(
            color: sel ? AppColors.accentAlt : AppColors.textSecondary)),
        ),
      );
    }).toList(),
  );
}

class _ModeTab extends StatelessWidget {
  final GoalInputMode mode;
  final ValueChanged<GoalInputMode> onChanged;
  const _ModeTab({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      _Btn(label: 'حدد المدة',          m: GoalInputMode.byDuration, sel: mode, onTap: onChanged),
      _Btn(label: 'حدد المبلغ الشهري', m: GoalInputMode.byMonthly,  sel: mode, onTap: onChanged),
    ]),
  );
}

class _Btn extends StatelessWidget {
  final String label; final GoalInputMode m, sel; final ValueChanged<GoalInputMode> onTap;
  const _Btn({required this.label, required this.m, required this.sel, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final active = m == sel;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(m),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color:        active ? AppColors.surface3 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Text(label, style: AppTextStyles.caption.copyWith(
            color: active ? AppColors.accentAlt : AppColors.textTertiary,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          ))),
        ),
      ),
    );
  }
}
