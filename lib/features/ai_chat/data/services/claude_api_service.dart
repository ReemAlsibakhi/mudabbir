// ═══════════════════════════════════════════════════════════
// ClaudeApiService — Anthropic claude-haiku-4-5
// ═══════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/chat_message.dart';

const _apiUrl = 'https://api.anthropic.com/v1/messages';
const _model  = 'claude-haiku-4-5-20251001';

final class ClaudeApiService {
  static const _tag = 'ClaudeAPI';

  final String _apiKey;
  ClaudeApiService(this._apiKey);

  Future<Result<String>> sendMessage({
    required List<ChatMessage> history,
    required String            userMessage,
    required String            systemPrompt,
  }) async {
    // Edge: empty message
    if (userMessage.trim().isEmpty)
      return const Fail(ValidationFailure('الرسالة فارغة'));

    // Edge: no API key
    if (_apiKey.isEmpty)
      return const Fail(ValidationFailure('مفتاح API غير موجود'));

    try {
      final messages = [
        // Include chat history (max last 10 messages to control tokens)
        ...history.takeLast(10).map((m) => {
          'role':    m.isUser ? 'user' : 'assistant',
          'content': m.content,
        }),
        {'role': 'user', 'content': userMessage},
      ];

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type':      'application/json',
          'x-api-key':         _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model':      _model,
          'max_tokens': 1024,
          'system':     systemPrompt,
          'messages':   messages,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('انتهت مهلة الاتصال'),
      );

      AppLogger.info(_tag, 'Response ${response.statusCode}');

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        final err  = body['error']?['message'] ?? 'خطأ من الخادم';
        AppLogger.error(_tag, 'API error: $err');
        return Fail(UnexpectedFailure(err));
      }

      final body   = jsonDecode(response.body);
      final text   = body['content']?[0]?['text'] as String? ?? '';
      if (text.isEmpty) return const Fail(UnexpectedFailure('رد فارغ من Claude'));
      return Success(text);

    } catch (e, st) {
      AppLogger.error(_tag, 'sendMessage error', e, st);
      return Fail(UnexpectedFailure(e.toString()));
    }
  }
}

extension<T> on List<T> {
  List<T> takeLast(int n) => length <= n ? this : sublist(length - n);
}
