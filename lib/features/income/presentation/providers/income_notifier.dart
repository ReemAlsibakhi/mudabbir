// ═══════════════════════════════════════════════════════════
// IncomeNotifier — ALL cases handled
// ═══════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/income_repository_impl.dart';
import '../../domain/entities/income.dart';
import '../../domain/repositories/income_repository.dart';
import '../../domain/usecases/save_income_usecase.dart';
import 'income_state.dart';

// ─── Providers ─────────────────────────────────────────────

final incomeRepoProvider = Provider<IncomeRepository>(
  (_) => IncomeRepositoryImpl(),
);

/// One notifier per month — auto-disposed when not watched
final incomeNotifierProvider =
    StateNotifierProvider.autoDispose.family<IncomeNotifier, IncomeState, String>(
  (ref, monthKey) {
    final repo = ref.watch(incomeRepoProvider);
    return IncomeNotifier(monthKey: monthKey, repo: repo);
  },
);

// ─── Notifier ──────────────────────────────────────────────

final class IncomeNotifier extends StateNotifier<IncomeState> {
  static const _tag = 'IncomeNotifier';

  final String             _monthKey;
  final IncomeRepository   _repo;
  StreamSubscription<Income>? _sub;

  IncomeNotifier({
    required String           monthKey,
    required IncomeRepository repo,
  })  : _monthKey = monthKey,
        _repo     = repo,
        super(const IncomeLoading()) {
    _init();
  }

  void _init() {
    try {
      _sub = _repo.watchByMonth(_monthKey).listen(
        _onData,
        onError:    _onStreamError,
        cancelOnError: false, // keep listening even after error
      );
    } catch (e, st) {
      // Edge: box not open, Hive not initialized
      AppLogger.error(_tag, 'Failed to init stream', e, st);
      state = IncomeError('تعذّر تحميل بيانات الدخل: ${e.runtimeType}');
    }
  }

  void _onData(Income income) {
    // Guard: don't update if disposed
    if (!mounted) return;
    state = IncomeLoaded(income: income);
  }

  void _onStreamError(Object e, StackTrace st) {
    AppLogger.error(_tag, 'Stream error', e, st);
    if (!mounted) return;
    // Soft error: stay on current data if we have it
    if (state is IncomeLoaded) {
      state = (state as IncomeLoaded).copyWith(
        saveError: 'خطأ في تحميل البيانات — تم استعادة آخر قيمة',
      );
    } else {
      state = IncomeError('تعذّر تحميل بيانات الدخل');
    }
  }

  // ── Save ──────────────────────────────────────────────────

  Future<void> save({
    required String primaryRaw,
    String secondaryRaw = '',
    String extraRaw     = '',
  }) async {
    // Guard: not in loaded state → ignore
    if (state is! IncomeLoaded) {
      AppLogger.warn(_tag, 'save called but state is not IncomeLoaded');
      return;
    }
    if (!mounted) return;

    // Optimistic: show saving
    state = (state as IncomeLoaded).copyWith(
      isSaving:   true,
      clearError: true,
    );

    final result = await SaveIncomeUseCase(_repo).call(
      SaveIncomeParams(
        monthKey:     _monthKey,
        primaryRaw:   primaryRaw,
        secondaryRaw: secondaryRaw,
        extraRaw:     extraRaw,
      ),
    );

    if (!mounted) return;

    result
      ..onSuccess((_) async {
        state = (state as IncomeLoaded).copyWith(
          isSaving:    false,
          saveSuccess: true,
          clearError:  true,
        );
        // Auto-clear success banner after 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        if (mounted && state is IncomeLoaded) {
          state = (state as IncomeLoaded).copyWith(saveSuccess: false);
        }
      })
      ..onFailure((f) {
        AppLogger.warn(_tag, 'Save failed: ${f.message}');
        state = (state as IncomeLoaded).copyWith(
          isSaving:  false,
          saveError: f.message,
        );
      });
  }

  /// Clear error banner (e.g. user dismissed it)
  void clearError() {
    if (state is IncomeLoaded) {
      state = (state as IncomeLoaded).copyWith(clearError: true);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
