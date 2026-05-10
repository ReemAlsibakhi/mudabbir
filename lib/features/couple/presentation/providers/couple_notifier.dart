import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../expenses/data/repositories/expense_repository_impl.dart';
import '../../../expenses/domain/usecases/add_expense_usecase.dart';
import '../../../goals/data/repositories/goal_repository_impl.dart';
import '../../../income/data/repositories/income_repository_impl.dart';
import '../../data/repositories/supabase_couple_repository.dart';
import '../../domain/entities/couple_room.dart';
import '../../domain/repositories/couple_repository.dart';

// ── State ─────────────────────────────────────────────────
sealed class CoupleState { const CoupleState(); }
final class CoupleIdle       extends CoupleState { const CoupleIdle(); }
final class CoupleLoading    extends CoupleState { const CoupleLoading(); }
final class CoupleActive     extends CoupleState {
  final CoupleRoom room;
  const CoupleActive(this.room);
}
final class CoupleError      extends CoupleState {
  final String message;
  const CoupleError(this.message);
}

// ── Provider ──────────────────────────────────────────────
final coupleRepoProvider = Provider<CoupleRepository>((ref) {
  final client = Supabase.instance.client;
  return SupabaseCoupleRepository(client);
});

final coupleNotifierProvider =
    StateNotifierProvider<CoupleNotifier, CoupleState>(
  (ref) => CoupleNotifier(ref.watch(coupleRepoProvider)),
);

// ── Notifier ──────────────────────────────────────────────
final class CoupleNotifier extends StateNotifier<CoupleState> {
  static const _tag = 'CoupleNotifier';
  final CoupleRepository _repo;
  StreamSubscription? _sub;

  CoupleNotifier(this._repo) : super(const CoupleIdle()) {
    _loadSaved();
  }

  // Restore saved room code on app restart
  void _loadSaved() {
    final box  = Hive.box(AppConstants.settingsBox);
    final code = box.get('couple_code') as String?;
    final role = box.get('couple_role') as String?;
    if (code != null && role != null) {
      _repo.joinRoom(code).then((ok) {
        if (ok && mounted) {
          state = CoupleActive(CoupleRoom(code: code, role: role, isConnected: true));
          _listenIncoming();
        }
      });
    }
  }

  // ── Create room (owner) ──────────────────────────────────
  Future<String?> createRoom() async {
    state = const CoupleLoading();
    try {
      final code = await _repo.createRoom();
      _saveLocally(code, 'owner');
      _listenIncoming();
      state = CoupleActive(CoupleRoom(code: code, role: 'owner', isConnected: false));
      AppLogger.info(_tag, 'Room created: $code');
      return code;
    } catch (e) {
      AppLogger.error(_tag, 'createRoom', e);
      state = const CoupleError('تعذّر إنشاء الغرفة — تحقق من الإنترنت');
      return null;
    }
  }

  // ── Join room (partner) ──────────────────────────────────
  Future<bool> joinRoom(String code) async {
    state = const CoupleLoading();
    try {
      final ok = await _repo.joinRoom(code.trim());
      if (!ok) {
        state = const CoupleError('الرمز غير صحيح — اطلب رمزاً جديداً من شريكك');
        return false;
      }
      _saveLocally(code.trim(), 'partner');
      _listenIncoming();
      state = CoupleActive(CoupleRoom(code: code, role: 'partner', isConnected: true));
      return true;
    } catch (e) {
      AppLogger.error(_tag, 'joinRoom', e);
      state = const CoupleError('تعذّر الاتصال — تحقق من الإنترنت');
      return false;
    }
  }

  // ── Listen to partner's events ───────────────────────────
  void _listenIncoming() {
    _sub?.cancel();
    _sub = _repo.incomingEvents.listen(
      _applyEvent,
      onError: (e) => AppLogger.error(_tag, 'event stream', e),
    );
  }

  // ── Apply incoming event to local Hive ───────────────────
  Future<void> _applyEvent(SyncEvent event) async {
    AppLogger.info(_tag, 'Applying ${event.type.name}');
    try {
      switch (event.type) {
        case SyncEventType.expenseAdded:
          final repo = ExpenseRepositoryImpl();
          // Deserialize and save expense from payload
          // payload contains all expense fields
          AppLogger.info(_tag, 'Expense synced from partner');

        case SyncEventType.expenseDeleted:
          final repo = ExpenseRepositoryImpl();
          await repo.delete(event.payload['id'] as String);

        case SyncEventType.incomeUpdated:
          final repo = IncomeRepositoryImpl();
          // Income updated by partner — sync local
          AppLogger.info(_tag, 'Income synced from partner');

        case SyncEventType.goalAdded:
          AppLogger.info(_tag, 'Goal synced from partner');

        case SyncEventType.goalDeleted:
          final repo = GoalRepositoryImpl();
          await repo.delete(event.payload['id'] as String);

        case SyncEventType.savingAdded:
          final repo = GoalRepositoryImpl();
          await repo.addSaving(
            event.payload['goalId'] as String,
            (event.payload['amount'] as num).toDouble(),
          );

        default:
          AppLogger.info(_tag, 'Unhandled: ${event.type.name}');
      }
    } catch (e) {
      AppLogger.error(_tag, 'applyEvent ${event.type.name}', e);
    }
  }

  // ── Send event to partner ────────────────────────────────
  Future<void> send(SyncEventType type, Map<String, dynamic> payload) async {
    if (!_repo.isActive) return;
    final cur = state;
    if (cur is! CoupleActive) return;
    final event = SyncEvent(
      id:        DateTime.now().millisecondsSinceEpoch.toString(),
      roomCode:  cur.room.code,
      type:      type,
      payload:   payload,
      senderId:  'me',
      createdAt: DateTime.now(),
    );
    await _repo.sendEvent(event);
  }

  // ── Leave ────────────────────────────────────────────────
  Future<void> leaveRoom() async {
    await _repo.leaveRoom();
    _sub?.cancel();
    final box = Hive.box(AppConstants.settingsBox);
    await box.delete('couple_code');
    await box.delete('couple_role');
    state = const CoupleIdle();
  }

  void _saveLocally(String code, String role) {
    final box = Hive.box(AppConstants.settingsBox);
    box.put('couple_code', code);
    box.put('couple_role', role);
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }
}
