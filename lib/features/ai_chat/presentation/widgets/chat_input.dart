import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ChatInput extends StatefulWidget {
  final bool            isLoading;
  final ValueChanged<String> onSend;
  const ChatInput({super.key, required this.isLoading, required this.onSend});

  @override
  State<ChatInput> createState() => _State();
}

class _State extends State<ChatInput> {
  final _ctrl  = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(
      12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
    decoration: BoxDecoration(
      color:  AppColors.surface1,
      border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller:    _ctrl,
            textDirection: TextDirection.rtl,
            maxLines:      4, minLines: 1,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText:       'اسألني عن ميزانيتك...',
              hintStyle:      AppTextStyles.body.copyWith(color: AppColors.textTertiary),
              border:         OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:   BorderSide(color: AppColors.border),
              ),
              enabledBorder:  OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:   BorderSide(color: AppColors.border),
              ),
              focusedBorder:  OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:   BorderSide(color: AppColors.accent, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onSubmitted: _send,
          ),
        ),
        const SizedBox(width: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width:  44, height: 44,
          decoration: BoxDecoration(
            gradient:     (_hasText && !widget.isLoading) ? AppColors.primary : null,
            color:        (_hasText && !widget.isLoading) ? null : AppColors.surface3,
            borderRadius: BorderRadius.circular(14),
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)))
              : IconButton(
                  icon:     Icon(Icons.send_rounded,
                    size: 18, color: _hasText ? Colors.white : AppColors.textTertiary),
                  onPressed: _hasText ? () => _send(_ctrl.text) : null,
                ),
        ),
      ],
    ),
  );

  void _send(String text) {
    if (text.trim().isEmpty || widget.isLoading) return;
    widget.onSend(text.trim());
    _ctrl.clear();
  }
}
