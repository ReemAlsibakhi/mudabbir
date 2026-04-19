import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/ui/widgets/mud_gradient_button.dart';
import '../../domain/entities/goal.dart';
import '../../domain/usecases/add_goal_usecase.dart';
import '../providers/goals_notifier.dart';

class AddGoalSheet extends StatefulWidget {
  final WidgetRef ref;
  const AddGoalSheet({super.key, required this.ref});

  static Future<void> show(BuildContext context, WidgetRef ref) =>
      showModalBottomSheet(
        context:         context,
        isScrollControlled: true,
        builder:         (_) => AddGoalSheet(ref: ref),
      );

  @override
  State<AddGoalSheet> createState() => _State();
}

class _State extends State<AddGoalSheet> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _targetCtrl   = TextEditingController();
  final _savedCtrl    = TextEditingController();
  final _monthlyCtrl  = TextEditingController();

  GoalType        _type     = GoalType.home;
  GoalInputMode   _mode     = GoalInputMode.byDuration;
  int             _duration = 24;
  bool            _loading  = false;
  String?         _error;

  // Live calculation
  double get _target    => double.tryParse(_targetCtrl.text.replaceAll(',', '')) ?? 0;
  double get _saved     => double.tryParse(_savedCtrl.text.replaceAll(',', '')) ?? 0;
  double get _remaining => (_target - _saved).clamp(0, double.infinity);

  double get _calcMonthly    => _duration > 0 && _remaining > 0 ? _remaining / _duration : 0;
  int    get _calcMonths {
    final mo = double.tryParse(_monthlyCtrl.text.replaceAll(',', '')) ?? 0;
    return mo > 0 && _remaining > 0 ? (_remaining / mo).ceil() : 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _targetCtrl.dispose();
    _savedCtrl.dispose(); _monthlyCtrl.dispose();
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text('✨ هدف مالي جديد', style: AppTextStyles.title)),
            const SizedBox(height: 16),

            // Goal type chips
            Wrap(
              spacing: 8, runSpacing: 8,
              children: GoalType.values.map((t) {
                final sel = _type == t;
                return GestureDetector(
                  onTap: () => setState(() => _type = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color:        sel ? AppColors.accent.withOpacity(0.15) : AppColors.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border:       Border.all(
                        color: sel ? AppColors.accent : AppColors.border, width: sel ? 1.5 : 1),
                    ),
                    child: Text('${t.icon} ${t.nameAr}',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: sel ? AppColors.accentAlt : AppColors.textSecondary)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _nameCtrl, textDirection: TextDirection.rtl,
              validator:  Validators.name,
              decoration: const InputDecoration(
                labelText: 'اسم الهدف',
                hintText:  'مثال: منزل العائلة في الرياض'),
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller:   _targetCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textDirection: TextDirection.rtl,
              validator:    Validators.amount,
              onChanged:    (_) => setState(() {}),
              decoration:   const InputDecoration(labelText: 'المبلغ المستهدف', hintText: '0'),
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller:   _savedCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textDirection: TextDirection.rtl,
              onChanged:    (_) => setState(() {}),
              decoration:   const InputDecoration(
                labelText: 'المدخر حالياً', hintText: '0 (إذا لم يكن لديك مدخرات بعد)'),
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),

            // Mode selector
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: GoalInputMode.values.map((m) {
                  final active = _mode == m;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _mode = m),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color:        active ? AppColors.surface3 : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            m == GoalInputMode.byDuration ? 'حدد المدة' : 'حدد المبلغ الشهري',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: active ? AppColors.accentAlt : AppColors.textTertiary),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            if (_mode == GoalInputMode.byDuration) ...[
              DropdownButtonFormField<int>(
                value: _duration, dropdownColor: AppColors.surface2,
                onChanged: (v) => setState(() => _duration = v ?? 12),
                decoration: const InputDecoration(labelText: 'المدة المطلوبة'),
                items: [6,12,18,24,36,48,60,84,120,180,240].map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(_monthLabel(m), style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary)),
                )).toList(),
              ),
              if (_calcMonthly > 0) ...[
                const SizedBox(height: 10),
                _InsightBox(
                  text: 'تحتاج توفير ${_calcMonthly.toStringAsFixed(0)} شهرياً خلال $_duration شهر',
                ),
              ],
            ] else ...[
              TextFormField(
                controller:   _monthlyCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textDirection: TextDirection.rtl,
                onChanged:    (_) => setState(() {}),
                decoration:   const InputDecoration(
                  labelText: 'مقدار الادخار الشهري', hintText: '0'),
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              ),
              if (_calcMonths > 0) ...[
                const SizedBox(height: 10),
                _InsightBox(
                  text: 'ستصل لهدفك في $_calcMonths شهر '
                        '(${(_calcMonths / 12).toStringAsFixed(1)} سنة)',
                ),
              ],
            ],

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
            ],
            const SizedBox(height: 16),

            MudGradientButton(label: '✨ إضافة الهدف', onTap: _submit, loading: _loading),
          ],
        ),
      ),
    ),
  );

  String _monthLabel(int m) {
    if (m < 12)  return '$m أشهر';
    if (m == 12) return 'سنة واحدة';
    if (m == 24) return 'سنتان';
    if (m % 12 == 0) return '${m ~/ 12} سنوات';
    return '$m شهراً';
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    final error = await widget.ref.read(goalsNotifierProvider.notifier).addGoal(
      AddGoalParams(
        type:             _type,
        name:             _nameCtrl.text,
        targetRaw:        _targetCtrl.text,
        savedRaw:         _savedCtrl.text,
        mode:             _mode,
        durationMonths:   _mode == GoalInputMode.byDuration ? _duration : null,
        monthlyAmountRaw: _mode == GoalInputMode.byMonthlyAmount ? _monthlyCtrl.text : null,
      ),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      setState(() => _error = error);
    } else {
      context.popScreen();
      context.showSnack('✅ تمت إضافة الهدف', color: AppColors.success);
    }
  }
}

class _InsightBox extends StatelessWidget {
  final String text;
  const _InsightBox({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color:        AppColors.accent.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      border:       Border.all(color: AppColors.accent.withOpacity(0.15)),
    ),
    child: Text(text, style: AppTextStyles.body),
  );
}
