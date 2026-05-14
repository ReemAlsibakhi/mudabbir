import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../../daily/data/repositories/streak_repository_impl.dart';
import '../../../daily/domain/repositories/streak_repository.dart';
import '../../../expenses/presentation/providers/expenses_notifier.dart';
import '../../../goals/presentation/providers/goals_notifier.dart';
import '../../../income/presentation/providers/income_notifier.dart';
import '../../../onboarding/presentation/providers/onboarding_notifier.dart';
import '../../data/repositories/insight_repository_impl.dart';
import '../../domain/entities/insight.dart';
import '../../domain/repositories/insight_repository.dart';
import '../../domain/usecases/get_insights_usecase.dart';

// ── Shared providers ──────────────────────────────────────

final insightRepoProvider = Provider<InsightRepository>(
  (_) => InsightRepositoryImpl(),
);

final streakRepoProvider = Provider<StreakRepository>(
  (_) => StreakRepositoryImpl(),
);

final getInsightsUseCaseProvider = Provider<GetInsightsUseCase>(
  (ref) => GetInsightsUseCase(
    incomeRepo:     ref.watch(incomeRepoProvider),
    expenseRepo:    ref.watch(expenseRepoProvider),
    goalRepo:       ref.watch(goalRepoProvider),
    onboardingRepo: ref.watch(onboardingRepoProvider),
    streakRepo:     ref.watch(streakRepoProvider),
    insightRepo:    ref.watch(insightRepoProvider),
  ),
);

// ── State ─────────────────────────────────────────────────

final class InsightsState {
  final List<Insight> insights;
  final bool          isLoading;

  const InsightsState({
    this.insights  = const [],
    this.isLoading = false,
  });

  InsightsState copyWith({
    List<Insight>? insights,
    bool?          isLoading,
  }) => InsightsState(
    insights:  insights  ?? this.insights,
    isLoading: isLoading ?? this.isLoading,
  );
}

// ── Notifier ──────────────────────────────────────────────

final insightsNotifierProvider =
    StateNotifierProvider.autoDispose<InsightsNotifier, InsightsState>(
  (ref) {
    final notifier = InsightsNotifier(ref.watch(getInsightsUseCaseProvider),
        ref.watch(insightRepoProvider));

    // Refresh whenever expenses, income, or goals change
    ref.listen(expenseRepoProvider,    (_, __) => notifier.refresh());
    ref.listen(incomeRepoProvider,     (_, __) => notifier.refresh());
    ref.listen(goalRepoProvider,       (_, __) => notifier.refresh());

    return notifier;
  },
);

final class InsightsNotifier extends StateNotifier<InsightsState> {
  static const _tag = 'InsightsNotifier';

  final GetInsightsUseCase _useCase;
  final InsightRepository  _insightRepo;

  InsightsNotifier(this._useCase, this._insightRepo)
      : super(const InsightsState()) {
    _init();
  }

  Future<void> _init() async {
    await _insightRepo.clearIfNewDay();
    refresh();
  }

  void refresh() {
    if (!mounted) return;
    try {
      final insights = _useCase.call(maxResults: 3);
      state = state.copyWith(insights: insights, isLoading: false);
    } catch (e, st) {
      AppLogger.error(_tag, 'refresh failed', e, st);
      state = state.copyWith(insights: [], isLoading: false);
    }
  }

  Future<void> dismiss(String insightId) async {
    await _insightRepo.dismiss(insightId);
    refresh();
  }
}
