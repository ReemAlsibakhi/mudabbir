import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/providers/income_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../shared/widgets/mud_card.dart';
import '../../../shared/widgets/main_scaffold.dart';

class IncomeScreen extends ConsumerStatefulWidget {
  const IncomeScreen({super.key});
  @override
  ConsumerState<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends ConsumerState<IncomeScreen> {
  final _primaryCtrl   = TextEditingController();
  final _secondaryCtrl = TextEditingController();
  final _extraCtrl     = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIncome());
  }

  void _loadIncome() {
    final month = ref.read(currentMonthProvider);
    final income = ref.read(incomeProvider(month));
    if (income != null) {
      _primaryCtrl.text   = income.primary   > 0 ? income.primary.toStringAsFixed(0)   : '';
      _secondaryCtrl.text = income.secondary > 0 ? income.secondary.toStringAsFixed(0) : '';
      _extraCtrl.text     = income.extra     > 0 ? income.extra.toStringAsFixed(0)     : '';
    }
  }

  @override
  void dispose() {
    _primaryCtrl.dispose(); _secondaryCtrl.dispose(); _extraCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final month     = ref.watch(currentMonthProvider);
    final income    = ref.watch(incomeProvider(month));
    final userAsync = ref.watch(userProvider);
    final stage     = userAsync.valueOrNull?.lifeStage ?? 'single';
    final currency  = 'ريال';
    final total     = income?.total ?? 0;

    final label1 = (stage == 'single' || stage == 'engaged') ? 'راتبك الشهري' : 'دخل الزوج';
    final showPartner = stage == 'married' || stage == 'family';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.surface1,
              title: Column(
                children: [
                  const Text('💰 الدخل الشهري',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w700)),
                  Text(MudabbirDateUtils.formatMonthAr(month),
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 12,
                      color: AppColors.textSecondary)),
                ],
              ),
              actions: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onPressed: () {
                        final m = ref.read(currentMonthProvider);
                        if (m.month == 1) {
                          ref.read(currentMonthProvider.notifier).state =
                              DateTime(m.year - 1, 12);
                        } else {
                          ref.read(currentMonthProvider.notifier).state =
                              DateTime(m.year, m.month - 1);
                        }
                        _loadIncome();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
                      onPressed: () {
                        final m = ref.read(currentMonthProvider);
                        final now = DateTime.now();
                        if (m.year > now.year || (m.year == now.year && m.month >= now.month)) return;
                        if (m.month == 12) {
                          ref.read(currentMonthProvider.notifier).state = DateTime(m.year + 1, 1);
                        } else {
                          ref.read(currentMonthProvider.notifier).state = DateTime(m.year, m.month + 1);
                        }
                        _loadIncome();
                      },
                    ),
                  ],
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Input Card
                  MudCard(
                    child: Column(
                      children: [
                        _IncomeField(
                          label: '👨 $label1',
                          controller: _primaryCtrl,
                          hint: '0',
                          onChanged: (_) => _save(),
                        ),
                        if (showPartner) ...[
                          const SizedBox(height: 12),
                          _IncomeField(
                            label: '👩 دخل الزوجة',
                            controller: _secondaryCtrl,
                            hint: '0',
                            onChanged: (_) => _save(),
                          ),
                        ],
                        const SizedBox(height: 12),
                        _IncomeField(
                          label: '💼 دخل إضافي (مكافآت، إيجارات...)',
                          controller: _extraCtrl,
                          hint: '0',
                          onChanged: (_) => _save(),
                        ),
                      ],
                    ),
                  ),

                  // Summary Card
                  MudCard(
                    child: Column(
                      children: [
                        _SummaryRow(label: '👨 $label1',
                          value: _fmt(_primaryCtrl.text), currency: currency),
                        if (showPartner)
                          _SummaryRow(label: '👩 دخل الزوجة',
                            value: _fmt(_secondaryCtrl.text), currency: currency),
                        _SummaryRow(label: '💼 دخل إضافي',
                          value: _fmt(_extraCtrl.text), currency: currency),
                        const Divider(color: AppColors.border, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('إجمالي الدخل',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 15,
                                fontWeight: FontWeight.w700)),
                            Text('${total.toStringAsFixed(0)} $currency',
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 22,
                                fontWeight: FontWeight.w900, color: AppColors.accent2)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Savings Insight
                  if (total > 0)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: AppColors.green.withOpacity(0.15)),
                      ),
                      child: Text(
                        '💡 لو وفّرت 20% من دخلك = '
                        '${(total * 0.2).toStringAsFixed(0)} $currency شهرياً\n'
                        '= ${(total * 0.2 * 12).toStringAsFixed(0)} $currency سنوياً!',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
                          color: AppColors.textSecondary, height: 1.8),
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(String val) {
    final n = double.tryParse(val);
    return n != null && n > 0 ? n.toStringAsFixed(0) : '—';
  }

  Future<void> _save() async {
    final month     = ref.read(currentMonthProvider);
    final primary   = double.tryParse(_primaryCtrl.text) ?? 0;
    final secondary = double.tryParse(_secondaryCtrl.text) ?? 0;
    final extra     = double.tryParse(_extraCtrl.text) ?? 0;
    await ref.read(incomeActionsProvider).saveIncome(
      month: month, primary: primary, secondary: secondary, extra: extra,
    );
  }
}

class _IncomeField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _IncomeField({
    required this.label, required this.hint,
    required this.controller, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12,
          color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.rtl,
          onChanged: onChanged,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value, currency;
  const _SummaryRow({required this.label, required this.value, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
            color: AppColors.textSecondary)),
          Text(value == '—' ? value : '$value $currency',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 14,
              fontWeight: FontWeight.w700,
              color: value == '—' ? AppColors.textTertiary : AppColors.accent2)),
        ],
      ),
    );
  }
}
