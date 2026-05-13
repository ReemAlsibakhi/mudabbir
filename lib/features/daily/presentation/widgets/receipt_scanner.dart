import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../expenses/domain/usecases/add_expense_usecase.dart';
import '../providers/daily_notifier.dart';

// ══════════════════════════════════════════════════════════
// ReceiptScanner
// OCR receipt scanning using google_mlkit_text_recognition
// Reads Arabic & English amounts from photos automatically
// ══════════════════════════════════════════════════════════

class ReceiptScanner extends ConsumerStatefulWidget {
  final DateTime month;
  const ReceiptScanner({super.key, required this.month});

  @override
  ConsumerState<ReceiptScanner> createState() => _ReceiptScannerState();
}

class _ReceiptScannerState extends ConsumerState<ReceiptScanner> {
  final _picker = ImagePicker();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _pickAndScan,
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
            if (_loading)
              const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.accentAlt))
            else
              const Text('📷', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              _loading ? AppStrings.receiptScanning : AppStrings.receiptScan,
              style: AppTextStyles.body.copyWith(
                color:      AppColors.accentAlt,
                fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndScan() async {
    // 1. Let user choose source
    final source = await _showSourcePicker();
    if (source == null || !mounted) return;

    // 2. Pick image
    final picked = await _picker.pickImage(
      source:       source,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _loading = true);

    try {
      // 3. Run OCR
      final amount = await _extractAmountFromImage(picked.path);

      if (!mounted) return;
      setState(() => _loading = false);

      if (amount == null) {
        context.showSnack(AppStrings.receiptNoAmount, color: AppColors.warning);
        return;
      }

      // 4. Show confirmation
      if (mounted) {
        showModalBottomSheet(
          context:            context,
          isScrollControlled: true,
          builder:            (_) => _ConfirmSheet(
            amount: amount,
            month:  widget.month,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        context.showSnack(AppStrings.receiptError, color: AppColors.error);
      }
    }
  }

  Future<ImageSource?> _showSourcePicker() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('📷', style: TextStyle(fontSize: 22)),
              title:   Text(AppStrings.receiptCamera, style: AppTextStyles.body),
              onTap:   () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Text('🖼️', style: TextStyle(fontSize: 22)),
              title:   Text(AppStrings.receiptGallery, style: AppTextStyles.body),
              onTap:   () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<double?> _extractAmountFromImage(String imagePath) async {
    final inputImage = InputImage.fromFile(File(imagePath));
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final result = await recognizer.processImage(inputImage);
      return _parseAmount(result.text);
    } finally {
      await recognizer.close();
    }
  }

  // Extracts the largest plausible total from OCR text
  double? _parseAmount(String text) {
    // Normalize Arabic-Indic digits → ASCII and Arabic decimal separator
    final normalized = text
        .replaceAllMapped(
          RegExp(r'[٠-٩]'),
          (m) => (m.group(0)!.codeUnitAt(0) - 0x0660).toString(),
        )
        .replaceAll('٫', '.');

    // Match numbers: 150 / 150.00 / 1,500
    final matches = RegExp(r'\d{1,7}(?:[.,]\d{1,3})*(?:\.\d{1,2})?')
        .allMatches(normalized)
        .map((m) {
          final clean = m.group(0)!.replaceAll(',', '');
          return double.tryParse(clean);
        })
        .where((n) => n != null && n >= 1 && n <= 99999)
        .cast<double>()
        .toList()
      ..sort();

    return matches.isEmpty ? null : matches.last;
  }
}

// ── Confirmation sheet ────────────────────────────────────
class _ConfirmSheet extends ConsumerStatefulWidget {
  final double   amount;
  final DateTime month;
  const _ConfirmSheet({required this.amount, required this.month});

  @override
  ConsumerState<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends ConsumerState<_ConfirmSheet> {
  late final TextEditingController _amtCtrl;
  String _catId  = 'food';
  bool   _saving = false;

  static const _cats = [
    'food', 'restaurants', 'transport',
    'shopping', 'health', 'other',
  ];

  @override
  void initState() {
    super.initState();
    _amtCtrl = TextEditingController(
      text: widget.amount.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _amtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left:   16, right: 16, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📷', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(AppStrings.receiptFound, style: AppTextStyles.headline2),
          const SizedBox(height: 4),
          Text(AppStrings.receiptConfirmSub, style: AppTextStyles.body),
          const SizedBox(height: 16),

          // Editable amount
          TextField(
            controller:    _amtCtrl,
            textDirection: TextDirection.rtl,
            keyboardType:  TextInputType.number,
            textAlign:     TextAlign.center,
            style: AppTextStyles.headline2.copyWith(
              color: AppColors.accentAlt, fontSize: 28),
            decoration: InputDecoration(labelText: AppStrings.amountLabel),
          ),
          const SizedBox(height: 14),

          // Category chips
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _cats.map((id) {
              final cat = getCategoryById(id);
              final sel = _catId == id;
              return GestureDetector(
                onTap: () => setState(() => _catId = id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:        sel
                        ? AppColors.accent.withOpacity(0.12)
                        : AppColors.surface2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: sel ? AppColors.accent : AppColors.border,
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    '${cat.icon} ${cat.nameAr}',
                    style: AppTextStyles.caption.copyWith(
                      color:      sel
                          ? AppColors.accentAlt : AppColors.textSecondary,
                      fontWeight: FontWeight.w700),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Save button
          GestureDetector(
            onTap: _saving ? null : _save,
            child: Container(
              width:   double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient:     _saving ? null : AppColors.primary,
                color:        _saving ? AppColors.surface3 : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                    : Text(AppStrings.receiptAddBtn,
                        style: AppTextStyles.button),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amtCtrl.text.trim());
    if (amount == null || amount <= 0) return;

    setState(() => _saving = true);

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
