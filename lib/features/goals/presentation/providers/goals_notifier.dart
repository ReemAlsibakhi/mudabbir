import '../../../../core/constants/app_strings.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/goal_repository_impl.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/usecases/add_goal_usecase.dart';
import '../../domain/usecases/add_saving_usecase.dart';
import 'goals_state.dart';

// ── Shared providers ─────────────────────────────────────
final goalRepoProvider = Provider<GoalRepository>(
  (_) => GoalRepositoryImpl(),
);

// ✅ Injected UseCases — fully mockable in tests
final addGoalUseCaseProvider = Provider<AddGoalUseCase>(
  (ref) => AddGoalUseCase(ref.watch(goalRepoProvider)),
);
final addSavingUseCaseProvider = Provider<AddSavingUseCase>(
  (ref) => AddSavingUseCase(ref.watch(goalRepoProvider)),
);

final goalsNotifierProvider =
    StateNotifierProvider.autoDispose<GoalsNotifier, GoalsState>(
  (ref) => GoalsNotifier(
    repo:           ref.watch(goalRepoProvider),
    addGoalUseCase: ref.watch(addGoalUseCaseProvider),
    addSavingUseCase: ref.watch(addSavingUseCaseProvider),
  ),
);

final class GoalsNotifier extends StateNotifier<GoalsState> {
  static const _tag = 'GoalsNotifier';

  final GoalRepository   _repo;
  final AddGoalUseCase   _addGoalUseCase;
  final AddSavingUseCase _addSavingUseCase;
  StreamSubscription?    _sub;

  GoalsNotifier({
    required GoalRepository   repo,
    required AddGoalUseCase   addGoalUseCase,
    required AddSavingUseCase addSavingUseCase,
  })  : _repo             = repo,
        _addGoalUseCase   = addGoalUseCase,
        _addSavingUseCase = addSavingUseCase,
        super(const GoalsLoading()) {
    _init();
  }

  void _init() {
    try {
      _sub = _repo.watchAll().listen(
        (goals) {
          if (!mounted) return;
          final prev = state is GoalsLoaded ? state as GoalsLoaded : const GoalsLoaded();
          state = prev.copyWith(goals: goals, clearError: true);
        },
        onError: (e, st) {
          AppLogger.error(_tag, 'stream error', e, st as StackTrace);
          if (mounted) state = const GoalsError(AppStrings.goalLoadFailed);
        },
        cancelOnError: false,
      );
    } catch (e, st) {
      AppLogger.error(_tag, 'init failed', e, st);
      state = GoalsError('${AppStrings.goalInitError}${e.runtimeType}');
    }
  }

  Future<String?> addGoal(AddGoalParams params) async {
    if (!mounted || state is! GoalsLoaded) return null;
    state = (state as GoalsLoaded).copyWith(isSaving: true, clearError: true);
    final result = await _addGoalUseCase(params); // ✅ injected
    if (!mounted) return null;
    if (result.isFailure) {
      state = (state as GoalsLoaded).copyWith(
        isSaving: false, errorMessage: result.failureOrNull!.message);
      return result.failureOrNull!.message;
    }
    state = (state as GoalsLoaded).copyWith(isSaving: false, clearError: true);
    return null;
  }

  Future<String?> addSaving(AddSavingParams params) async {
    if (!mounted || state is! GoalsLoaded) return null;
    final goals = (state as GoalsLoaded).goals;
    final goal  = goals.where((g) => g.id == params.goalId).firstOrNull;
    final amount = double.tryParse(params.amountRaw) ?? 0;
    final willComplete = goal != null && (goal.saved + amount) >= goal.target;
    final result = await _addSavingUseCase(params); // ✅ injected
    if (!mounted) return null;
    if (result.isFailure) {
      state = (state as GoalsLoaded).copyWith(
          errorMessage: result.failureOrNull!.message);
      return result.failureOrNull!.message;
    }
    if (willComplete && mounted) {
      state = (state as GoalsLoaded).copyWith(
          justCompletedGoalId: params.goalId);
    }
    return null;
  }

  Future<void> deleteGoal(String id) async {
    final result = await _repo.delete(id);
    if (result.isFailure && mounted && state is GoalsLoaded)
      state = (state as GoalsLoaded).copyWith(errorMessage: AppStrings.goalDelFailed);
  }

  void clearError() {
    if (mounted && state is GoalsLoaded)
      state = (state as GoalsLoaded).copyWith(clearError: true);
  }

  void clearCompletion() {
    if (mounted && state is GoalsLoaded)
      state = (state as GoalsLoaded).copyWith(clearCompletion: true);
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }
}
