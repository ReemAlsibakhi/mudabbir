import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/chat_notifier.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_suggestions.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatNotifierProvider);

    ref.listen(chatNotifierProvider, (_, next) {
      if (next.error != null) {
        context.showSnack(next.error!, color: AppColors.error);
        ref.read(chatNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface1,
        title: Column(
          children: [
            Text('🤖 مدبّر الذكي', style: AppTextStyles.title),
            Text('مساعدك المالي الشخصي',
              style: AppTextStyles.caption.copyWith(color: AppColors.accentAlt)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
              color: AppColors.textTertiary, size: 20),
            onPressed: () => ref.read(chatNotifierProvider.notifier).clearHistory(),
            tooltip: 'مسح المحادثة',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: state.isEmpty
                ? const _EmptyChat()
                : _MessagesList(messages: state.messages, isLoading: state.isLoading),
          ),
          // Suggestions (shown when empty or few messages)
          if (state.messages.length <= 2)
            ChatSuggestions(
              onSelect: (q) => ref.read(chatNotifierProvider.notifier).sendMessage(q),
            ),
          // Input bar
          ChatInput(
            isLoading: state.isLoading,
            onSend:    (text) => ref.read(chatNotifierProvider.notifier).sendMessage(text),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🤖', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 12),
        Text('اسألني أي شيء عن ميزانيتك',
          style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Text('أستطيع تحليل مصاريفك، نصائح الادخار\nوالتخطيط لأهدافك المالية',
          style: AppTextStyles.body, textAlign: TextAlign.center),
      ],
    ),
  );
}

class _MessagesList extends StatefulWidget {
  final List messages;
  final bool   isLoading;
  const _MessagesList({required this.messages, required this.isLoading});

  @override
  State<_MessagesList> createState() => _State();
}

class _State extends State<_MessagesList> {
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(_MessagesList old) {
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
  void dispose() { _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ListView.builder(
    controller:  _scroll,
    padding:     const EdgeInsets.fromLTRB(12, 12, 12, 8),
    itemCount:   widget.messages.length,
    itemBuilder: (_, i) => ChatBubble(message: widget.messages[i]),
  );
}
