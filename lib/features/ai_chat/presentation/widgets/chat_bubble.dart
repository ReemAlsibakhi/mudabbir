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
            _Avatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                gradient: isUser ? null : AppColors.primaryDeep,
                color:    isUser ? AppColors.surface2 : null,
                borderRadius: BorderRadius.only(
                  topRight:    const Radius.circular(16),
                  topLeft:     const Radius.circular(16),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft:  Radius.circular(isUser ? 16 : 4),
                ),
                border: Border.all(
                  color: isUser
                      ? AppColors.border
                      : AppColors.accent.withOpacity(0.2)),
              ),
              child: message.isLoading
                  ? _LoadingDots()
                  : message.hasError
                  ? Text(message.content,
                      style: AppTextStyles.body.copyWith(color: AppColors.error))
                  : Text(message.content,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary, height: 1.6)),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _UserAvatar(),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 30, height: 30,
    decoration: BoxDecoration(
      gradient:     AppColors.primary,
      borderRadius: BorderRadius.circular(9),
    ),
    child: const Center(
      child: Text('🤖', style: TextStyle(fontSize: 15)),
    ),
  );
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 30, height: 30,
    decoration: BoxDecoration(
      color:        AppColors.surface3,
      borderRadius: BorderRadius.circular(9),
      border:       Border.all(color: AppColors.border),
    ),
    child: const Center(
      child: Text('👤', style: TextStyle(fontSize: 15)),
    ),
  );
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _DotsState();
}

class _DotsState extends State<_LoadingDots>
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
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(3, (i) => AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final offset = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
        final opacity = (0.3 + (0.7 * (offset < 0.5 ? offset * 2 : (1 - offset) * 2))).clamp(0.3, 1.0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppColors.accentAlt),
            ),
          ),
        );
      },
    )),
  );
}
