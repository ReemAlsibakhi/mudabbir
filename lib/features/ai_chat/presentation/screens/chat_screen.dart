import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/chat_notifier.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/suggested_questions.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('مستشارك المالي', style: AppTextStyles.title),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.success),
                ),
                const SizedBox(width: 4),
                Text('Claude AI',
                  style: AppTextStyles.caption.copyWith(color: AppColors.success)),
              ],
            ),
          ],
        ),
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.textTertiary),
              onPressed: () => _confirmClear(context, ref),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _EmptyState()
                : _MessageList(messages: messages),
          ),
          ChatInput(
            onSend: (text) =>
                ref.read(chatNotifierProvider.notifier).send(text),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface2,
        title: Text('مسح المحادثة', style: AppTextStyles.title),
        content: Text('هل تريد مسح سجل المحادثة كاملاً؟',
          style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('مسح', style: AppTextStyles.body.copyWith(
              color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(chatNotifierProvider.notifier).clearHistory();
    }
  }
}

class _EmptyState extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    children: [
      Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🤖', style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 14),
              Text('مستشارك المالي الذكي',
                style: AppTextStyles.title),
              const SizedBox(height: 6),
              Text('اسألني أي شيء عن ميزانيتك',
                style: AppTextStyles.body, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      SuggestedQuestions(
        onTap: (q) => ref.read(chatNotifierProvider.notifier).send(q),
      ),
      const SizedBox(height: 8),
    ],
  );
}

class _MessageList extends StatefulWidget {
  final List<ChatMessage> messages;
  const _MessageList({required this.messages});

  @override
  State<_MessageList> createState() => _State();
}

class _State extends State<_MessageList> {
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(_MessageList old) {
    super.didUpdateWidget(old);
    if (widget.messages.length != old.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => ListView.builder(
    controller:  _scroll,
    padding:     const EdgeInsets.fromLTRB(16, 12, 16, 8),
    itemCount:   widget.messages.length,
    itemBuilder: (_, i) => ChatBubble(message: widget.messages[i]),
  );
}
