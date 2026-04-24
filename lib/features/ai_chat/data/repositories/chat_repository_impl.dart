import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../services/claude_api_service.dart';

final class ChatRepositoryImpl implements ChatRepository {
  static const _tag     = 'ChatRepo';
  static const _histKey = 'chat_history';
  static const _systemPrompt = '''
أنت مدبّر — مستشار مالي ذكي للعائلات العربية.
تتحدث العربية الفصحى البسيطة، إجاباتك قصيرة ومباشرة (3-5 جمل).
تستخدم أرقام المستخدم الفعلية في ردودك.
لا تكرر نفس النصيحة. إذا لم تعرف، قل ذلك بوضوح.
ركّز على الإجراءات العملية القابلة للتطبيق فوراً.
''';

  final ClaudeApiService _api;
  ChatRepositoryImpl(this._api);

  Box get _box => Hive.box(AppConstants.settingsBox);

  @override
  Future<Result<ChatMessage>> send({
    required List<ChatMessage> history,
    required String            userMessage,
    required String            financialContext,
  }) async {
    final fullPrompt = '$_systemPrompt\nبيانات المستخدم المالية:\n$financialContext';

    final result = await _api.send(
      history:      history,
      userMessage:  userMessage,
      systemPrompt: fullPrompt,
    );

    return result.map((text) => ChatMessage(
      id:        DateTime.now().millisecondsSinceEpoch.toString(),
      role:      MessageRole.assistant,
      content:   text,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<void> saveHistory(List<ChatMessage> messages) async {
    try {
      // Keep only last 50 messages to avoid bloat
      final toSave = messages.length > 50
          ? messages.sublist(messages.length - 50)
          : messages;
      final json = toSave.map((m) => {
        'id':        m.id,
        'role':      m.role.name,
        'content':   m.content,
        'createdAt': m.createdAt.toIso8601String(),
      }).toList();
      await _box.put(_histKey, jsonEncode(json));
    } catch (e) {
      AppLogger.error(_tag, 'saveHistory', e);
    }
  }

  @override
  List<ChatMessage> loadHistory() {
    try {
      final raw = _box.get(_histKey);
      if (raw == null) return [];
      final list = jsonDecode(raw as String) as List;
      return list.map((m) {
        // Edge: malformed entry → skip
        final role = MessageRole.values.firstWhere(
          (r) => r.name == (m['role'] as String? ?? ''),
          orElse: () => MessageRole.user,
        );
        return ChatMessage(
          id:        m['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          role:      role,
          content:   (m['content'] as String?) ?? '',
          createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
          status:    MessageStatus.done,
        );
      }).where((m) => m.content.isNotEmpty).toList();
    } catch (e, st) {
      AppLogger.error(_tag, 'loadHistory', e, st);
      return [];
    }
  }

  @override
  Future<void> clearHistory() async {
    try { await _box.delete(_histKey); } catch (e) {
      AppLogger.error(_tag, 'clearHistory', e);
    }
  }
}
