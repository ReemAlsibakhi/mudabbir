import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/providers/goals_provider.dart';
import '../../../data/models/goal.dart';
import '../../../data/providers/user_provider.dart';
import '../../../shared/widgets/mud_card.dart';

final _goalTabProvider = StateProvider<int>((ref) => 0); // 0=list 1=add
final _goalModeProvider = StateProvider<String>((ref) => 'duration'); // duration|monthly

const _goalTypes = [
  {'id': 'home',      'icon': '🏠', 'name': 'شراء منزل'},
  {'id': 'car',       'icon': '🚗', 'name': 'سيارة'},
  {'id': 'wedding',   'icon': '💍', 'name': 'زواج'},
  {'id': 'travel',    'icon': '✈️', 'name': 'سفر وإجازة'},
  {'id': 'education', 'icon': '🎓', 'name': 'تعليم الأبناء'},
  {'id': 'emergency', 'icon': '🛡️', 'name': 'صندوق طوارئ'},
  {'id': 'business',  'icon': '💼', 'name': 'مشروع تجاري'},
  {'id': 'other',     'icon': '⭐', 'name': 'أخرى'},
];

const _durations = [6, 12, 18, 24, 36, 48, 60, 84, 120];

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(_goalTabProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🎯 الأهداف المالية',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w800)),
                  GestureDetector(
                    onTap: () => ref.read(_goalTabProvider.notifier).state = tab == 0 ? 1 : 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(tab == 0 ? '➕ هدف جديد' : '← الأهداف',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
                          fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: tab == 0 ? const _GoalsList() : const _AddGoalForm(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalsList extends ConsumerWidget {
  const _GoalsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);

    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            const Text('لم تضف أي هدف بعد',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => ref.read(_goalTabProvider.notifier).state = 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('أضف هدفك الأول',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (_, i) => _GoalCard(goal: goals[i]),
    );
  }
}

class _GoalCard extends ConsumerStatefulWidget {
  final Goal goal;
  const _GoalCard({required this.goal});

  @override
  ConsumerState<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends ConsumerState<_GoalCard> {
  final _addCtrl = TextEditingController();

  @override
  void dispose() { _addCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final g = widget.goal;
    final type = _goalTypes.firstWhere((t) => t['id'] == g.type, orElse: () => _goalTypes.last);
    final pct  = g.progress;
    final gradColor = pct >= 1.0 ? AppColors.green : AppColors.accent;

    return MudCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(type['icon']!, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.name,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(type['name']!,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(goalsActionsProvider).deleteGoal(g.id),
                child: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 9,
              backgroundColor: AppColors.surface3,
              valueColor: AlwaysStoppedAnimation(gradColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('مدخر: ${g.saved.toStringAsFixed(0)} ريال',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary)),
              Text('${(pct * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w800, color: gradColor)),
              Text('الهدف: ${g.target.toStringAsFixed(0)} ريال',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          // Insight
          if (pct < 1.0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.06),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.accent.withOpacity(0.12)),
              ),
              child: Text(
                pct >= 1.0
                    ? '🎉 تم تحقيق الهدف!'
                    : '💡 المتبقي: ${g.remaining.toStringAsFixed(0)} ريال'
                      '${g.monthsLeft > 0 ? ' · بمعدلك الحالي تحتاج ${g.monthsLeft} شهر' : ''}',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 12,
                  color: AppColors.textSecondary, height: 1.6),
              ),
            ),
          ],
          // Add amount
          if (pct < 1.0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addCtrl,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'إضافة مبلغ (ريال)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addToGoal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('إضافة',
                      style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700,
                        color: Colors.white, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ] else
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('🎉 تم تحقيق الهدف! مبروك!',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700,
                    color: AppColors.green)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addToGoal() async {
    final amt = double.tryParse(_addCtrl.text);
    if (amt == null || amt <= 0) return;
    await ref.read(goalsActionsProvider).addToGoal(widget.goal.id, amt);
    _addCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ تم إضافة ${amt.toStringAsFixed(0)} ريال للهدف',
        style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.green, behavior: SnackBarBehavior.floating),
    );
  }
}

class _AddGoalForm extends ConsumerStatefulWidget {
  const _AddGoalForm();
  @override
  ConsumerState<_AddGoalForm> createState() => _AddGoalFormState();
}

class _AddGoalFormState extends ConsumerState<_AddGoalForm> {
  final _nameCtrl    = TextEditingController();
  final _targetCtrl  = TextEditingController();
  final _savedCtrl   = TextEditingController();
  final _monthlyCtrl = TextEditingController();
  String _type = 'home';
  int _durMonths = 12;
  String _mode = 'duration';

  @override
  void dispose() {
    _nameCtrl.dispose(); _targetCtrl.dispose();
    _savedCtrl.dispose(); _monthlyCtrl.dispose();
    super.dispose();
  }

  double get _calcMonthly {
    final target = double.tryParse(_targetCtrl.text) ?? 0;
    final saved  = double.tryParse(_savedCtrl.text) ?? 0;
    final rem    = (target - saved).clamp(0, double.infinity);
    return _durMonths > 0 ? rem / _durMonths : 0;
  }

  int get _calcMonths {
    final target  = double.tryParse(_targetCtrl.text) ?? 0;
    final saved   = double.tryParse(_savedCtrl.text) ?? 0;
    final monthly = double.tryParse(_monthlyCtrl.text) ?? 0;
    final rem     = (target - saved).clamp(0, double.infinity);
    return monthly > 0 ? (rem / monthly).ceil() : 0;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MudCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal Type
              const MudSectionTitle('نوع الهدف'),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _goalTypes.map((t) {
                  final sel = _type == t['id'];
                  return GestureDetector(
                    onTap: () => setState(() => _type = t['id']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.accent.withOpacity(0.15) : AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel ? AppColors.accent : AppColors.border,
                          width: sel ? 1.5 : 1,
                        ),
                      ),
                      child: Text('${t['icon']} ${t['name']}',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? AppColors.accent2 : AppColors.textSecondary)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              // Name
              TextField(controller: _nameCtrl, textDirection: TextDirection.rtl,
                style: const TextStyle(fontFamily: 'Cairo'),
                decoration: const InputDecoration(labelText: 'اسم الهدف',
                  hintText: 'مثال: منزل العائلة في الرياض')),
              const SizedBox(height: 12),
              // Target
              TextField(controller: _targetCtrl, keyboardType: TextInputType.number,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontFamily: 'Cairo'),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'المبلغ المستهدف (ريال)', hintText: '0')),
              const SizedBox(height: 12),
              // Saved
              TextField(controller: _savedCtrl, keyboardType: TextInputType.number,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontFamily: 'Cairo'),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'المدخر حالياً (ريال)', hintText: '0')),
              const SizedBox(height: 14),

              // Mode tabs
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    _ModeTab(label: 'حدد المدة', mode: 'duration', selected: _mode,
                      onTap: () => setState(() => _mode = 'duration')),
                    _ModeTab(label: 'حدد المبلغ الشهري', mode: 'monthly', selected: _mode,
                      onTap: () => setState(() => _mode = 'monthly')),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (_mode == 'duration') ...[
                DropdownButtonFormField<int>(
                  value: _durMonths,
                  dropdownColor: AppColors.surface2,
                  decoration: const InputDecoration(labelText: 'المدة المطلوبة'),
                  items: _durations.map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(_durationLabel(m), style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                  )).toList(),
                  onChanged: (v) => setState(() => _durMonths = v ?? 12),
                ),
                if (_targetCtrl.text.isNotEmpty && _calcMonthly > 0) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.accent.withOpacity(0.15)),
                    ),
                    child: Text(
                      'لتحقيق هدفك خلال $_durMonths شهر تحتاج توفير '
                      '${_calcMonthly.toStringAsFixed(0)} ريال شهرياً',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
                        color: AppColors.textSecondary, height: 1.6),
                    ),
                  ),
                ],
              ] else ...[
                TextField(controller: _monthlyCtrl, keyboardType: TextInputType.number,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontFamily: 'Cairo'),
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'مقدار الادخار الشهري (ريال)', hintText: '0')),
                if (_monthlyCtrl.text.isNotEmpty && _calcMonths > 0) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.accent.withOpacity(0.15)),
                    ),
                    child: Text(
                      'بادخار ${_monthlyCtrl.text} ريال شهرياً ستصل لهدفك '
                      'خلال $_calcMonths شهر (${(_calcMonths / 12).toStringAsFixed(1)} سنة)',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
                        color: AppColors.textSecondary, height: 1.6),
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 16),
              GestureDetector(
                onTap: _submit,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('✨ إضافة الهدف',
                      style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700,
                        color: Colors.white, fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _durationLabel(int m) {
    if (m < 12) return '$m أشهر';
    if (m == 12) return 'سنة واحدة';
    if (m == 24) return 'سنتان';
    return '${m ~/ 12} سنوات';
  }

  Future<void> _submit() async {
    final name   = _nameCtrl.text;
    final target = double.tryParse(_targetCtrl.text);
    if (name.isEmpty || target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل الاسم والمبلغ المستهدف', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating),
      );
      return;
    }
    final saved   = double.tryParse(_savedCtrl.text) ?? 0;
    final monthly = _mode == 'duration' ? _calcMonthly
        : (double.tryParse(_monthlyCtrl.text) ?? 0);
    final months  = _mode == 'duration' ? _durMonths : _calcMonths;

    await ref.read(goalsActionsProvider).addGoal(
      type: _type, name: name, target: target,
      saved: saved, monthlyTarget: monthly, targetMonths: months,
    );
    ref.read(_goalTabProvider.notifier).state = 0;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تمت إضافة الهدف', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.green, behavior: SnackBarBehavior.floating),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label, mode, selected;
  final VoidCallback onTap;
  const _ModeTab({required this.label, required this.mode, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = mode == selected;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? AppColors.surface3 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(label,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600,
                color: active ? AppColors.accent2 : AppColors.textTertiary)),
          ),
        ),
      ),
    );
  }
}
