import '../../../../core/errors/result.dart';
import '../entities/chat_message.dart';

abstract interface class ChatRepository {
  /// Send message to Claude — returns assistant reply
  Future<Result<ChatMessage>> send({
    required List<ChatMessage> history,
    required String userMessage,
    required String financialContext,
  });

  /// Save conversation to local storage
  Future<void> saveHistory(List<ChatMessage> messages);

  /// Load saved conversation
  List<ChatMessage> loadHistory();

  /// Clear history
  Future<void> clearHistory();
}
