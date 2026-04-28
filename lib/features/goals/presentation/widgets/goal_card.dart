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
  bool  _expanded   = false; // ✅ input collapsed by default
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
          // ── Header ──────────────────────────────────
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color:        color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(g.type.icon,
                    style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.name,
                      style: AppTextStyles.bodyBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                    Text(g.type.nameAr,
                      style: AppTextStyles.caption),
                  ],
                ),
              ),
              // Delete
              IconButton(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppColors.textTertiary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Progress bar ──────────────────────────────
          MudProgressBar(value: g.progress, color: color, height: 9),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(g.saved.fmt(),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.success, fontWeight: FontWeight.w700)),
              Text('${(g.progress * 100).toStringAsFixed(1)}%',
                style: AppTextStyles.caption.copyWith(
                  color: color, fontWeight: FontWeight.w800)),
              Text(g.target.fmt(),
                style: AppTextStyles.caption),
            ],
          ),

          // ── Insight box ───────────────────────────────
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
                    '${monthsLeft != null ? ' · $monthsLeft شهر بمعدلك' : ''}',
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

            const SizedBox(height: 8),

            // ── Add saving — collapsed by default ────────
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: GestureDetector(
                onTap: () => setState(() => _expanded = true),
                child: Container(
                  width:   double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color:        AppColors.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border:       Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded,
                        size: 16, color: AppColors.accentAlt),
                      const SizedBox(width: 6),
                      Text('إضافة مبلغ للادخار',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentAlt,
                          fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              secondChild: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:   _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textDirection: TextDirection.rtl,
                      autofocus:    true,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText:       'المبلغ',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                        errorText:  _error,
                        errorStyle: AppTextStyles.caption.copyWith(
                          color: AppColors.error),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close_rounded,
                            size: 16, color: AppColors.textTertiary),
                          onPressed: () => setState(() {
                            _expanded = false;
                            _amountCtrl.clear();
                            _error = null;
                          }),
                        ),
                      ),
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _adding ? null : _addSaving,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient:     _adding ? null : AppColors.primary,
                        color:        _adding ? AppColors.surface3 : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _adding
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                          : Text('إضافة',
                              style: AppTextStyles.button.copyWith(
                                fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            // ── Completed badge ──────────────────────────
            Container(
              margin:  const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color:        AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: Text('🎉 تم تحقيق الهدف! مبروك!',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.success)),
              ),
            ),
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
      AddSavingParams(goalId: widget.goal.id, amountRaw: raw));
    if (!mounted) return;
    setState(() => _adding = false);
    if (error != null) {
      setState(() => _error = error);
    } else {
      _amountCtrl.clear();
      setState(() => _expanded = false);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
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
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف',
              style: AppTextStyles.body.copyWith(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true) {
      ref.read(goalsNotifierProvider.notifier).deleteGoal(widget.goal.id);
    }
  }
}
