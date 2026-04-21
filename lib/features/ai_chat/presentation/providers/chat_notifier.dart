import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/logger.dart';
import '../../../expenses/data/repositories/expense_repository_impl.dart';
import '../../../goals/data/repositories/goal_repository_impl.dart';
import '../../../income/data/repositories/income_repository_impl.dart';
import '../../../onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_chat_message_usecase.dart';

// ── State ──────────────────────────────────────────────────
final class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool              isLoading;
  final String?           error;
  final bool              hasApiKey;

  const ChatState({
    this.messages  = const [],
    this.isLoading = false,
    this.error,
    this.hasApiKey = false,
  });

  bool get isEmpty    => messages.isEmpty;
  bool get hasError   => error != null;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool?              isLoading,
    String?            error,
    bool?              hasApiKey,
    bool               clearError = false,
  }) => ChatState(
    messages:  messages   ?? this.messages,
    isLoading: isLoading  ?? this.isLoading,
    error:     clearError ? null : error ?? this.error,
    hasApiKey: hasApiKey  ?? this.hasApiKey,
  );

  @override
  List<Object?> get props => [messages, isLoading, error, hasApiKey];
}

// ── Provider ───────────────────────────────────────────────
final chatApiKeyProvider = StateProvider<String>((ref) => '');

final chatNotifierProvider =
    StateNotifierProvider.autoDispose<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(ref),
);

// ── Notifier ───────────────────────────────────────────────
final class ChatNotifier extends StateNotifier<ChatState> {
  static const _tag = 'ChatNotifier';
  final Ref _ref;

  ChatNotifier(this._ref) : super(const ChatState()) {
    _init();
  }

  void _init() {
    // Add welcome message
    final notifier = _ref.read(onboardingRepoProvider);
    final profile  = notifier.getSaved();
    final name     = profile?.name ?? 'صديقي';

    state = state.copyWith(messages: [
      ChatMessage(
        id:        'welcome',
        role:      MessageRole.assistant,
        text:      'مرحباً يا $name 👋\n\nأنا مدبّر، مساعدك المالي الذكي. '
                   'اسألني عن أي شيء يخص ميزانيتك — تحليل المصاريف، '
                   'نصائح الادخار، أو التخطيط لأهدافك.',
        createdAt: DateTime.now(),
      ),
    ]);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isLoading) return;
    if (!mounted) return;

    // Add user message
    final userMsg = ChatMessage.user(text);
    state = state.copyWith(
      messages:   [...state.messages, userMsg],
      isLoading:  true,
      clearError: true,
    );

    // Add thinking bubble
    final thinking = ChatMessage.thinking();
    state = state.copyWith(
      messages: [...state.messages, thinking],
    );

    final apiKey = _ref.read(chatApiKeyProvider);
    if (apiKey.isEmpty) {
      if (!mounted) return;
      _removeThinking();
      state = state.copyWith(
        isLoading: false,
        error:     'يحتاج مفتاح API — أضفه في الإعدادات',
      );
      return;
    }

    // Build use case
    final useCase = SendChatMessageUseCase(
      chatRepo:       ChatRepositoryImpl(apiKey: apiKey),
      incomeRepo:     IncomeRepositoryImpl(),
      expenseRepo:    ExpenseRepositoryImpl(),
      goalRepo:       GoalRepositoryImpl(),
      onboardingRepo: OnboardingRepositoryImpl(),
    );

    final result = await useCase.call(
      SendChatMessageParams(
        message: text,
        history: state.messages
            .where((m) => m.id != 'thinking' && m.id != 'welcome')
            .toList(),
      ),
    );

    if (!mounted) return;
    _removeThinking();

    result
      ..onSuccess((reply) async {
        final assistantMsg = ChatMessage(
          id:        DateTime.now().millisecondsSinceEpoch.toString(),
          role:      MessageRole.assistant,
          text:      reply,
          createdAt: DateTime.now(),
        );
        state = state.copyWith(
          messages:  [...state.messages, assistantMsg],
          isLoading: false,
          clearError: true,
        );
      })
      ..onFailure((f) {
        AppLogger.warn(_tag, 'Chat failed: ${f.message}');
        state = state.copyWith(
          isLoading: false,
          error:     f.message,
        );
      });
  }

  void _removeThinking() {
    state = state.copyWith(
      messages: state.messages.where((m) => m.id != 'thinking').toList(),
    );
  }

  void clearError() => state = state.copyWith(clearError: true);

  void clearHistory() {
    state = const ChatState();
    _init();
  }
}
