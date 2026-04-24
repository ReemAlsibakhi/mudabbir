import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ChatInput extends StatefulWidget {
  final ValueChanged<String> onSend;
  const ChatInput({super.key, required this.onSend});

  @override
  State<ChatInput> createState() => _State();
}

class _State extends State<ChatInput> {
  final _ctrl  = TextEditingController();
  bool  _ready = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final ok = _ctrl.text.trim().isNotEmpty;
      if (ok != _ready) setState(() => _ready = ok);
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(12, 8, 12,
      MediaQuery.of(context).viewInsets.bottom + 12),
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
            maxLines:      4,
            minLines:      1,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            textInputAction: TextInputAction.send,
            onSubmitted:     (_) => _send(),
            decoration: InputDecoration(
              hintText:       'اسأل عن ميزانيتك...',
              border:         OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:   BorderSide.none,
              ),
              filled:         true,
              fillColor:      AppColors.surface2,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient:     _ready ? AppColors.primary : null,
            color:        _ready ? null : AppColors.surface2,
            borderRadius: BorderRadius.circular(13),
          ),
          child: IconButton(
            onPressed: _ready ? _send : null,
            icon: Icon(Icons.send_rounded,
              color: _ready ? Colors.white : AppColors.textTertiary,
              size:  20),
          ),
        ),
      ],
    ),
  );

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    _ctrl.clear();
    widget.onSend(t);
  }
}
