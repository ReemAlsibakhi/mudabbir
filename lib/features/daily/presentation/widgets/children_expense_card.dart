import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_card.dart';
import '../../../onboarding/domain/entities/onboarding_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_notifier.dart';

// ══════════════════════════════════════════════════════════
// ChildrenExpenseCard — تتبع مصاريف كل طفل منفصل
// يظهر للأسرة فقط
// البيانات تُحفظ في Hive
// ══════════════════════════════════════════════════════════

class ChildData {
  String name;
  double monthlyAllowance;
  double schoolFees;
  double medicalBudget;

  ChildData({
    required this.name,
    this.monthlyAllowance = 0,
    this.schoolFees       = 0,
    this.medicalBudget    = 0,
  });

  double get total => monthlyAllowance + schoolFees + medicalBudget;

  Map<String, dynamic> toJson() => {
    'name': name, 'allowance': monthlyAllowance,
    'school': schoolFees, 'medical': medicalBudget,
  };

  factory ChildData.fromJson(Map<String, dynamic> j) => ChildData(
    name:             j['name'] as String,
    monthlyAllowance: (j['allowance'] as num?)?.toDouble() ?? 0,
    schoolFees:       (j['school']   as num?)?.toDouble() ?? 0,
    medicalBudget:    (j['medical']  as num?)?.toDouble() ?? 0,
  );
}

class ChildrenExpenseCard extends ConsumerStatefulWidget {
  const ChildrenExpenseCard({super.key});

  @override
  ConsumerState<ChildrenExpenseCard> createState() => _State();
}

class _State extends ConsumerState<ChildrenExpenseCard> {
  List<ChildData> _children = [];
  int? _editing;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final box  = Hive.box(AppConstants.settingsBox);
    final raw  = box.get('children_data') as List?;
    if (raw != null) {
      _children = raw
          .map((e) => ChildData.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
  }

  Future<void> _save() async {
    final box = Hive.box(AppConstants.settingsBox);
    await box.put('children_data', _children.map((c) => c.toJson()).toList());
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(onboardingRepoProvider).getSaved();
    if (profile?.lifeStage != LifeStage.family) return const SizedBox.shrink();

    final totalChildren = _children.fold(0.0, (s, c) => s + c.total);

    return MudCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Text('👨‍👩‍👧‍👦', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(AppStrings.childrenTitle, style: AppTextStyles.bodyBold),
              ]),
              GestureDetector(
                onTap: _addChild,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    const Icon(Icons.add_rounded, size: 14, color: AppColors.accentAlt),
                    const SizedBox(width: 4),
                    Text(AppStrings.addChild,
                      style: AppTextStyles.caption.copyWith(color: AppColors.accentAlt)),
                  ]),
                ),
              ),
            ],
          ),

          if (_children.isEmpty) ...[
            const SizedBox(height: 14),
            Center(
              child: Text(AppStrings.noChildrenYet,
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
            ),
            const SizedBox(height: 8),
          ] else ...[
            const SizedBox(height: 12),
            ..._children.asMap().entries.map((e) => _ChildRow(
              data:      e.value,
              isEditing: _editing == e.key,
              onEdit:    () => setState(() => _editing = e.key),
              onClose:   () { setState(() => _editing = null); _save(); },
              onDelete:  () {
                setState(() {
                  _children.removeAt(e.key);
                  _editing = null;
                });
                _save();
              },
              onChanged: () => setState(() {}),
            )),
            const Divider(color: AppColors.border),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.childrenTotalMonthly,
                  style: AppTextStyles.body.copyWith(fontSize: 13)),
                Text(totalChildren.fmt(),
                  style: AppTextStyles.headline2.copyWith(
                    color:    AppColors.error, fontSize: 16)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _addChild() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _AddChildDialog(),
    );
    if (name != null && name.trim().isNotEmpty) {
      setState(() => _children.add(ChildData(name: name.trim())));
      await _save();
    }
  }
}

// ── Child row ──────────────────────────────────────────────
class _ChildRow extends StatefulWidget {
  final ChildData  data;
  final bool       isEditing;
  final VoidCallback onEdit, onClose, onDelete;
  final VoidCallback onChanged;
  const _ChildRow({
    required this.data,      required this.isEditing,
    required this.onEdit,    required this.onClose,
    required this.onDelete,  required this.onChanged,
  });
  @override State<_ChildRow> createState() => _ChildRowState();
}

class _ChildRowState extends State<_ChildRow> {
  late final TextEditingController _allowCtrl, _schoolCtrl, _medCtrl;

  @override
  void initState() {
    super.initState();
    _allowCtrl  = TextEditingController(
      text: widget.data.monthlyAllowance > 0
          ? widget.data.monthlyAllowance.toStringAsFixed(0) : '');
    _schoolCtrl = TextEditingController(
      text: widget.data.schoolFees > 0
          ? widget.data.schoolFees.toStringAsFixed(0) : '');
    _medCtrl    = TextEditingController(
      text: widget.data.medicalBudget > 0
          ? widget.data.medicalBudget.toStringAsFixed(0) : '');
  }

  @override
  void dispose() { _allowCtrl.dispose(); _schoolCtrl.dispose(); _medCtrl.dispose(); super.dispose(); }

  void _update() {
    widget.data.monthlyAllowance = double.tryParse(_allowCtrl.text)  ?? 0;
    widget.data.schoolFees       = double.tryParse(_schoolCtrl.text) ?? 0;
    widget.data.medicalBudget    = double.tryParse(_medCtrl.text)    ?? 0;
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      // Header row
      GestureDetector(
        onTap: widget.isEditing ? widget.onClose : widget.onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Text('👦', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(child: Text(widget.data.name,
                style: AppTextStyles.bodyBold)),
              Text(widget.data.total.fmt(),
                style: AppTextStyles.bodyBold.copyWith(color: AppColors.accentAlt)),
              const SizedBox(width: 8),
              Icon(
                widget.isEditing
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 18, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),

      // Expandable detail
      AnimatedCrossFade(
        duration: const Duration(milliseconds: 220),
        crossFadeState: widget.isEditing
            ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstChild:  const SizedBox.shrink(),
        secondChild: Column(
          children: [
            _Field('💰 ${AppStrings.childAllowance}', _allowCtrl),
            _Field('🎒 ${AppStrings.childSchool}',    _schoolCtrl),
            _Field('🏥 ${AppStrings.childMedical}',   _medCtrl),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onDelete,
                  child: Text(AppStrings.delete,
                    style: AppTextStyles.caption.copyWith(color: AppColors.error))),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () { _update(); widget.onClose(); },
                  child: Text(AppStrings.save,
                    style: AppTextStyles.caption.copyWith(color: AppColors.accentAlt))),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  const _Field(this.label, this.ctrl);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        SizedBox(width: 140,
          child: Text(label, style: AppTextStyles.caption)),
        Expanded(
          child: TextField(
            controller:   ctrl,
            textDirection: TextDirection.rtl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
            style: AppTextStyles.body.copyWith(fontSize: 13),
            decoration: const InputDecoration(
              hintText:       '0',
              isDense:        true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Add child dialog ───────────────────────────────────────
class _AddChildDialog extends StatefulWidget {
  @override State<_AddChildDialog> createState() => _AddChildDialogState();
}
class _AddChildDialogState extends State<_AddChildDialog> {
  final _ctrl = TextEditingController();
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.surface2,
    title: Text(AppStrings.addChildTitle, style: AppTextStyles.title),
    content: TextField(
      controller:    _ctrl,
      textDirection: TextDirection.rtl,
      autofocus:     true,
      decoration:    InputDecoration(hintText: AppStrings.childNameHint),
      style:         AppTextStyles.body.copyWith(color: AppColors.textPrimary),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(AppStrings.cancel,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary))),
      TextButton(
        onPressed: () => Navigator.pop(context, _ctrl.text),
        child: Text(AppStrings.add,
          style: AppTextStyles.body.copyWith(color: AppColors.accentAlt))),
    ],
  );
}
