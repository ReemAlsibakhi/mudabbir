import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// ═══════════════════════════════════════════════════════════
// WeddingBudgetSheet — تفصيل تكاليف الزواج للمخطوب
// يسمح للمستخدم بإدخال كل بند بشكل منفصل
// ويحسب الإجمالي والمبلغ الشهري المطلوب
// ═══════════════════════════════════════════════════════════

class WeddingBudgetSheet extends StatefulWidget {
  final int      monthsLeft;
  final double   alreadySaved;
  final Function(double total) onTotalChanged;

  const WeddingBudgetSheet({
    super.key,
    required this.monthsLeft,
    required this.alreadySaved,
    required this.onTotalChanged,
  });

  static Future<double?> show(
    BuildContext context, {
    required int    monthsLeft,
    required double alreadySaved,
  }) => showModalBottomSheet<double>(
    context:           context,
    isScrollControlled: true,
    builder: (_) => WeddingBudgetSheet(
      monthsLeft:   monthsLeft,
      alreadySaved: alreadySaved,
      onTotalChanged: (_) {},
    ),
  );

  @override
  State<WeddingBudgetSheet> createState() => _State();
}

class _State extends State<WeddingBudgetSheet> {
  // ── Controllers for each wedding cost item ─────────────
  final _items = <_WeddingItem>[
    _WeddingItem(AppStrings.weddingMahr,       '💍'),
    _WeddingItem(AppStrings.weddingShebka,     '💎'),
    _WeddingItem(AppStrings.weddingHall,       '🏛️'),
    _WeddingItem(AppStrings.weddingHoneymoon,  '✈️'),
    _WeddingItem(AppStrings.weddingApartment,  '🏠'),
    _WeddingItem(AppStrings.weddingFurniture,  '🛋️'),
  ];

  double get _total => _items.fold(0, (s, i) => s + i.value);
  double get _remaining => (_total - widget.alreadySaved).clamp(0, double.infinity);
  double get _monthlyNeeded =>
      widget.monthsLeft > 0 ? _remaining / widget.monthsLeft : _remaining;

  // Percentage of goal achieved relative to total
  double get _progress => _total > 0
      ? (widget.alreadySaved / _total).clamp(0, 1.0) : 0;

  // Is the user behind? Compare current savings vs ideal savings by now
  // Ideal: alreadySaved should be proportional to elapsed months
  bool get _isBehind {
    if (_total <= 0 || widget.monthsLeft <= 0) return false;
    // We don't know total duration here, just show deficit if < 10% saved
    return _progress < 0.1 && _remaining > 0;
  }

  @override
  void dispose() {
    for (final i in _items) i.ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Center(
              child: Text(AppStrings.weddingBudgetTitle,
                style: AppTextStyles.title),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '${widget.monthsLeft} ${AppStrings.weddingMonthsLeft}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accentAlt),
              ),
            ),
            const SizedBox(height: 16),

            // Each cost item
            ..._items.map((item) => _CostRow(
              item:      item,
              onChanged: () => setState(() {
                widget.onTotalChanged(_total);
              }),
            )),

            const SizedBox(height: 12),
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.weddingTotal,
                  style: AppTextStyles.bodyBold),
                Text(_total.fmt(),
                  style: AppTextStyles.headline2.copyWith(
                    color: AppColors.accentAlt)),
              ],
            ),
            const SizedBox(height: 12),

            // Monthly needed insight
            if (_total > 0 && _monthlyNeeded > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.14)),
                ),
                child: Text(
                  '${AppStrings.weddingNeedPerMonth}'
                  '${_monthlyNeeded.fmt()}'
                  '${AppStrings.weddingPerMonthSuf}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.accentAlt),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 8),

            // Progress vs target
            if (widget.alreadySaved > 0 && _total > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (_progress < 0.5
                      ? AppColors.error : AppColors.success).withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (_progress < 0.5
                        ? AppColors.error : AppColors.success).withOpacity(0.15)),
                ),
                child: Text(
                  _progress < 0.5
                      ? '${AppStrings.weddingBehindPre}'
                        '${((1 - _progress) * 100).toStringAsFixed(0)}'
                        '${AppStrings.weddingBehindSuf}'
                      : AppStrings.weddingOnTrack,
                  style: AppTextStyles.caption.copyWith(
                    color: _progress < 0.5
                        ? AppColors.error : AppColors.success),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Confirm button — returns total to caller
            GestureDetector(
              onTap: () => Navigator.pop(context, _total),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primary,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text('استخدام الإجمالي ${_total.fmt()}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ─────────────────────────────────────────────
class _WeddingItem {
  final String label, icon;
  final TextEditingController ctrl;
  _WeddingItem(this.label, this.icon) : ctrl = TextEditingController();
  double get value => double.tryParse(ctrl.text.replaceAll(',','')) ?? 0;
}

// ── Row widget ─────────────────────────────────────────────
class _CostRow extends StatelessWidget {
  final _WeddingItem item;
  final VoidCallback onChanged;
  const _CostRow({required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Text(item.icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(item.label,
            style: AppTextStyles.body.copyWith(fontSize: 13)),
        ),
        Expanded(
          flex: 3,
          child: TextField(
            controller:   item.ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textDirection: TextDirection.rtl,
            onChanged:    (_) => onChanged(),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,٠-٩٫]')),
            ],
            style: AppTextStyles.body.copyWith(
              fontSize: 14, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              hintText: '0',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10, vertical: 8),
            ),
          ),
        ),
      ],
    ),
  );
}
