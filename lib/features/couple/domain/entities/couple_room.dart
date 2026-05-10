import 'package:equatable/equatable.dart';

enum SyncEventType {
  expenseAdded, expenseDeleted,
  fixedAdded,   fixedDeleted,
  incomeUpdated,
  goalAdded,    goalDeleted,
  savingAdded,
}

final class CoupleRoom extends Equatable {
  final String code;    // 6-digit shared code
  final String role;    // 'owner' | 'partner'
  final bool   isConnected;
  const CoupleRoom({required this.code, required this.role, this.isConnected = false});

  bool get isOwner => role == 'owner';
  CoupleRoom copyWith({bool? isConnected}) =>
      CoupleRoom(code: code, role: role, isConnected: isConnected ?? this.isConnected);
  @override List<Object?> get props => [code, role, isConnected];
}

final class SyncEvent extends Equatable {
  final String id, roomCode, senderId;
  final SyncEventType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  const SyncEvent({
    required this.id, required this.roomCode, required this.type,
    required this.payload, required this.senderId, required this.createdAt,
  });

  factory SyncEvent.fromJson(Map<String, dynamic> j) => SyncEvent(
    id:        j['id'] as String,
    roomCode:  j['room_code'] as String,
    type:      SyncEventType.values.firstWhere(
      (e) => e.name == j['event_type'], orElse: () => SyncEventType.expenseAdded),
    payload:   Map<String, dynamic>.from(j['payload'] as Map),
    senderId:  j['sender_id'] as String,
    createdAt: DateTime.parse(j['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'room_code': roomCode, 'event_type': type.name,
    'payload': payload, 'sender_id': senderId,
    'created_at': createdAt.toIso8601String(),
  };
  @override List<Object?> get props => [id, roomCode, type, senderId];
}
