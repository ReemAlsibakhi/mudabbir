import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../../expenses/data/repositories/expense_repository_impl.dart';
import '../../../expenses/presentation/providers/expenses_notifier.dart';
import '../../../income/data/repositories/income_repository_impl.dart';
import '../../../income/presentation/providers/income_notifier.dart';
import '../../../onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../../onboarding/presentation/providers/onboarding_notifier.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/services/claude_api_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

// ── Provider ───────────────────────────────────────────────
final chatApiKeyProvider = StateProvider<String>((_) => '');

final chatRepoProvider = Provider<ChatRepository>((ref) {
  final apiKey = ref.watch(chatApiKeyProvider);
  return ChatRepositoryImpl(ClaudeApiService(apiKey));
});

final chatNotifierProvider =
    StateNotifierProvider.autoDispose<ChatNotifier, List<ChatMessage>>(
  (ref) => ChatNotifier(
    repo:            ref.watch(chatRepoProvider),
    incomeRepo:      IncomeRepositoryImpl(),
    expenseRepo:     ExpenseRepositoryImpl(),
    onboardingRepo:  OnboardingRepositoryImpl(),
  ),
);

// ── Notifier ───────────────────────────────────────────────
final class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  static const _tag = 'ChatNotifier';

  final ChatRepository _repo;
  final dynamic        _incomeRepo;
  final dynamic        _expenseRepo;
  final dynamic        _onboardingRepo;

  ChatNotifier({
    required ChatRepository _repo,
    required dynamic        incomeRepo,
    required dynamic        expenseRepo,
    required dynamic        onboardingRepo,
  }) : _repo           = _repo,
       _incomeRepo     = incomeRepo,
       _expenseRepo    = expenseRepo,
       _onboardingRepo = onboardingRepo,
       super([]) {
    _loadHistory();
  }

  void _loadHistory() {
    try {
      final history = _repo.loadHistory();
      if (history.isNotEmpty) state = history;
    } catch (e) {
      AppLogger.error(_tag, 'load history error', e);
    }
  }

  // ── Send message ──────────────────────────────────────────
  Future<void> send(String text) async {
    if (!mounted) return;
    if (text.trim().isEmpty) return;

    // Add user message
    final userMsg = ChatMessage.user(text);
    state = [...state, userMsg];

    // Add loading bubble
    final loadingMsg = ChatMessage.loading();
    state = [...state, loadingMsg];

    // Build financial context from real data
    final context = _buildContext();

    // Call Claude
    final result = await _repo.send(
      history:         state.where((m) => m.id != 'loading').toList(),
      userMessage:     text,
      financialContext: context,
    );

    if (!mounted) return;

    // Replace loading with real response
    final msgs = state.where((m) => m.id != 'loading').toList();
    if (result.isSuccess) {
      state = [...msgs, result.valueOrNull!];
      await _repo.saveHistory(state);
    } else {
      final errMsg = result.failureOrNull?.message ?? 'حدث خطأ، حاول مرة أخرى';
      state = [...msgs, ChatMessage.error(errMsg)];
    }
  }

  // ── Build context from user's real financial data ─────────
  String _buildContext() {
    try {
      final now       = DateTime.now();
      final monthKey  = '${now.year}-${now.month.toString().padLeft(2,'0')}';
      final profile   = _onboardingRepo.getSaved();
      final income    = _incomeRepo.getByMonth(monthKey);
      final expenses  = _expenseRepo.totalByMonth(monthKey);
      final fixed     = _expenseRepo.totalFixed();

      return '''
- الاسم: ${profile?.name ?? 'المستخدم'}
- مرحلة الحياة: ${profile?.lifeStage.nameAr ?? 'غير محدد'}
- الدخل الشهري: ${income.total.toStringAsFixed(0)} ريال
- المصروف المتغير: ${expenses.toStringAsFixed(0)} ريال
- المصروف الثابت: ${fixed.toStringAsFixed(0)} ريال
- الفائض: ${(income.total - expenses - fixed).toStringAsFixed(0)} ريال
- الشهر: $monthKey
''';
    } catch (e) {
      return 'بيانات المستخدم غير متاحة';
    }
  }

  void clearHistory() {
    state = [];
    _repo.clearHistory();
  }
}
