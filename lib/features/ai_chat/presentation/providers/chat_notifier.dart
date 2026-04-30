import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../expenses/data/repositories/expense_repository_impl.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../goals/data/repositories/goal_repository_impl.dart';
import '../../../goals/domain/repositories/goal_repository.dart';
import '../../../income/data/repositories/income_repository_impl.dart';
import '../../../income/domain/repositories/income_repository.dart';
import '../../../onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../../onboarding/domain/repositories/onboarding_repository.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/services/claude_api_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

// ── API key ───────────────────────────────────────────────
final apiKeyProvider = StateNotifierProvider<ApiKeyNotifier, String>(
  (_) => ApiKeyNotifier(),
);

final class ApiKeyNotifier extends StateNotifier<String> {
  static const _key = 'anthropic_api_key';
  Box get _box => Hive.box(AppConstants.settingsBox);

  ApiKeyNotifier() : super('') { _load(); }

  void _load() => state = _box.get(_key, defaultValue: '') as String;

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

// ── Typed repo providers — avoids manual instantiation ────
final _chatIncomeRepoProvider  = Provider<IncomeRepository> ((_) => IncomeRepositoryImpl());
final _chatExpenseRepoProvider = Provider<ExpenseRepository>((_) => ExpenseRepositoryImpl());
final _chatGoalRepoProvider    = Provider<GoalRepository>   ((_) => GoalRepositoryImpl());
final _chatOnboardRepoProvider = Provider<OnboardingRepository>((_) => OnboardingRepositoryImpl());

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

// ── Notifier (typed interfaces, no dynamic) ───────────────
final chatNotifierProvider =
    StateNotifierProvider.autoDispose<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(
    repo:           ref.watch(chatRepoProvider),
    incomeRepo:     ref.watch(_chatIncomeRepoProvider),
    expenseRepo:    ref.watch(_chatExpenseRepoProvider),
    goalRepo:       ref.watch(_chatGoalRepoProvider),
    onboardingRepo: ref.watch(_chatOnboardRepoProvider),
  ),
);

final class ChatNotifier extends StateNotifier<ChatState> {
  static const _tag = 'ChatNotifier';

  // ✅ Typed interfaces — no dynamic
  final ChatRepository        _repo;
  final IncomeRepository      _incomeRepo;
  final ExpenseRepository     _expenseRepo;
  final GoalRepository        _goalRepo;
  final OnboardingRepository  _onboardingRepo;

  ChatNotifier({
    required ChatRepository       repo,
    required IncomeRepository     incomeRepo,
    required ExpenseRepository    expenseRepo,
    required GoalRepository       goalRepo,
    required OnboardingRepository onboardingRepo,
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
      final h = _repo.loadHistory();
      if (h.isNotEmpty) state = state.copyWith(messages: h);
    } catch (e) {
      AppLogger.error(_tag, 'load history', e);
    }
  }

  Future<void> send(String text) async {
    if (!mounted) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMsg = ChatMessage.user(trimmed);
    state = state.copyWith(
      messages:   [...state.messages, userMsg],
      isTyping:   true,
      clearError: true,
    );
    await _repo.saveHistory(state.messages);

    final result = await _repo.send(
      history:          _historyOnly(),
      userMessage:      trimmed,
      financialContext: _buildContext(),
    );

    if (!mounted) return;
    if (result.isSuccess) {
      state = state.copyWith(
        messages: [...state.messages, result.valueOrNull!],
        isTyping: false,
      );
      await _repo.saveHistory(state.messages);
    } else {
      final err = result.failureOrNull?.message ?? 'حدث خطأ';
      state = state.copyWith(
        messages: [...state.messages, ChatMessage.error(err)],
        isTyping: false,
        error:    err,
      );
    }
  }

  void clearHistory() {
    state = const ChatState();
    _repo.clearHistory();
  }

  void clearError() => state = state.copyWith(clearError: true);

  List<ChatMessage> _historyOnly() =>
      state.messages.where((m) => !m.isLoading).toList();

  String _buildContext() {
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
        'الدخل الشهري: ${income.total.toStringAsFixed(0)}',
        'المصاريف المتغيرة: ${varExp.toStringAsFixed(0)}',
        'المصاريف الثابتة: ${fixedExp.toStringAsFixed(0)}',
        'الفائض: ${balance.toStringAsFixed(0)}',
        'الأهداف النشطة: ${goals.where((g) => !g.isCompleted).length}',
        'الشهر: $monthKey',
      ].join('\n');
    } catch (e) {
      AppLogger.error(_tag, 'context error', e);
      return 'بيانات غير متاحة';
    }
  }
}
