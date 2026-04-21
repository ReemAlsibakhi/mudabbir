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

  final ClaudeApiService _api;
  ChatRepositoryImpl(this._api);

  Box get _box => Hive.box(AppConstants.settingsBox);

  @override
  Future<Result<ChatMessage>> send({
    required List<ChatMessage> history,
    required String userMessage,
    required String financialContext,
  }) async {
    final result = await _api.sendMessage(
      history:      history,
      userMessage:  userMessage,
      systemPrompt: _buildSystemPrompt(financialContext),
    );

    return result.map((text) => ChatMessage(
      id:        DateTime.now().millisecondsSinceEpoch.toString(),
      role:      MessageRole.assistant,
      content:   text,
      createdAt: DateTime.now(),
    ));
  }

  // ── System prompt with financial context ────────────────
  String _buildSystemPrompt(String financialContext) => '''
أنت مستشار مالي ذكي في تطبيق "مدبّر" للعائلات العربية.
تتحدث العربية الفصحى البسيطة المفهومة.

السياق المالي للمستخدم:
$financialContext

قواعدك:
1. إجاباتك قصيرة ومباشرة (3-5 جمل كحد أقصى)
2. لا تعطي أرقاماً محددة بدون بيانات المستخدم
3. نصائحك عملية وقابلة للتطبيق فوراً
4. استخدم أرقام المستخدم الحقيقية في ردودك
5. لا تكرر نفس النصيحة مرتين
6. إذا لم تعرف، قل "لا أملك معلومات كافية"
''';

  @override
  Future<void> saveHistory(List<ChatMessage> messages) async {
    try {
      final json = messages.map((m) => {
        'id': m.id, 'role': m.role.name,
        'content': m.content,
        'createdAt': m.createdAt.toIso8601String(),
        'status': m.status.name,
      }).toList();
      await _box.put(_histKey, jsonEncode(json));
    } catch (e) {
      AppLogger.error(_tag, 'saveHistory error', e);
    }
  }

  @override
  List<ChatMessage> loadHistory() {
    try {
      final raw = _box.get(_histKey);
      if (raw == null) return [];
      final list = jsonDecode(raw as String) as List;
      return list.map((m) => ChatMessage(
        id:        m['id'] as String,
        role:      MessageRole.values.firstWhere((r) => r.name == m['role'],
                     orElse: () => MessageRole.user),
        content:   m['content'] as String? ?? '',
        createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
        status:    MessageStatus.done,
      )).toList();
    } catch (e) {
      AppLogger.error(_tag, 'loadHistory error', e);
      return [];
    }
  }

  @override
  Future<void> clearHistory() async {
    await _box.delete(_histKey);
  }
}
