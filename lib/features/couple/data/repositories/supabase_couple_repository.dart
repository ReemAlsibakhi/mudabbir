import 'dart:async';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/couple_room.dart';
import '../../domain/repositories/couple_repository.dart';

// ══════════════════════════════════════════════════════════
// LocalCoupleRepository
//
// Couple Mode without backend — uses a 6-digit shareable code.
// Real-time sync requires Supabase (configured in SETUP_SUPABASE.md).
// This implementation stores the room code locally and simulates
// the connection so the UI works correctly.
//
// To enable real-time sync: follow ios/SETUP_SUPABASE.md
// ══════════════════════════════════════════════════════════

final class SupabaseCoupleRepository implements CoupleRepository {
  static const _tag      = 'CoupleRepo';
  static const _codeKey  = 'couple_code';
  static const _roleKey  = 'couple_role';

  Box get _box => Hive.box(AppConstants.settingsBox);

  CoupleRoom?                  _room;
  final _ctrl = StreamController<SyncEvent>.broadcast();

  @override CoupleRoom? get currentRoom => _room;
  @override bool        get isActive    => _room != null;

  @override
  Future<String> createRoom() async {
    final code = _generateCode();
    await _box.put(_codeKey, code);
    await _box.put(_roleKey, 'owner');
    _room = CoupleRoom(code: code, role: 'owner', isConnected: false);
    AppLogger.info(_tag, 'Room created: $code');
    return code;
  }

  @override
  Future<bool> joinRoom(String code) async {
    final trimmed = code.trim();
    if (trimmed.length != 6) return false;
    await _box.put(_codeKey, trimmed);
    await _box.put(_roleKey, 'partner');
    _room = CoupleRoom(code: trimmed, role: 'partner', isConnected: true);
    AppLogger.info(_tag, 'Joined room: $trimmed');
    return true;
  }

  @override
  Future<void> sendEvent(SyncEvent event) async {
    // No-op without backend — events are stored locally only
    AppLogger.info(_tag, 'Event: ${event.type.name} (local only)');
  }

  @override
  Stream<SyncEvent> get incomingEvents => _ctrl.stream;

  @override
  Future<void> leaveRoom() async {
    await _box.delete(_codeKey);
    await _box.delete(_roleKey);
    _room = null;
    AppLogger.info(_tag, 'Left room');
  }

  // ── Helpers ────────────────────────────────────────────

  static String _generateCode() {
    final r = Random.secure();
    return List.generate(6, (_) => r.nextInt(10)).join();
  }
}
