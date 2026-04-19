import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/goal.dart';

class GoalCompletionOverlay {
  static Future<void> show(BuildContext context, Goal goal) => showDialog(
    context:             context,
    barrierDismissible:  false,
    builder:             (_) => _CompletionDialog(goal: goal),
  );
}

class _CompletionDialog extends StatefulWidget {
  final Goal goal;
  const _CompletionDialog({required this.goal});

  @override
  State<_CompletionDialog> createState() => _State();
}

class _State extends State<_CompletionDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    child: ScaleTransition(
      scale: _scale,
      child: Container(
        padding:     const EdgeInsets.all(28),
        decoration:  BoxDecoration(
          color:        AppColors.surface1,
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: AppColors.success.withOpacity(0.3)),
          boxShadow:    [BoxShadow(
            color: AppColors.success.withOpacity(0.2),
            blurRadius: 30,
          )],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.goal.type.icon, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text('تهانينا! 🎉', style: AppTextStyles.headline1),
            const SizedBox(height: 8),
            Text(
              'لقد حققت هدف\n"${widget.goal.name}"\nبنجاح! 🏆',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(height: 1.8),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              onPressed: () => Navigator.pop(context),
              child: Text('رائع! شكراً 🚀',
                style: AppTextStyles.button),
            ),
          ],
        ),
      ),
    ),
  );
}
