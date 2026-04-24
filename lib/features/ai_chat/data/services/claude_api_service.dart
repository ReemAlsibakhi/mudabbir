import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/chat_message.dart';

const _kApiUrl  = 'https://api.anthropic.com/v1/messages';
const _kModel   = 'claude-haiku-4-5-20251001';
const _kMaxTok  = 1024;
const _kTimeout = Duration(seconds: 30);

final class ClaudeApiService {
  static const _tag = 'ClaudeAPI';
  final String _apiKey;
  ClaudeApiService(this._apiKey);

  Future<Result<String>> send({
    required List<ChatMessage> history,
    required String            userMessage,
    required String            systemPrompt,
  }) async {
    // Edge: empty message
    if (userMessage.trim().isEmpty)
      return const Fail(ValidationFailure('الرسالة فارغة'));

    // Edge: missing API key
    if (_apiKey.isEmpty)
      return const Fail(ValidationFailure('مفتاح API غير مضبوط'));

    try {
      final messages = [
        // Last 10 messages only — token control
        ..._lastN(history, 10).map((m) => {
          'role':    m.isUser ? 'user' : 'assistant',
          'content': m.content,
        }),
        {'role': 'user', 'content': userMessage.trim()},
      ];

      final response = await http.post(
        Uri.parse(_kApiUrl),
        headers: {
          'Content-Type':      'application/json',
          'x-api-key':         _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model':      _kModel,
          'max_tokens': _kMaxTok,
          'system':     systemPrompt,
          'messages':   messages,
        }),
      ).timeout(_kTimeout);

      // Edge: non-200 response
      if (response.statusCode != 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final msg  = body['error']?['message'] as String? ?? 'خطأ من الخادم (${response.statusCode})';
        AppLogger.error(_tag, 'API error $msg');
        return Fail(UnexpectedFailure(_arabicError(response.statusCode, msg)));
      }

      final body = jsonDecode(utf8.decode(response.bodyBytes));
      // Edge: unexpected response shape
      final content = body['content'];
      if (content == null || content is! List || content.isEmpty)
        return const Fail(UnexpectedFailure('رد غير متوقع من الخادم'));

      final text = content[0]['text'] as String? ?? '';
      if (text.trim().isEmpty)
        return const Fail(UnexpectedFailure('استلمنا رداً فارغاً'));

      return Success(text.trim());

    } on http.ClientException catch (e) {
      AppLogger.error(_tag, 'Network error', e);
      return const Fail(UnexpectedFailure('تعذّر الاتصال بالإنترنت — تحقق من الشبكة'));
    } catch (e, st) {
      AppLogger.error(_tag, 'Unexpected error', e, st);
      // Edge: timeout
      if (e.toString().contains('TimeoutException'))
        return const Fail(UnexpectedFailure('انتهت مهلة الاتصال — حاول مرة أخرى'));
      return Fail(UnexpectedFailure(e.toString()));
    }
  }

  String _arabicError(int code, String msg) => switch (code) {
    401  => 'مفتاح API غير صالح — تحقق من الإعدادات',
    429  => 'تم تجاوز حد الطلبات — انتظر دقيقة وحاول مجدداً',
    500  => 'خطأ في خادم Claude — حاول لاحقاً',
    503  => 'الخدمة غير متاحة مؤقتاً',
    _    => msg,
  };

  List<T> _lastN<T>(List<T> list, int n) =>
      list.length <= n ? list : list.sublist(list.length - n);
}
