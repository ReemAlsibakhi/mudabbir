import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../freemium/presentation/providers/subscription_provider.dart';
import '../../../freemium/presentation/screens/paywall_screen.dart';
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
    final isPremium = ref.watch(subscriptionProvider).canUseAiChat;
    final hasKey = ref.watch(apiKeyProvider).isNotEmpty;

    if (!isPremium) return const _PaywallGate();
    if (!hasKey) return const _KeySetupGate();

    return const _ChatContent();
  }
}

// ── Paywall gate — with back ───────────────────────────────
class _PaywallGate extends StatelessWidget {
  const _PaywallGate();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          // ✅ Back button — returns to home
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.textPrimary),
            onPressed: () => context.go(AppRoutes.home),
          ),
          title: Text('المستشار الذكي', style: AppTextStyles.title),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🤖', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text('المستشار الذكي للمشتركين',
                    style: AppTextStyles.headline2,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'احصل على نصائح مالية مخصصة بناءً على بياناتك الحقيقية',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () => PaywallScreen.show(
                    context,
                    feature: 'المستشار الذكي',
                    desc: 'اسأل عن ميزانيتك واحصل على إجابات مخصصة بالعربي',
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text('👑 اشترك الآن',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// ── Key setup gate ─────────────────────────────────────────
class _KeySetupGate extends StatelessWidget {
  const _KeySetupGate();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.textPrimary),
            onPressed: () => context.go(AppRoutes.home),
          ),
          title: Text('إعداد المستشار', style: AppTextStyles.title),
        ),
        body: const ApiKeySetupScreen(fromChat: true),
      );
}

// ── Main chat UI ───────────────────────────────────────────
class _ChatContent extends ConsumerStatefulWidget {
  const _ChatContent();

  @override
  ConsumerState<_ChatContent> createState() => _State();
}

class _State extends ConsumerState<_ChatContent> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final messages = chatState.messages.where((m) => !m.isLoading).toList();
    final isTyping = chatState.isTyping;

    ref.listen(chatNotifierProvider, (prev, next) {
      if (next.messages.length != (prev?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        // ✅ Back button — returns to previous screen (daily)
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
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 4),
                Text('Claude AI — متاح',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.success)),
              ],
            ),
          ],
        ),
        actions: [
          // API key settings
          IconButton(
            icon: const Icon(Icons.key_outlined, color: AppColors.textTertiary),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ApiKeySetupScreen(fromChat: true))),
          ),
          // Clear history
          if (messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.textTertiary),
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty && !isTyping
                ? _EmptyState(onQuestionTap: _send)
                : _MessageList(
                    messages: messages,
                    isTyping: isTyping,
                    scroll: _scrollCtrl,
                  ),
          ),
          ChatInput(onSend: _send),
        ],
      ),
    );
  }

  void _send(String text) => ref.read(chatNotifierProvider.notifier).send(text);

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface2,
        title: Text('مسح المحادثة', style: AppTextStyles.title),
        content:
            Text('سيتم حذف سجل المحادثة كاملاً', style: AppTextStyles.body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('إلغاء',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('مسح',
                  style: AppTextStyles.body.copyWith(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true) ref.read(chatNotifierProvider.notifier).clearHistory();
  }
}

class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onQuestionTap;
  const _EmptyState({required this.onQuestionTap});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 14),
                  Text('مستشارك المالي', style: AppTextStyles.headline2),
                  const SizedBox(height: 8),
                  Text('اسألني عن ميزانيتك، أهدافك، أو أي قرار مالي',
                      style: AppTextStyles.body, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          SuggestedQuestions(onTap: onQuestionTap),
          const SizedBox(height: 8),
        ],
      );
}

class _MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool isTyping;
  final ScrollController scroll;

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
