import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            // Bot avatar
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                gradient:     AppColors.primary,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 13))),
            ),
            const SizedBox(width: 7),
          ],

          // Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color:        isUser ? AppColors.accent : AppColors.surface2,
                borderRadius: BorderRadius.only(
                  topRight:    const Radius.circular(16),
                  topLeft:     const Radius.circular(16),
                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                  bottomLeft:  isUser ? const Radius.circular(16) : Radius.zero,
                ),
                border: isUser ? null : Border.all(color: AppColors.border),
              ),
              child: message.isSending
                  ? _ThinkingDots()
                  : Text(
                      message.text,
                      style: AppTextStyles.body.copyWith(
                        color:  isUser ? Colors.white : AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
            ),
          ),

          if (isUser) const SizedBox(width: 7),
        ],
      ),
    );
  }
}

class _ThinkingDots extends StatefulWidget {
  @override
  State<_ThinkingDots> createState() => _ThinkingState();
}

class _ThinkingState extends State<_ThinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) {
      final v = _ctrl.value;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final phase = (v + i * 0.3) % 1.0;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: 7, height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.textSecondary.withOpacity(
                  0.3 + 0.7 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2)),
              ),
            ),
          );
        }),
      );
    },
  );
}
