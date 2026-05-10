import '../entities/couple_room.dart';

abstract interface class CoupleRepository {
  /// Create a new room — returns 6-digit code
  Future<String> createRoom();

  /// Join partner's room using their 6-digit code
  Future<bool> joinRoom(String code);

  /// Leave and disconnect from room
  Future<void> leaveRoom();

  /// Send a sync event to partner's device
  Future<void> sendEvent(SyncEvent event);

  /// Stream of incoming events from partner
  Stream<SyncEvent> get incomingEvents;

  /// Current room (null = not connected)
  CoupleRoom? get currentRoom;

  /// Whether couple mode is active
  bool get isActive;
}
