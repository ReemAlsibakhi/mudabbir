// ═══════════════════════════════════════════════════════════
// SupabaseCoupleRepository — real-time couple sync via Supabase
//
// SETUP (one time, 2 minutes):
// 1. Go to supabase.com → New project (free)
// 2. SQL Editor → run: (SQL in SETUP_SUPABASE.md)
// 3. Settings → API → copy URL + anon key
// 4. Paste into lib/core/constants/app_constants.dart
// ═══════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/couple_room.dart';
import '../../domain/repositories/couple_repository.dart';

final class SupabaseCoupleRepository implements CoupleRepository {
  static const _tag      = 'CoupleRepo';
  static const _table    = 'sync_events';
  static const _roomsTab = 'couple_rooms';

  final SupabaseClient _client;
  CoupleRoom?          _room;
  StreamController<SyncEvent>? _ctrl;
  RealtimeChannel?     _channel;

  SupabaseCoupleRepository(this._client);

  @override CoupleRoom? get currentRoom => _room;
  @override bool get isActive => _room != null;

  // ── Create room ────────────────────────────────────────
  @override
  Future<String> createRoom() async {
    final code     = _randomCode();
    final deviceId = _deviceId();

    await _client.from(_roomsTab).insert({
      'code':       code,
      'owner_id':   deviceId,
      'created_at': DateTime.now().toIso8601String(),
    });

    _room = CoupleRoom(code: code, role: 'owner');
    await _subscribe(code, deviceId);
    AppLogger.info(_tag, 'Room created: $code');
    return code;
  }

  // ── Join room ──────────────────────────────────────────
  @override
  Future<bool> joinRoom(String code) async {
    final trimmed = code.trim().toUpperCase();
    final deviceId = _deviceId();

    // Verify room exists
    final rows = await _client
        .from(_roomsTab)
        .select()
        .eq('code', trimmed)
        .limit(1);

    if ((rows as List).isEmpty) {
      AppLogger.warn(_tag, 'Room $trimmed not found');
      return false;
    }

    _room = CoupleRoom(code: trimmed, role: 'partner', isConnected: true);
    await _subscribe(trimmed, deviceId);
    AppLogger.info(_tag, 'Joined room: $trimmed');
    return true;
  }

  // ── Subscribe to realtime events ───────────────────────
  Future<void> _subscribe(String code, String deviceId) async {
    _ctrl    = StreamController<SyncEvent>.broadcast();
    _channel = _client.channel('couple:$code');

    _channel!
      .onPostgresChanges(
        event:  PostgresChangeEvent.insert,
        schema: 'public',
        table:  _table,
        filter: PostgresChangeFilter(
          type:   FilterType.eq,
          column: 'room_code',
          value:  code,
        ),
        callback: (payload) {
          final newRow = payload.newRecord;
          // Ignore our own events
          if (newRow['sender_id'] == deviceId) return;
          try {
            final event = SyncEvent.fromJson(newRow);
            _ctrl?.add(event);
            AppLogger.info(_tag, 'Received: ${event.type.name}');
          } catch (e) {
            AppLogger.error(_tag, 'Parse event', e);
          }
        },
      )
      .subscribe();

    _room = _room?.copyWith(isConnected: true);
  }

  // ── Send event ─────────────────────────────────────────
  @override
  Future<void> sendEvent(SyncEvent event) async {
    if (!isActive) return;
    try {
      await _client.from(_table).insert(event.toJson());
      AppLogger.info(_tag, 'Sent: ${event.type.name}');
    } catch (e) {
      AppLogger.error(_tag, 'Send event', e);
    }
  }

  // ── Stream ─────────────────────────────────────────────
  @override
  Stream<SyncEvent> get incomingEvents =>
      _ctrl?.stream ?? const Stream.empty();

  // ── Leave room ─────────────────────────────────────────
  @override
  Future<void> leaveRoom() async {
    await _channel?.unsubscribe();
    await _ctrl?.close();
    _ctrl    = null;
    _channel = null;
    _room    = null;
    AppLogger.info(_tag, 'Left room');
  }

  // ── Helpers ────────────────────────────────────────────
  String _randomCode() {
    final r = Random.secure();
    return List.generate(6, (_) => r.nextInt(10)).join();
  }

  String _deviceId() {
    // In production: use device_info_plus for real device ID
    // For now: use a stable random stored in Hive settingsBox
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }
}
