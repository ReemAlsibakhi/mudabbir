import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/categories.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/providers/expense_provider.dart';
import '../../../data/providers/user_provider.dart';

// Voice state provider
final _voiceStateProvider = StateProvider<_VoiceState>((ref) => _VoiceState.idle);
final _voiceResultProvider = StateProvider<_VoiceResult?>((ref) => null);
final _isListeningProvider = StateProvider<bool>((ref) => false);

enum _VoiceState { idle, listening, result }

class _VoiceResult {
  final String text;
  final double? amount;
  final String categoryId;

  const _VoiceResult({required this.text, this.amount, required this.categoryId});
}

class VoiceInputWidget extends ConsumerWidget {
  const VoiceInputWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(_voiceStateProvider);
    final voiceResult = ref.watch(_voiceResultProvider);

    return Column(
      children: [
        // Voice Button
        GestureDetector(
          onTap: () => _handleVoiceTap(context, ref),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: voiceState == _VoiceState.listening
                  ? AppColors.red.withOpacity(0.12)
                  : AppColors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: voiceState == _VoiceState.listening
                    ? AppColors.red.withOpacity(0.4)
                    : AppColors.purple.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _VoiceIcon(isListening: voiceState == _VoiceState.listening),
                const SizedBox(width: 10),
                Text(
                  voiceState == _VoiceState.listening
                      ? 'جارٍ الاستماع... تكلم الآن'
                      : 'قول اللي صرفته — "صرفت 50 ريال على البنزين"',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: voiceState == _VoiceState.listening
                        ? AppColors.red
                        : AppColors.purple,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Voice Result
        if (voiceResult != null && voiceState == _VoiceState.result)
          _VoiceResultCard(result: voiceResult),
      ],
    );
  }

  void _handleVoiceTap(BuildContext context, WidgetRef ref) {
    final state = ref.read(_voiceStateProvider);
    if (state == _VoiceState.listening) {
      ref.read(_voiceStateProvider.notifier).state = _VoiceState.idle;
      return;
    }

    // Check speech availability
    _startVoiceInput(context, ref);
  }

  Future<void> _startVoiceInput(BuildContext context, WidgetRef ref) async {
    ref.read(_voiceStateProvider.notifier).state = _VoiceState.listening;

    // Simulate voice — in real app uses speech_to_text package
    await Future.delayed(const Duration(seconds: 2));

    // For now show manual input dialog
    if (context.mounted) {
      ref.read(_voiceStateProvider.notifier).state = _VoiceState.idle;
      _showManualDialog(context, ref);
    }
  }

  void _showManualDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ManualInputSheet(),
    );
  }
}

class _VoiceIcon extends StatefulWidget {
  final bool isListening;
  const _VoiceIcon({required this.isListening});

  @override
  State<_VoiceIcon> createState() => _VoiceIconState();
}

class _VoiceIconState extends State<_VoiceIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!widget.isListening) {
      return const Text('🎤', style: TextStyle(fontSize: 20));
    }
    return ScaleTransition(
      scale: _anim,
      child: const Text('🔴', style: TextStyle(fontSize: 20)),
    );
  }
}

class _VoiceResultCard extends ConsumerWidget {
  final _VoiceResult result;
  const _VoiceResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = getCategoryById(result.categoryId);
    final userAsync = ref.watch(userProvider);
    final currency = userAsync.valueOrNull == null ? 'ريال' : 'ريال';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🎤 سمعنا: ${result.text}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo')),
          const SizedBox(height: 8),
          if (result.amount != null)
            Text('💰 المبلغ: ${result.amount} $currency',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: AppColors.accent2, fontFamily: 'Cairo')),
          Text('📂 الفئة: ${cat.icon} ${cat.nameAr}',
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontFamily: 'Cairo')),
          const SizedBox(height: 10),
          if (result.amount != null)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _confirm(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('✅ تأكيد الإضافة',
                          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700,
                            color: Colors.white, fontSize: 13)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => ref.read(_voiceResultProvider.notifier).state = null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface3,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('إلغاء',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    if (result.amount == null) return;
    await ref.read(expenseActionsProvider).addExpense(
      categoryId: result.categoryId,
      name: getCategoryById(result.categoryId).nameAr,
      amount: result.amount!,
      date: DateTime.now(),
    );
    await ref.read(userActionsProvider).updateStreak();
    ref.read(_voiceResultProvider.notifier).state = null;
    ref.read(_voiceStateProvider.notifier).state = _VoiceState.idle;
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم تسجيل ${result.amount} ريال',
            style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// Manual input bottom sheet
class _ManualInputSheet extends ConsumerStatefulWidget {
  const _ManualInputSheet();

  @override
  ConsumerState<_ManualInputSheet> createState() => _ManualInputSheetState();
}

class _ManualInputSheetState extends ConsumerState<_ManualInputSheet> {
  final _amountCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  String _selectedCat = 'food';
  DateTime _selectedDate = DateTime.now();
  bool _loading = false;

  @override
  void dispose() { _amountCtrl.dispose(); _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
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
            value: _selectedCat,
            dropdownColor: AppColors.surface2,
            decoration: InputDecoration(
              labelText: 'الفئة',
              filled: true,
              fillColor: AppColors.surface2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.border)),
            ),
            items: variableCategories.map((c) => DropdownMenuItem(
              value: c.id,
              child: Text('${c.icon} ${c.nameAr}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
            )).toList(),
            onChanged: (v) => setState(() => _selectedCat = v ?? 'food'),
          ),
          const SizedBox(height: 12),
          // Amount
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: 'المبلغ',
              hintText: '0',
              filled: true, fillColor: AppColors.surface2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.border)),
            ),
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
          ),
          const SizedBox(height: 12),
          // Description
          TextField(
            controller: _nameCtrl,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: 'الوصف (اختياري)',
              hintText: 'مثال: بقالة الخميس',
              filled: true, fillColor: AppColors.surface2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.border)),
            ),
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
          ),
          const SizedBox(height: 12),
          // Date
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
                  const Text('📅', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    MudabbirDateUtils.formatDayAr(_selectedDate),
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Submit
          GestureDetector(
            onTap: _loading ? null : _submit,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('➕ إضافة',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 15,
                          fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    final amt = double.tryParse(_amountCtrl.text);
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ أدخل مبلغاً صحيحاً', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _loading = true);
    final cat = getCategoryById(_selectedCat);
    await ref.read(expenseActionsProvider).addExpense(
      categoryId: _selectedCat,
      name: _nameCtrl.text.isNotEmpty ? _nameCtrl.text : cat.nameAr,
      amount: amt,
      date: _selectedDate,
    );
    await ref.read(userActionsProvider).updateStreak();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم تسجيل $amt ريال — ${cat.nameAr}',
            style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
