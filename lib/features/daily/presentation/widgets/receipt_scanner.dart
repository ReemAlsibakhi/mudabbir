import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../expenses/domain/usecases/add_expense_usecase.dart';
import '../providers/daily_notifier.dart';

// ══════════════════════════════════════════════════════════
// ReceiptScanner — تصوير الفاتورة + OCR تلقائي
// PRD: يقرأ مبلغ الفاتورة العربية/الإنجليزية تلقائياً
// ══════════════════════════════════════════════════════════

class ReceiptScanner extends ConsumerStatefulWidget {
  final DateTime month;
  const ReceiptScanner({super.key, required this.month});

  @override
  ConsumerState<ReceiptScanner> createState() => _State();
}

class _State extends ConsumerState<ReceiptScanner> {
  final _picker = ImagePicker();
  bool  _loading = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _scan,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
      decoration: BoxDecoration(
        color:        AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _loading
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.accentAlt))
              : const Text('📷', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            _loading ? AppStrings.receiptScanning : AppStrings.receiptScan,
            style: AppTextStyles.body.copyWith(
              color: AppColors.accentAlt,
              fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );

  Future<void> _scan() async {
    // Pick image from camera or gallery
    final source = await showModalBottomSheet<ImageSource>(
      context:  context,
      builder:  (_) => const _SourcePicker(),
    );
    if (source == null || !mounted) return;

    final image = await _picker.pickImage(
      source:    source,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;

    setState(() => _loading = true);

    try {
      // Run ML Kit text recognition
      final inputImage = InputImage.fromFile(File(image.path));
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final result     = await recognizer.processImage(inputImage);
      await recognizer.close();

      // Extract amount from recognized text
      final amount = _extractAmount(result.text);

      if (!mounted) return;
      setState(() => _loading = false);

      if (amount == null) {
        context.showSnack(AppStrings.receiptNoAmount, color: AppColors.warning);
        return;
      }

      // Show confirmation sheet
      _showConfirm(amount, result.text);

    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        context.showSnack(AppStrings.receiptError, color: AppColors.error);
      }
    }
  }

  // Extract the final/largest amount from receipt text
  double? _extractAmount(String text) {
    // Look for patterns: 150.00 / ١٥٠٫٠٠ / SAR 150 / المجموع 150
    final normalized = text
        .replaceAllMapped(RegExp(r'[٠-٩]'),
            (m) => (m.group(0)!.codeUnitAt(0) - 0x0660).toString())
        .replaceAll('٫', '.');

    // Find numbers that look like totals
    final amounts = RegExp(r'\d+(?:\.\d{1,2})?')
        .allMatches(normalized)
        .map((m) => double.tryParse(m.group(0)!))
        .where((n) => n != null && n > 1 && n < 100000)
        .cast<double>()
        .toList()
      ..sort();

    // Return the largest (usually the total) or null
    return amounts.isEmpty ? null : amounts.last;
  }

  void _showConfirm(double amount, String rawText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ReceiptConfirmSheet(
        amount: amount,
        month:  widget.month,
      ),
    );
  }
}

// Source picker
class _SourcePicker extends StatelessWidget {
  const _SourcePicker();
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Text('📷', style: TextStyle(fontSize: 22)),
          title:   Text(AppStrings.receiptCamera,
            style: AppTextStyles.body),
          onTap: () => Navigator.pop(context, ImageSource.camera),
        ),
        ListTile(
          leading: const Text('🖼️', style: TextStyle(fontSize: 22)),
          title:   Text(AppStrings.receiptGallery,
            style: AppTextStyles.body),
          onTap: () => Navigator.pop(context, ImageSource.gallery),
        ),
      ],
    ),
  );
}

// Confirm sheet after OCR
class _ReceiptConfirmSheet extends ConsumerStatefulWidget {
  final double   amount;
  final DateTime month;
  const _ReceiptConfirmSheet({required this.amount, required this.month});

  @override
  ConsumerState<_ReceiptConfirmSheet> createState() => _ConfirmState();
}

class _ConfirmState extends ConsumerState<_ReceiptConfirmSheet> {
  late final TextEditingController _amtCtrl;
  String _catId   = 'food';
  bool   _loading = false;

  @override
  void initState() {
    super.initState();
    _amtCtrl = TextEditingController(
      text: widget.amount.toStringAsFixed(2));
  }

  @override
  void dispose() { _amtCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 16, right: 16, top: 20,
      bottom: MediaQuery.of(context).viewInsets.bottom + 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('📷', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        Text(AppStrings.receiptFound, style: AppTextStyles.headline2),
        const SizedBox(height: 4),
        Text(AppStrings.receiptConfirmSub, style: AppTextStyles.body),
        const SizedBox(height: 16),
        // Amount edit
        TextField(
          controller:    _amtCtrl,
          textDirection: TextDirection.rtl,
          keyboardType:  TextInputType.number,
          style: AppTextStyles.headline2.copyWith(
            color: AppColors.accentAlt, fontSize: 28),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: AppStrings.amountLabel),
        ),
        const SizedBox(height: 14),
        // Category select — quick chips
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ['food','restaurants','transport','shopping','health','other']
              .map((id) {
            from lib '../../../../core/constants/categories.dart';
            final cat  = getCategoryById(id);
            final sel  = _catId == id;
            return GestureDetector(
              onTap: () => setState(() => _catId = id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? AppColors.accent.withOpacity(0.12) : AppColors.surface2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: sel ? AppColors.accent : AppColors.border),
                ),
                child: Text('${cat.icon} ${cat.nameAr}',
                  style: AppTextStyles.caption.copyWith(
                    color: sel ? AppColors.accentAlt : AppColors.textSecondary,
                    fontWeight: FontWeight.w700)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Confirm
        GestureDetector(
          onTap: _confirm,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient:     AppColors.primary,
              borderRadius: BorderRadius.circular(12)),
            child: Center(child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(AppStrings.receiptAddBtn, style: AppTextStyles.button)),
          ),
        ),
      ],
    ),
  );

  Future<void> _confirm() async {
    final amount = double.tryParse(_amtCtrl.text);
    if (amount == null || amount <= 0) return;
    setState(() => _loading = true);
    await ref.read(dailyActionsProvider).addExpenseAndLog(
      AddExpenseParams(
        categoryId: _catId,
        name:       AppStrings.receiptExpenseName,
        amountRaw:  amount.toString(),
        date:       DateTime.now(),
      ),
    );
    if (mounted) Navigator.pop(context);
  }
}
