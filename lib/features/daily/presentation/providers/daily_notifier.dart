import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/utils/logger.dart';
import '../../../expenses/domain/usecases/add_expense_usecase.dart';
import '../../../expenses/presentation/providers/expenses_notifier.dart';
import '../../data/repositories/streak_repository_impl.dart';
import '../../domain/entities/streak.dart';
import '../../domain/repositories/streak_repository.dart';

final streakRepoProvider = Provider<StreakRepository>((_) => StreakRepositoryImpl());

final streakProvider = StateNotifierProvider<StreakNotifier, Streak>(
  (ref) => StreakNotifier(ref.watch(streakRepoProvider)),
);

final class StreakNotifier extends StateNotifier<Streak> {
  static const _tag = 'StreakNotifier';
  final StreakRepository _repo;

  StreakNotifier(this._repo) : super(const Streak()) { _load(); }

  void _load() {
    try {
      state = _repo.get();
    } catch (e) {
      AppLogger.error(_tag, 'load error', e);
      state = const Streak();
    }
  }

  Future<void> markLogged() async {
    if (state.loggedToday) return; // Edge: already logged
    final updated = state.markLogged();
    state = updated;
    await _repo.save(updated);
    AppLogger.info(_tag, 'Streak marked: ${updated.count} days');
  }

  Future<bool> useRescueToken() async {
    if (state.rescueTokens <= 0) return false; // Edge: no tokens
    if (state.loggedToday)       return false; // Edge: already logged
    final updated = state.useRescueToken();
    state = updated;
    await _repo.save(updated);
    return true;
  }

  Future<void> reset() async {
    state = const Streak();
    await _repo.reset();
  }
}

// ── Quick-add from daily screen ───────────────────────────
final dailyActionsProvider = Provider((ref) => DailyActions(ref));

final class DailyActions {
  final Ref _ref;
  DailyActions(this._ref);

  Future<String?> addExpenseAndLog(AddExpenseParams params) async {
    final monthKey = params.date.monthKey;
    final error    = await _ref
        .read(expensesNotifierProvider(monthKey).notifier)
        .addExpense(params);

    if (error == null) {
      await _ref.read(streakProvider.notifier).markLogged();
    }
    return error;
  }

  Future<void> noSpendToday() async {
    await _ref.read(streakProvider.notifier).markLogged();
    AppLogger.info('DailyActions', 'No-spend day marked');
  }
}
