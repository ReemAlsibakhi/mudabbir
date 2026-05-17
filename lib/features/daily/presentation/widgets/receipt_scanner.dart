import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
// User picks a photo → enters amount manually → saves expense
// OCR removed: google_mlkit caused Swift linker errors on iOS
// ══════════════════════════════════════════════════════════

class ReceiptScanner extends ConsumerStatefulWidget {
  final DateTime month;
  const ReceiptScanner({super.key, required this.month});

  @override
  ConsumerState<ReceiptScanner> createState() => _ReceiptScannerState();
}

class _ReceiptScannerState extends ConsumerState<ReceiptScanner> {
  final _picker  = ImagePicker();
  bool  _loading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _pickImage,
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

  Future<void> _pickImage() async {
    final source = await _showSourcePicker();
    if (source == null || !mounted) return;

    setState(() => _loading = true);
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (!mounted) return;
    setState(() => _loading = false);

    if (picked == null) return;

    // Show manual entry sheet — user reads the amount themselves
    if (mounted) {
      showModalBottomSheet(
        context:            context,
        isScrollControlled: true,
        builder:            (_) => _ManualEntrySheet(month: widget.month),
      );
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
}

// ── Manual entry after photo ──────────────────────────────
class _ManualEntrySheet extends ConsumerStatefulWidget {
  final DateTime month;
  const _ManualEntrySheet({required this.month});

  @override
  ConsumerState<_ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends ConsumerState<_ManualEntrySheet> {
  final _amtCtrl = TextEditingController();
  String _catId  = 'food';
  bool   _saving = false;

  static const _cats = [
    'food', 'restaurants', 'transport', 'health', 'shopping', 'other',
  ];

  @override
  void dispose() { _amtCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: const Text('📷', style: TextStyle(fontSize: 40))),
          const SizedBox(height: 8),
          Center(child: Text(AppStrings.receiptFound, style: AppTextStyles.headline2)),
          const SizedBox(height: 4),
          Center(child: Text(AppStrings.receiptConfirmSub, style: AppTextStyles.body)),
          const SizedBox(height: 16),

          // Amount input
          TextField(
            controller:    _amtCtrl,
            textDirection: TextDirection.rtl,
            keyboardType:  TextInputType.number,
            textAlign:     TextAlign.center,
            autofocus:     true,
            style: AppTextStyles.headline2.copyWith(
              color: AppColors.accentAlt, fontSize: 32),
            decoration: InputDecoration(labelText: AppStrings.amountLabel),
          ),
          const SizedBox(height: 14),

          // Category chips
          Wrap(
            spacing: 8, runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _cats.map((id) {
              final cat = getCategoryById(id);
              final sel = _catId == id;
              return GestureDetector(
                onTap: () => setState(() => _catId = id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.accent.withValues(alpha: 0.14)
                        : AppColors.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel ? AppColors.accent : AppColors.border,
                      width: sel ? 1.5 : 1),
                  ),
                  child: Text('${cat.icon} ${cat.nameAr}',
                    style: AppTextStyles.caption.copyWith(
                      color:      sel ? AppColors.accentAlt : AppColors.textSecondary,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Save button
          GestureDetector(
            onTap: _saving ? null : _save,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient:     _saving ? null : AppColors.primary,
                color:        _saving ? AppColors.surface3 : null,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                    : Text(AppStrings.receiptAddBtn, style: AppTextStyles.button),
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
