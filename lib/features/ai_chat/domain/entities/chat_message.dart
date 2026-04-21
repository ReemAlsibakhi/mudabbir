import 'package:equatable/equatable.dart';

enum MessageRole { user, assistant }
enum MessageStatus { sending, done, error }

final class ChatMessage extends Equatable {
  final String        id;
  final MessageRole   role;
  final String        content;
  final DateTime      createdAt;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.status = MessageStatus.done,
  });

  bool get isUser      => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
  bool get isLoading   => status == MessageStatus.sending;
  bool get hasError    => status == MessageStatus.error;

  ChatMessage copyWith({String? content, MessageStatus? status}) => ChatMessage(
    id: id, role: role, createdAt: createdAt,
    content: content ?? this.content,
    status:  status  ?? this.status,
  );

  factory ChatMessage.user(String content) => ChatMessage(
    id:        DateTime.now().millisecondsSinceEpoch.toString(),
    role:      MessageRole.user,
    content:   content,
    createdAt: DateTime.now(),
  );

  factory ChatMessage.loading() => ChatMessage(
    id:        'loading',
    role:      MessageRole.assistant,
    content:   '',
    createdAt: DateTime.now(),
    status:    MessageStatus.sending,
  );

  factory ChatMessage.error(String msg) => ChatMessage(
    id:        DateTime.now().millisecondsSinceEpoch.toString(),
    role:      MessageRole.assistant,
    content:   msg,
    createdAt: DateTime.now(),
    status:    MessageStatus.error,
  );

  @override
  List<Object?> get props => [id, role, content, status];
}
