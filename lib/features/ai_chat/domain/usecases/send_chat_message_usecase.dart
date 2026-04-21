import 'package:equatable/equatable.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../income/domain/repositories/income_repository.dart';
import '../../../goals/domain/repositories/goal_repository.dart';
import '../../../onboarding/domain/repositories/onboarding_repository.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

final class SendChatMessageParams extends Equatable {
  final String             message;
  final List<ChatMessage>  history;
  const SendChatMessageParams({required this.message, required this.history});
  @override List<Object?> get props => [message, history];
}

final class SendChatMessageUseCase {
  final ChatRepository       _chatRepo;
  final IncomeRepository     _incomeRepo;
  final ExpenseRepository    _expenseRepo;
  final GoalRepository       _goalRepo;
  final OnboardingRepository _onboardingRepo;

  SendChatMessageUseCase({
    required ChatRepository       chatRepo,
    required IncomeRepository     incomeRepo,
    required ExpenseRepository    expenseRepo,
    required GoalRepository       goalRepo,
    required OnboardingRepository onboardingRepo,
  })  : _chatRepo       = chatRepo,
        _incomeRepo     = incomeRepo,
        _expenseRepo    = expenseRepo,
        _goalRepo       = goalRepo,
        _onboardingRepo = onboardingRepo;

  Future<Result<String>> call(SendChatMessageParams p) async {
    // Edge: empty message
    if (p.message.trim().isEmpty)
      return const Fail(ValidationFailure('الرسالة فارغة'));

    // Edge: too long
    if (p.message.length > 500)
      return const Fail(ValidationFailure('الرسالة طويلة جداً — اختصر سؤالك'));

    // Build financial context from local data
    final context = await _buildContext();

    AppLogger.info('AIChatUseCase', 'Sending: ${p.message.substring(0, p.message.length.clamp(0, 40))}...');

    return _chatRepo.sendMessage(
      userMessage:      p.message.trim(),
      history:          p.history,
      financialContext: context,
    );
  }

  Future<Map<String, dynamic>> _buildContext() async {
    try {
      final now        = DateTime.now();
      final monthKey   = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final profile    = _onboardingRepo.getSaved();
      final income     = _incomeRepo.getByMonth(monthKey);
      final expenses   = _expenseRepo.totalByMonth(monthKey);
      final fixed      = _expenseRepo.totalFixed();
      final goals      = _goalRepo.getAll();
      final last3      = _incomeRepo.getLastMonths(monthKey, count: 3);

      return {
        'user': {
          'name':      profile?.name ?? '',
          'lifeStage': profile?.lifeStage.nameAr ?? '',
          'country':   profile?.countryId ?? 'sa',
        },
        'currentMonth': {
          'key':          monthKey,
          'income':       income.total,
          'expenses':     expenses + fixed,
          'balance':      income.total - expenses - fixed,
          'savingRate':   income.total > 0
              ? ((income.total - expenses - fixed) / income.total * 100).toStringAsFixed(1)
              : '0',
        },
        'goals': goals.map((g) => {
          'name':     g.name,
          'target':   g.target,
          'saved':    g.saved,
          'progress': '${(g.progress * 100).toStringAsFixed(0)}%',
        }).toList(),
        'trend': last3.map((m) => {
          'month':   m.monthKey,
          'income':  m.total,
        }).toList(),
      };
    } catch (e) {
      AppLogger.error('AIChatUseCase', 'Failed to build context', e);
      return {}; // Edge: context build fails — still send without context
    }
  }
}
