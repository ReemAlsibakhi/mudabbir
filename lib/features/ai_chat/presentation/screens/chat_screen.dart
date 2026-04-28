import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/chat_notifier.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/suggested_questions.dart';
import 'api_key_setup_screen.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasKey = ref.watch(apiKeyProvider).isNotEmpty;

    // Only gate: does user have an API key?
    if (!hasKey) return const _KeySetupGate();

    return const _ChatContent();
  }
}

// ── API Key Setup gate ────────────────────────────────────
class _KeySetupGate extends StatelessWidget {
  const _KeySetupGate();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded,
          color: AppColors.textPrimary),
        onPressed: () => context.go(AppRoutes.home),
      ),
      title: Text('مستشارك المالي 🤖', style: AppTextStyles.title),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryDeep,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Text('🤖', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text('المستشار المالي الذكي',
                  style: AppTextStyles.headline2,
                  textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'اسألني عن ميزانيتك، مصاريفك، أهدافك — وسأجيبك بناءً على بياناتك الحقيقية',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── How to get key ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface1,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🔑', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text('احصل على مفتاح API مجاني',
                      style: AppTextStyles.bodyBold),
                  ],
                ),
                const SizedBox(height: 12),
                ...[
                  '1. افتح: console.anthropic.com',
                  '2. أنشئ حساباً مجانياً',
                  '3. من القائمة: API Keys ← Create Key',
                  '4. انسخ المفتاح والصقه أدناه',
                ].map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(s,
                    style: AppTextStyles.body.copyWith(fontSize: 13)),
                )),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded,
                        size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'مجاني تماماً — Anthropic تعطي رصيداً ابتدائياً مجاناً',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Embed the API key input directly ───────────
          const ApiKeySetupScreen(fromChat: false, embedded: true),
        ],
      ),
    ),
  );
}

// ── Main Chat ─────────────────────────────────────────────
class _ChatContent extends ConsumerStatefulWidget {
  const _ChatContent();

  @override
  ConsumerState<_ChatContent> createState() => _State();
}

class _State extends ConsumerState<_ChatContent> {
  final _scroll = ScrollController();

  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final messages  = chatState.messages.where((m) => !m.isLoading).toList();
    final isTyping  = chatState.isTyping;
    final hasError  = chatState.error != null;

    ref.listen(chatNotifierProvider, (prev, next) {
      if (next.messages.length != (prev?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
            color: AppColors.textPrimary),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: Column(
          children: [
            Text('مستشارك المالي', style: AppTextStyles.title),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success),
                ),
                const SizedBox(width: 4),
                Text('Claude AI — جاهز',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success)),
              ],
            ),
          ],
        ),
        actions: [
          // Change API key
          IconButton(
            icon: const Icon(Icons.key_outlined,
              color: AppColors.textTertiary, size: 20),
            tooltip: 'تغيير المفتاح',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                  const ApiKeySetupScreen(fromChat: true))),
          ),
          // Clear history
          if (messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.textTertiary, size: 20),
              tooltip: 'مسح المحادثة',
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // Error banner
          if (hasError)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
              color: AppColors.error.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                    size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatState.error!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                      ref.read(chatNotifierProvider.notifier).clearError(),
                    child: const Icon(Icons.close_rounded,
                      size: 14, color: AppColors.error),
                  ),
                ],
              ),
            ),

          Expanded(
            child: messages.isEmpty && !isTyping
                ? _EmptyState(onTap: _send)
                : _MessageList(
                    messages: messages,
                    isTyping: isTyping,
                    scroll:   _scroll,
                  ),
          ),
          ChatInput(onSend: _send),
        ],
      ),
    );
  }

  void _send(String text) =>
    ref.read(chatNotifierProvider.notifier).send(text);

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
      }
    });
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface2,
        title: Text('مسح المحادثة', style: AppTextStyles.title),
        content: Text('سيتم حذف كل الرسائل', style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('مسح',
              style: AppTextStyles.body.copyWith(
                color: AppColors.error))),
        ],
      ),
    );
    if (ok == true) {
      ref.read(chatNotifierProvider.notifier).clearHistory();
    }
  }
}

class _EmptyState extends ConsumerWidget {
  final ValueChanged<String> onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    children: [
      Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🤖', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 16),
                Text('ابدأ المحادثة',
                  style: AppTextStyles.headline2),
                const SizedBox(height: 8),
                Text(
                  'اسألني عن ميزانيتك، مصاريفك، أو أي قرار مالي',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      SuggestedQuestions(onTap: onTap),
      const SizedBox(height: 8),
    ],
  );
}

class _MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool              isTyping;
  final ScrollController  scroll;

  const _MessageList({
    required this.messages,
    required this.isTyping,
    required this.scroll,
  });

  @override
  Widget build(BuildContext context) => ListView.builder(
    controller: scroll,
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    itemCount: messages.length + (isTyping ? 1 : 0),
    itemBuilder: (_, i) {
      if (isTyping && i == messages.length)
        return ChatBubble(message: ChatMessage.loading());
      return ChatBubble(message: messages[i]);
    },
  );
}
