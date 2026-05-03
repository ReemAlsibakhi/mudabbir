import '../../../../core/constants/app_strings.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/income_repository_impl.dart';
import '../../domain/repositories/income_repository.dart';
import '../../domain/usecases/save_income_usecase.dart';
import 'income_state.dart';

// ── Shared providers ─────────────────────────────────────
final incomeRepoProvider = Provider<IncomeRepository>(
  (_) => IncomeRepositoryImpl(),
);

// ✅ Injected UseCase
final saveIncomeUseCaseProvider = Provider<SaveIncomeUseCase>(
  (ref) => SaveIncomeUseCase(ref.watch(incomeRepoProvider)),
);

final incomeNotifierProvider =
    StateNotifierProvider.autoDispose.family<IncomeNotifier, IncomeState, String>(
  (ref, monthKey) => IncomeNotifier(
    monthKey:    monthKey,
    repo:        ref.watch(incomeRepoProvider),
    saveUseCase: ref.watch(saveIncomeUseCaseProvider),
  ),
);

final class IncomeNotifier extends StateNotifier<IncomeState> {
  static const _tag = 'IncomeNotifier';

  final String              _monthKey;
  final IncomeRepository    _repo;
  final SaveIncomeUseCase   _saveUseCase; // ✅ injected
  StreamSubscription?       _sub;

  IncomeNotifier({
    required String            monthKey,
    required IncomeRepository  repo,
    required SaveIncomeUseCase saveUseCase,
  })  : _monthKey    = monthKey,
        _repo        = repo,
        _saveUseCase = saveUseCase,
        super(const IncomeLoading()) {
    _init();
  }

  void _init() {
    try {
      _sub = _repo.watchByMonth(_monthKey).listen(
        (income) { if (mounted) state = IncomeLoaded(income: income); },
        onError: (e, st) {
          AppLogger.error(_tag, 'stream error', e, st as StackTrace);
          if (!mounted) return;
          if (state is IncomeLoaded) {
            state = (state as IncomeLoaded).copyWith(
              saveError: AppStrings.incomeDataError);
          } else {
            state = const IncomeError(AppStrings.incomeLoadFailed);
          }
        },
        cancelOnError: false,
      );
    } catch (e, st) {
      AppLogger.error(_tag, 'init failed', e, st);
      state = IncomeError('${AppStrings.incomeInitError}${e.runtimeType}');
    }
  }

  Future<void> save({
    required String primaryRaw,
    String secondaryRaw = '',
    String extraRaw     = '',
  }) async {
    if (state is! IncomeLoaded || !mounted) return;
    state = (state as IncomeLoaded).copyWith(isSaving: true, clearError: true);

    final result = await _saveUseCase(SaveIncomeParams( // ✅ injected
      monthKey:     _monthKey,
      primaryRaw:   primaryRaw,
      secondaryRaw: secondaryRaw,
      extraRaw:     extraRaw,
    ));

    if (!mounted) return;
    if (result.isFailure) {
      state = (state as IncomeLoaded).copyWith(
        isSaving: false, saveError: result.failureOrNull!.message);
    } else {
      state = (state as IncomeLoaded).copyWith(
        isSaving: false, saveSuccess: true, clearError: true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted && state is IncomeLoaded)
        state = (state as IncomeLoaded).copyWith(saveSuccess: false);
    }
  }

  void clearError() {
    if (mounted && state is IncomeLoaded)
      state = (state as IncomeLoaded).copyWith(clearError: true);
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }
}
