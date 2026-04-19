import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/categories.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/providers/expense_provider.dart';
import '../../../data/providers/income_provider.dart';
import '../../../shared/widgets/mud_card.dart';

final _expTabProvider = StateProvider<int>((ref) => 0);

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(_expTabProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              color: AppColors.surface1,
              child: Column(
                children: [
                  const Text('💸 المصروف',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Row(
                      children: [
                        _TabBtn(label: '📅 ثابت شهري', index: 0, selected: tab),
                        _TabBtn(label: '📆 متغير يومي', index: 1, selected: tab),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            // Content
            Expanded(
              child: tab == 0 ? const _FixedTab() : const _DailyTab(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBtn extends ConsumerWidget {
  final String label;
  final int index, selected;
  const _TabBtn({required this.label, required this.index, required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = index == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(_expTabProvider.notifier).state = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface3 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(label,
              style: TextStyle(
                fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600,
                color: isActive ? AppColors.accent2 : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Fixed Tab ─────────────────────────────────────
class _FixedTab extends ConsumerStatefulWidget {
  const _FixedTab();
  @override
  ConsumerState<_FixedTab> createState() => _FixedTabState();
}

class _FixedTabState extends ConsumerState<_FixedTab> {
  final _nameCtrl = TextEditingController();
  final _amtCtrl  = TextEditingController();
  String _cat = 'rent';

  @override
  void dispose() { _nameCtrl.dispose(); _amtCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final fixed = ref.watch(fixedExpensesProvider);
    final total = fixed.fold(0.0, (s, e) => s + e.amount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MudCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MudSectionTitle('➕ إضافة مصروف ثابت'),
              DropdownButtonFormField<String>(
                value: _cat,
                dropdownColor: AppColors.surface2,
                decoration: const InputDecoration(labelText: 'النوع'),
                items: fixedCategories.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text('${c.icon} ${c.nameAr}',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                )).toList(),
                onChanged: (v) => setState(() => _cat = v ?? 'rent'),
              ),
              const SizedBox(height: 12),
              TextField(controller: _nameCtrl, textDirection: TextDirection.rtl,
                decoration: const InputDecoration(labelText: 'الاسم', hintText: 'مثال: إيجار الشقة'),
                style: const TextStyle(fontFamily: 'Cairo')),
              const SizedBox(height: 12),
              TextField(controller: _amtCtrl, keyboardType: TextInputType.number,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(labelText: 'المبلغ الشهري', hintText: '0'),
                style: const TextStyle(fontFamily: 'Cairo')),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _addFixed,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Center(
                    child: Text('➕ إضافة — يُضاف تلقائياً كل شهر',
                      style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700,
                        color: Colors.white, fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
        MudCard(
          child: fixed.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('لا توجد مصاريف ثابتة',
                      style: TextStyle(fontFamily: 'Cairo', color: AppColors.textTertiary)),
                  ),
                )
              : Column(
                  children: [
                    ...fixed.map((e) {
                      final cat = getCategoryById(e.categoryId);
                      return _ExpRow(
                        icon: cat.icon, name: e.name, sub: 'ثابت شهري',
                        amount: e.amount, color: Color(cat.color),
                        onDelete: () => ref.read(expenseActionsProvider).deleteFixedExpense(e.id),
                      );
                    }),
                    const Divider(color: AppColors.border, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المجموع الثابت',
                          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                        Text('${total.toStringAsFixed(0)} ريال',
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 18,
                            fontWeight: FontWeight.w900, color: AppColors.red)),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _addFixed() async {
    final amt = double.tryParse(_amtCtrl.text);
    if (_nameCtrl.text.isEmpty || amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل الاسم والمبلغ', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating),
      );
      return;
    }
    await ref.read(expenseActionsProvider).addFixedExpense(
      categoryId: _cat, name: _nameCtrl.text, amount: amt,
    );
    _nameCtrl.clear(); _amtCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تمت الإضافة — سيظهر كل شهر تلقائياً',
        style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.green, behavior: SnackBarBehavior.floating),
    );
  }
}

// ─── Daily Tab ─────────────────────────────────────
class _DailyTab extends ConsumerStatefulWidget {
  const _DailyTab();
  @override
  ConsumerState<_DailyTab> createState() => _DailyTabState();
}

class _DailyTabState extends ConsumerState<_DailyTab> {
  final _nameCtrl = TextEditingController();
  final _amtCtrl  = TextEditingController();
  String _cat = 'food';
  DateTime _date = DateTime.now();

  @override
  void dispose() { _nameCtrl.dispose(); _amtCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final month    = ref.watch(currentMonthProvider);
    final expenses = ref.watch(expensesProvider(month));
    final total    = expenses.fold(0.0, (s, e) => s + e.amount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MudCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MudSectionTitle('➕ إضافة مصروف'),
              DropdownButtonFormField<String>(
                value: _cat,
                dropdownColor: AppColors.surface2,
                decoration: const InputDecoration(labelText: 'الفئة'),
                items: variableCategories.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text('${c.icon} ${c.nameAr}',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                )).toList(),
                onChanged: (v) => setState(() => _cat = v ?? 'food'),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Text('📅 '),
                      Text(MudabbirDateUtils.formatDayAr(_date),
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
                          color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(controller: _amtCtrl, keyboardType: TextInputType.number,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(labelText: 'المبلغ', hintText: '0'),
                style: const TextStyle(fontFamily: 'Cairo')),
              const SizedBox(height: 12),
              TextField(controller: _nameCtrl, textDirection: TextDirection.rtl,
                decoration: const InputDecoration(labelText: 'الوصف (اختياري)',
                  hintText: 'مثال: بقالة الأسبوع'),
                style: const TextStyle(fontFamily: 'Cairo')),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _addDaily,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Center(
                    child: Text('➕ إضافة',
                      style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700,
                        color: Colors.white, fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Expense List
        MudCard(
          child: expenses.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('لا توجد مصاريف هذا الشهر',
                      style: TextStyle(fontFamily: 'Cairo', color: AppColors.textTertiary)),
                  ),
                )
              : Column(
                  children: [
                    ...expenses.map((e) {
                      final cat = getCategoryById(e.categoryId);
                      return _ExpRow(
                        icon: cat.icon, name: e.name, sub: '${cat.nameAr} · ${e.date}',
                        amount: e.amount, color: Color(cat.color),
                        onDelete: () => ref.read(expenseActionsProvider).deleteExpense(e.id),
                      );
                    }),
                    const Divider(color: AppColors.border, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المجموع',
                          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                        Text('${total.toStringAsFixed(0)} ريال',
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 18,
                            fontWeight: FontWeight.w900, color: AppColors.red)),
                      ],
                    ),
                  ],
                ),
        ),
      ],
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

  Future<void> _addDaily() async {
    final amt = double.tryParse(_amtCtrl.text);
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ أدخل مبلغاً صحيحاً', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating),
      );
      return;
    }
    final cat = getCategoryById(_cat);
    await ref.read(expenseActionsProvider).addExpense(
      categoryId: _cat,
      name: _nameCtrl.text.isNotEmpty ? _nameCtrl.text : cat.nameAr,
      amount: amt, date: _date,
    );
    _amtCtrl.clear(); _nameCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ تمت الإضافة — ${cat.nameAr}',
        style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.green, behavior: SnackBarBehavior.floating),
    );
  }
}

class _ExpRow extends StatelessWidget {
  final String icon, name, sub;
  final double amount;
  final Color color;
  final VoidCallback onDelete;

  const _ExpRow({
    required this.icon, required this.name, required this.sub,
    required this.amount, required this.color, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
                  fontWeight: FontWeight.w600)),
                Text(sub, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11,
                  color: AppColors.textTertiary)),
              ],
            ),
          ),
          Text('${amount.toStringAsFixed(0)} ريال',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
              fontWeight: FontWeight.w800, color: color)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.close, size: 14, color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}
