import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/ui/widgets/mud_card.dart';
import '../../../../shared/ui/widgets/mud_progress_bar.dart';
import '../../domain/entities/goal.dart';
import '../../domain/usecases/add_saving_usecase.dart';
import '../providers/goals_notifier.dart';

class GoalCard extends ConsumerStatefulWidget {
  final Goal goal;
  final bool completed;
  const GoalCard({super.key, required this.goal, this.completed = false});

  @override
  ConsumerState<GoalCard> createState() => _State();
}

class _State extends ConsumerState<GoalCard> {
  final _amountCtrl = TextEditingController();
  bool  _adding     = false;
  String? _error;

  @override
  void dispose() { _amountCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final g          = widget.goal;
    final color      = widget.completed ? AppColors.success : AppColors.accent;
    final monthsLeft = g.monthsLeft;
    final faster     = g.monthlyTarget > 0
        ? g.monthlyNeeded((monthsLeft ?? 12) ~/ 2) : null;

    return MudCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(g.type.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.name, style: AppTextStyles.bodyBold, maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                    Text(g.type.nameAr, style: AppTextStyles.caption),
                  ],
                ),
              ),
              // Delete
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: const Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress
          MudProgressBar(
            value:  g.progress,
            color:  color,
            height: 9,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('مدخر: ${g.saved.fmt()}',
                style: AppTextStyles.caption.copyWith(color: AppColors.success)),
              Text('${(g.progress * 100).toStringAsFixed(1)}%',
                style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w800)),
              Text('الهدف: ${g.target.fmt()}',
                style: AppTextStyles.caption),
            ],
          ),

          // Insight
          if (!widget.completed) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:        AppColors.accent.withOpacity(0.06),
                borderRadius: BorderRadius.circular(9),
                border:       Border.all(color: AppColors.accent.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 المتبقي: ${g.remaining.fmt()}'
                    '${monthsLeft != null ? ' · $monthsLeft شهر بمعدلك الحالي' : ''}',
                    style: AppTextStyles.caption.copyWith(height: 1.6),
                  ),
                  if (faster != null && monthsLeft != null && monthsLeft > 1)
                    Text(
                      '⚡ بادخار ${faster.fmt()}/شهر → ${(monthsLeft ~/ 2)} شهر فقط',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentAlt, height: 1.6),
                    ),
                ],
              ),
            ),
          ] else
            Container(
              margin:  const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color:        AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: Text('🎉 تم تحقيق الهدف! مبروك!',
                  style: AppTextStyles.bodyBold.copyWith(color: AppColors.success)),
              ),
            ),

          // Add saving input
          if (!widget.completed) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:   _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText:        'إضافة مبلغ',
                      contentPadding:  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      errorText:       _error,
                      errorStyle:      AppTextStyles.caption.copyWith(color: AppColors.error),
                    ),
                    onChanged: (_) { if (_error != null) setState(() => _error = null); },
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _adding ? null : _addSaving,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    decoration: BoxDecoration(
                      gradient:     _adding ? null : AppColors.primary,
                      color:        _adding ? AppColors.surface3 : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _adding
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                        : Text('إضافة', style: AppTextStyles.button.copyWith(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addSaving() async {
    final raw = _amountCtrl.text.trim();
    if (raw.isEmpty) {
      setState(() => _error = 'أدخل مبلغاً');
      return;
    }
    setState(() { _adding = true; _error = null; });

    final error = await ref.read(goalsNotifierProvider.notifier).addSaving(
      AddSavingParams(goalId: widget.goal.id, amountRaw: raw),
    );

    if (!mounted) return;
    setState(() => _adding = false);

    if (error != null) {
      setState(() => _error = error);
    } else {
      _amountCtrl.clear();
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface2,
        title:   Text('حذف الهدف', style: AppTextStyles.title),
        content: Text('هل تريد حذف هدف "${widget.goal.name}"؟',
          style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف',
              style: AppTextStyles.body.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(goalsNotifierProvider.notifier).deleteGoal(widget.goal.id);
    }
  }
}
