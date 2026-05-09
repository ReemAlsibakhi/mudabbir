import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/ui/widgets/mud_gradient_button.dart';
import '../../../onboarding/domain/entities/onboarding_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_notifier.dart';
import '../../domain/entities/goal.dart';
import '../../domain/usecases/add_goal_usecase.dart';
import '../providers/goals_notifier.dart';
import 'wedding_budget_sheet.dart';

class AddGoalSheet extends StatefulWidget {
  final WidgetRef ref;
  const AddGoalSheet({super.key, required this.ref});

  static Future<void> show(BuildContext context, WidgetRef ref) =>
      showModalBottomSheet(
        context:            context,
        isScrollControlled: true,
        builder:            (_) => AddGoalSheet(ref: ref),
      );

  @override
  State<AddGoalSheet> createState() => _State();
}

class _State extends State<AddGoalSheet> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _targetCtrl  = TextEditingController();
  final _savedCtrl   = TextEditingController();
  final _monthlyCtrl = TextEditingController();

  GoalType      _type     = GoalType.home;
  GoalInputMode _mode     = GoalInputMode.byDuration;
  int           _duration = 24;
  bool          _loading  = false;
  String?       _error;

  // ✅ Wedding date — for engaged scenario
  DateTime? _weddingDate;

  // ── Goal types ordered by life stage ───────────────────
  List<GoalType> _goalsForStage(LifeStage stage) => switch (stage) {
    LifeStage.single => [
      GoalType.home, GoalType.car, GoalType.travel,
      GoalType.emergency, GoalType.business, GoalType.education,
      GoalType.hajj, GoalType.gold, GoalType.wedding, GoalType.other,
    ],
    LifeStage.engaged => [
      GoalType.wedding, GoalType.home, GoalType.car,
      GoalType.travel, GoalType.emergency, GoalType.business,
      GoalType.hajj, GoalType.gold, GoalType.other,
    ],
    LifeStage.married => [
      GoalType.home, GoalType.car, GoalType.emergency,
      GoalType.travel, GoalType.education, GoalType.business,
      GoalType.hajj, GoalType.gold, GoalType.other,
    ],
    LifeStage.family => [
      GoalType.emergency, GoalType.education, GoalType.home,
      GoalType.car, GoalType.hajj, GoalType.travel,
      GoalType.business, GoalType.gold, GoalType.other,
    ],
  };

  String _headline(LifeStage stage) => switch (stage) {
    LifeStage.single  => AppStrings.goalSingle,
    LifeStage.engaged => AppStrings.goalEngaged,
    LifeStage.married => AppStrings.goalMarried,
    LifeStage.family  => AppStrings.goalFamily,
  };

  double get _target    => double.tryParse(_targetCtrl.text.replaceAll(',','')) ?? 0;
  double get _saved     => double.tryParse(_savedCtrl.text.replaceAll(',','')) ?? 0;
  double get _remaining => (_target - _saved).clamp(0, double.infinity);
  double get _calcMonthly => _duration > 0 && _remaining > 0
      ? _remaining / _duration : 0;
  int get _calcMonths {
    final mo = double.tryParse(_monthlyCtrl.text.replaceAll(',','')) ?? 0;
    return mo > 0 && _remaining > 0 ? (_remaining / mo).ceil() : 0;
  }

  // ── Months from wedding date ────────────────────────────
  int get _monthsFromDate {
    if (_weddingDate == null) return 0;
    final now = DateTime.now();
    return (_weddingDate!.year - now.year) * 12 +
           (_weddingDate!.month - now.month);
  }

  // ── Is user behind? ────────────────────────────────────
  bool get _isBehind {
    if (_target <= 0 || _duration <= 0 || _saved <= 0) return false;
    // How much should have been saved by now?
    final totalDuration = _mode == GoalInputMode.byDuration
        ? _duration : (_calcMonths > 0 ? _calcMonths : _duration);
    if (totalDuration <= 0) return false;
    final elapsed    = (totalDuration - _duration).clamp(0, totalDuration);
    final idealSaved = elapsed * (_target / totalDuration);
    return _saved < (idealSaved * 0.9); // 10% tolerance
  }

  double get _behindPct {
    if (_target <= 0 || _saved <= 0) return 0;
    return ((1 - (_saved / _target)) * 100).clamp(0, 100);
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _targetCtrl.dispose();
    _savedCtrl.dispose(); _monthlyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile   = widget.ref.watch(onboardingRepoProvider).getSaved();
    final stage     = profile?.lifeStage ?? LifeStage.single;
    final goalTypes = _goalsForStage(stage);
    final isEngaged = stage == LifeStage.engaged;
    final isWedding = _type == GoalType.wedding;

    if (!goalTypes.contains(_type)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _type = goalTypes.first);
      });
    }

    return Padding(
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
              Center(child: Text(_headline(stage), style: AppTextStyles.title)),
              const SizedBox(height: 16),

              // ── Goal type chips ──────────────────────────
              Wrap(
                spacing: 7, runSpacing: 7,
                children: goalTypes.map((t) {
                  final sel = _type == t;
                  return GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.accent.withOpacity(0.12)
                            : AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel ? AppColors.accent : AppColors.border,
                          width: sel ? 1.5 : 1),
                      ),
                      child: Text('${t.icon} ${t.nameAr}',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: sel ? AppColors.accentAlt : AppColors.textSecondary)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // ✅ WEDDING DATE PICKER — للمخطوب فقط ─────────
              if (isEngaged && isWedding) ...[
                _WeddingDatePicker(
                  selected:  _weddingDate,
                  onPicked:  (d) => setState(() {
                    _weddingDate = d;
                    _duration    = _monthsFromDate.clamp(1, 600);
                    _mode        = GoalInputMode.byDuration;
                  }),
                ),
                if (_weddingDate != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentAlt.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      '${_monthsFromDate} ${AppStrings.weddingMonthsLeft}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyBold.copyWith(
                        color: AppColors.accentAlt),
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // ✅ WEDDING BUDGET BREAKDOWN BUTTON ──────────
                GestureDetector(
                  onTap: () async {
                    final total = await showModalBottomSheet<double>(
                      context:            context,
                      isScrollControlled: true,
                      builder: (_) => WeddingBudgetSheet(
                        monthsLeft:    _monthsFromDate.clamp(1, 600),
                        alreadySaved:  _saved,
                        onTotalChanged: (t) {
                          _targetCtrl.text = t.toStringAsFixed(0);
                          setState(() {});
                        },
                      ),
                    );
                    if (total != null && total > 0) {
                      setState(() => _targetCtrl.text = total.toStringAsFixed(0));
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: AppColors.accentAlt.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('💍', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(AppStrings.weddingBudgetTitle,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.accentAlt,
                            fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios_rounded,
                          size: 12, color: AppColors.accentAlt),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Name ────────────────────────────────────
              TextFormField(
                controller:    _nameCtrl,
                textDirection: TextDirection.rtl,
                validator:     Validators.name,
                decoration: InputDecoration(
                  labelText: AppStrings.goalNameLabel,
                  hintText:  _hintForType(_type, stage),
                ),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              // ── Target ──────────────────────────────────
              TextFormField(
                controller:   _targetCtrl,
                textDirection: TextDirection.rtl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator:    Validators.amount,
                onChanged:    (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: AppStrings.goalTargetLabel,
                  hintText:  '0'),
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              // ── Already saved ───────────────────────────
              TextFormField(
                controller:   _savedCtrl,
                textDirection: TextDirection.rtl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged:    (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: AppStrings.goalSavedLabel,
                  hintText:  '0'),
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 14),

              // ── Mode toggle (hidden if wedding date selected) ─
              if (!(isEngaged && isWedding && _weddingDate != null)) ...[
                _ModeToggle(mode: _mode,
                  onChange: (m) => setState(() => _mode = m)),
                const SizedBox(height: 12),
              ],

              if (_mode == GoalInputMode.byDuration) ...[
                if (!(isEngaged && isWedding && _weddingDate != null))
                  DropdownButtonFormField<int>(
                    value: _duration,
                    dropdownColor: AppColors.surface2,
                    onChanged: (v) => setState(() => _duration = v ?? 24),
                    decoration: const InputDecoration(
                      labelText: AppStrings.goalDurationLabel),
                    items: [6,12,18,24,36,48,60,84,120,180]
                        .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(_monthLabel(m),
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textPrimary))))
                        .toList(),
                  ),
                if (_calcMonthly > 0) ...[
                  const SizedBox(height: 10),
                  _Insight(
                    '${AppStrings.goalNeedMonthlyPre}'
                    '${_calcMonthly.toStringAsFixed(0)} '
                    '${AppStrings.monthly} '
                    '${AppStrings.goalNeedMonthlySuf} '
                    '$_duration '
                    '${AppStrings.goalNeedMonthlySuf2}'),
                ],
              ] else ...[
                TextFormField(
                  controller:   _monthlyCtrl,
                  textDirection: TextDirection.rtl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged:    (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: AppStrings.goalMonthlyLabel,
                    hintText:  '0'),
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                ),
                if (_calcMonths > 0) ...[
                  const SizedBox(height: 10),
                  _Insight(
                    '${AppStrings.goalReachPre}'
                    '$_calcMonths'
                    '${AppStrings.goalReachMid}'
                    '${(_calcMonths / 12).toStringAsFixed(1)}'
                    '${AppStrings.goalReachSuf}'),
                ],
              ],

              // ✅ BEHIND ALERT ──────────────────────────────
              if (_isBehind && _saved > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.2)),
                  ),
                  child: Text(
                    '${AppStrings.weddingBehindPre}'
                    '${_behindPct.toStringAsFixed(0)}'
                    '${AppStrings.weddingBehindSuf}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: AppTextStyles.caption.copyWith(
                  color: AppColors.error)),
              ],
              const SizedBox(height: 16),

              MudGradientButton(
                label:   AppStrings.addGoalTitle,
                onTap:   _submit,
                loading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _hintForType(GoalType t, LifeStage stage) => switch (t) {
    GoalType.home      => stage == LifeStage.family
        ? AppStrings.hintHomeFamily : AppStrings.hintHomeSingle,
    GoalType.wedding   => stage == LifeStage.engaged
        ? AppStrings.hintWeddingFull : AppStrings.hintWeddingSmall,
    GoalType.education => stage == LifeStage.family
        ? AppStrings.hintEduFamily : AppStrings.hintEduSelf,
    GoalType.emergency => stage == LifeStage.family
        ? AppStrings.hintEmgFamily : AppStrings.hintEmgSingle,
    GoalType.car       => AppStrings.hintCar,
    GoalType.travel    => AppStrings.hintTravel,
    GoalType.hajj      => AppStrings.hintHajj,
    GoalType.business  => AppStrings.hintBusiness,
    GoalType.gold      => AppStrings.hintGold,
    GoalType.other     => AppStrings.hintOther,
  };

  String _monthLabel(int m) {
    if (m < 12)   return '$m ${AppStrings.monthsAr}';
    if (m == 12)  return AppStrings.yearLabel;
    if (m == 24)  return AppStrings.twoYearsLabel;
    if (m % 12 == 0) return '${m ~/ 12} ${AppStrings.years}';
    return '$m ${AppStrings.monthSuffix}';
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    final err = await widget.ref
        .read(goalsNotifierProvider.notifier)
        .addGoal(AddGoalParams(
          type:             _type,
          name:             _nameCtrl.text,
          targetRaw:        _targetCtrl.text,
          savedRaw:         _savedCtrl.text,
          mode:             _mode,
          durationMonths:   _mode == GoalInputMode.byDuration
              ? _duration : null,
          monthlyAmountRaw: _mode == GoalInputMode.byMonthlyAmount
              ? _monthlyCtrl.text : null,
        ));

    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      setState(() => _error = err);
    } else {
      context.popScreen();
      context.showSnack(AppStrings.goalAdded, color: AppColors.success);
    }
  }
}

// ── Wedding Date Picker ──────────────────────────────────────
class _WeddingDatePicker extends StatelessWidget {
  final DateTime?             selected;
  final ValueChanged<DateTime> onPicked;
  const _WeddingDatePicker({required this.selected, required this.onPicked});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () async {
      final now  = DateTime.now();
      final picked = await showDatePicker(
        context:     context,
        initialDate: selected ?? DateTime(now.year + 1, now.month),
        firstDate:   now,
        lastDate:    DateTime(now.year + 10),
        helpText:    AppStrings.weddingDateLabel,
        locale:      const Locale('ar', 'SA'),
        builder:     (ctx, child) => Theme(
          data: Theme.of(ctx),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!),
        ),
      );
      if (picked != null) onPicked(picked);
    },
    child: Container(
      width:   double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color:        AppColors.surface2,
        borderRadius: BorderRadius.circular(11),
        border:       Border.all(
          color: selected != null
              ? AppColors.accentAlt
              : AppColors.border,
          width: selected != null ? 1.5 : 1),
      ),
      child: Row(
        children: [
          const Text('📅', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              selected == null
                  ? AppStrings.weddingDateHint
                  : '${selected!.day}/${selected!.month}/${selected!.year}',
              style: AppTextStyles.body.copyWith(
                color: selected != null
                    ? AppColors.accentAlt : AppColors.textTertiary),
            ),
          ),
          Icon(
            selected != null
                ? Icons.edit_calendar_rounded
                : Icons.calendar_today_rounded,
            size:  16,
            color: AppColors.textTertiary),
        ],
      ),
    ),
  );
}

// ── Mode Toggle ──────────────────────────────────────────────
class _ModeToggle extends StatelessWidget {
  final GoalInputMode mode;
  final ValueChanged<GoalInputMode> onChange;
  const _ModeToggle({required this.mode, required this.onChange});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color:        AppColors.surface2,
      borderRadius: BorderRadius.circular(10)),
    child: Row(
      children: GoalInputMode.values.map((m) {
        final active = mode == m;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChange(m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: active ? AppColors.surface3 : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                m == GoalInputMode.byDuration
                    ? AppStrings.goalChooseDur
                    : AppStrings.goalChooseMon,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: active ? AppColors.accentAlt : AppColors.textTertiary)),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

// ── Insight box ──────────────────────────────────────────────
class _Insight extends StatelessWidget {
  final String text;
  const _Insight(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color:        AppColors.accent.withOpacity(0.07),
      borderRadius: BorderRadius.circular(10),
      border:       Border.all(color: AppColors.accent.withOpacity(0.14)),
    ),
    child: Text('💡 $text',
      style: AppTextStyles.caption.copyWith(
        color: AppColors.accentAlt.withOpacity(0.85))),
  );
}
