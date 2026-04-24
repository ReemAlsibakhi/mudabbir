import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/services/claude_api_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../expenses/data/repositories/expense_repository_impl.dart';
import '../../../goals/data/repositories/goal_repository_impl.dart';
import '../../../income/data/repositories/income_repository_impl.dart';
import '../../../onboarding/data/repositories/onboarding_repository_impl.dart';

// ── API key stored in settings box ────────────────────────
final apiKeyProvider = StateNotifierProvider<ApiKeyNotifier, String>(
  (_) => ApiKeyNotifier(),
);

final class ApiKeyNotifier extends StateNotifier<String> {
  static const _key = 'anthropic_api_key';
  Box get _box => Hive.box(AppConstants.settingsBox);

  ApiKeyNotifier() : super('') { _load(); }

  void _load() {
    state = _box.get(_key, defaultValue: '') as String;
  }

  Future<void> set(String key) async {
    state = key.trim();
    await _box.put(_key, key.trim());
  }

  Future<void> clear() async {
    state = '';
    await _box.delete(_key);
  }

  bool get hasKey => state.isNotEmpty;
}

// ── Chat repo provider ────────────────────────────────────
final chatRepoProvider = Provider<ChatRepository>((ref) {
  final key = ref.watch(apiKeyProvider);
  return ChatRepositoryImpl(ClaudeApiService(key));
});

// ── Chat state ────────────────────────────────────────────
final class ChatState {
  final List<ChatMessage> messages;
  final bool              isTyping;
  final String?           error;

  const ChatState({
    this.messages = const [],
    this.isTyping = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool?              isTyping,
    String?            error,
    bool               clearError = false,
  }) => ChatState(
    messages: messages ?? this.messages,
    isTyping: isTyping ?? this.isTyping,
    error:    clearError ? null : error ?? this.error,
  );
}

// ── Notifier ──────────────────────────────────────────────
final chatNotifierProvider =
    StateNotifierProvider.autoDispose<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(
    repo:           ref.watch(chatRepoProvider),
    incomeRepo:     IncomeRepositoryImpl(),
    expenseRepo:    ExpenseRepositoryImpl(),
    goalRepo:       GoalRepositoryImpl(),
    onboardingRepo: OnboardingRepositoryImpl(),
  ),
);

final class ChatNotifier extends StateNotifier<ChatState> {
  static const _tag = 'ChatNotifier';

  final ChatRepository        _repo;
  final IncomeRepositoryImpl  _incomeRepo;
  final ExpenseRepositoryImpl _expenseRepo;
  final GoalRepositoryImpl    _goalRepo;
  final OnboardingRepositoryImpl _onboardingRepo;

  ChatNotifier({
    required ChatRepository        repo,
    required IncomeRepositoryImpl  incomeRepo,
    required ExpenseRepositoryImpl expenseRepo,
    required GoalRepositoryImpl    goalRepo,
    required OnboardingRepositoryImpl onboardingRepo,
  })  : _repo           = repo,
        _incomeRepo     = incomeRepo,
        _expenseRepo    = expenseRepo,
        _goalRepo       = goalRepo,
        _onboardingRepo = onboardingRepo,
        super(const ChatState()) {
    _loadHistory();
  }

  void _loadHistory() {
    try {
      final history = _repo.loadHistory();
      if (history.isNotEmpty) state = state.copyWith(messages: history);
    } catch (e) {
      AppLogger.error(_tag, 'load history', e);
    }
  }

  // ── Send ──────────────────────────────────────────────────
  Future<void> send(String text) async {
    if (!mounted) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Add user message
    final userMsg = ChatMessage.user(trimmed);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
      clearError: true,
    );

    // Save user message
    await _repo.saveHistory(state.messages);

    // Build financial context from real Hive data
    final context = _buildFinancialContext();

    // Call Claude
    final result = await _repo.send(
      history:          _historyWithoutLoading(),
      userMessage:      trimmed,
      financialContext: context,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      final assistantMsg = ChatMessage(
        id:        DateTime.now().millisecondsSinceEpoch.toString(),
        role:      MessageRole.assistant,
        content:   result.valueOrNull!,
        createdAt: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        isTyping: false,
      );
      await _repo.saveHistory(state.messages);
    } else {
      final errText = result.failureOrNull?.message ?? 'حدث خطأ';
      state = state.copyWith(
        messages: [...state.messages, ChatMessage.error(errText)],
        isTyping: false,
        error:    errText,
      );
    }
  }

  // ── Clear ─────────────────────────────────────────────────
  void clearHistory() {
    state = const ChatState();
    _repo.clearHistory();
  }

  void clearError() => state = state.copyWith(clearError: true);

  // ── Helpers ───────────────────────────────────────────────

  List<ChatMessage> _historyWithoutLoading() =>
      state.messages.where((m) => !m.isLoading).toList();

  String _buildFinancialContext() {
    try {
      final now      = DateTime.now();
      final monthKey = '${now.year}-${now.month.toString().padLeft(2,'0')}';
      final profile  = _onboardingRepo.getSaved();
      final income   = _incomeRepo.getByMonth(monthKey);
      final varExp   = _expenseRepo.totalByMonth(monthKey);
      final fixedExp = _expenseRepo.totalFixed();
      final goals    = _goalRepo.getAll();
      final balance  = income.total - varExp - fixedExp;

      return [
        'الاسم: ${profile?.name ?? "المستخدم"}',
        'مرحلة الحياة: ${profile?.lifeStage.nameAr ?? "غير محدد"}',
        'الدخل الشهري: ${income.total.toStringAsFixed(0)} ريال',
        'المصاريف المتغيرة: ${varExp.toStringAsFixed(0)} ريال',
        'المصاريف الثابتة: ${fixedExp.toStringAsFixed(0)} ريال',
        'الفائض: ${balance.toStringAsFixed(0)} ريال',
        'عدد الأهداف النشطة: ${goals.where((g) => !g.isCompleted).length}',
        'الشهر: $monthKey',
      ].join('\n');
    } catch (e) {
      AppLogger.error(_tag, 'context build error', e);
      return 'بيانات غير متاحة';
    }
  }
}
