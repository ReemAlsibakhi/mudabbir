import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/goal_repository_impl.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/usecases/add_goal_usecase.dart';
import '../../domain/usecases/add_saving_usecase.dart';
import 'goals_state.dart';

final goalRepoProvider = Provider<GoalRepository>((_) => GoalRepositoryImpl());

final goalsNotifierProvider =
    StateNotifierProvider.autoDispose<GoalsNotifier, GoalsState>(
  (ref) => GoalsNotifier(ref.watch(goalRepoProvider)),
);

final class GoalsNotifier extends StateNotifier<GoalsState> {
  static const _tag = 'GoalsNotifier';
  final GoalRepository _repo;
  StreamSubscription?  _sub;

  GoalsNotifier(this._repo) : super(const GoalsLoading()) { _init(); }

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
          if (mounted) state = const GoalsError('تعذّر تحميل الأهداف');
        },
        cancelOnError: false,
      );
    } catch (e, st) {
      AppLogger.error(_tag, 'init failed', e, st);
      state = GoalsError('خطأ في تهيئة الأهداف: ${e.runtimeType}');
    }
  }

  Future<String?> addGoal(AddGoalParams params) async {
    if (!mounted || state is! GoalsLoaded) return null;
    state = (state as GoalsLoaded).copyWith(isSaving: true, clearError: true);

    final result = await AddGoalUseCase(_repo).call(params);
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

    // Check if goal will be completed after this saving
    final goals   = (state as GoalsLoaded).goals;
    final goal    = goals.where((g) => g.id == params.goalId).firstOrNull;
    final amount  = double.tryParse(params.amountRaw) ?? 0;
    final willComplete = goal != null && (goal.saved + amount) >= goal.target;

    final result = await AddSavingUseCase(_repo).call(params);
    if (!mounted) return null;

    if (result.isFailure) {
      state = (state as GoalsLoaded).copyWith(
        errorMessage: result.failureOrNull!.message);
      return result.failureOrNull!.message;
    }

    // Signal completion for celebration overlay
    if (willComplete && mounted) {
      state = (state as GoalsLoaded).copyWith(
        justCompletedGoalId: params.goalId);
    }
    return null;
  }

  Future<void> deleteGoal(String id) async {
    final result = await _repo.delete(id);
    if (result.isFailure && mounted && state is GoalsLoaded) {
      state = (state as GoalsLoaded).copyWith(errorMessage: 'تعذّر حذف الهدف');
    }
  }

  void clearError()      {
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
