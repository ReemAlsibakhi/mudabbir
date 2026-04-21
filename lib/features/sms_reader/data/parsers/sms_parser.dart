import 'dart:math';
import '../../../sms_reader/domain/entities/bank_transaction.dart';

/// Parses Arabic bank SMS messages from major Saudi/Gulf banks
/// Handles: Alinma, Rajhi, NCB (AlAhli), Riyad, SNB, Emirates NBD, etc.
abstract final class SmsParser {

  static BankTransaction? parse(String sms, {String? sender}) {
    // Edge: empty SMS
    if (sms.trim().isEmpty) return null;

    final type   = _detectType(sms);
    final amount = _extractAmount(sms);
    if (amount == null || amount <= 0) return null;

    return BankTransaction(
      id:          _generateId(sms),
      type:        type,
      amount:      amount,
      description: _extractDescription(sms),
      merchant:    _extractMerchant(sms),
      date:        DateTime.now(),
      rawSms:      sms,
    );
  }

  static TransactionType _detectType(String sms) {
    final lower = sms.toLowerCase();
    // Debit keywords (Arabic)
    if (RegExp(r'مدين|خصم|سحب|مشتريات|إنفاق|تحويل خارج').hasMatch(sms))
      return TransactionType.debit;
    // Credit keywords
    if (RegExp(r'دائن|إيداع|تحويل وارد|راتب|استرداد').hasMatch(sms))
      return TransactionType.credit;
    // English fallbacks
    if (lower.contains('debit') || lower.contains('purchase') || lower.contains('withdrawal'))
      return TransactionType.debit;
    if (lower.contains('credit') || lower.contains('deposit') || lower.contains('salary'))
      return TransactionType.credit;
    return TransactionType.unknown;
  }

  static double? _extractAmount(String sms) {
    // Pattern 1: "مبلغ 245.00 ريال" or "SAR 245.00"
    final patterns = [
      RegExp(r'(?:مبلغ|قيمة|بمبلغ)\s*([\d,٠-٩]+(?:[.,][\d٠-٩]+)?)\s*(?:ريال|SAR|درهم|AED|دينار)?'),
      RegExp(r'(?:SAR|ريال|AED|درهم)\s*([\d,]+(?:\.\d+)?)'),
      RegExp(r'([\d,٠-٩]+(?:[.,][\d٠-٩]{2}))\s*(?:ريال|SAR)'),
    ];

    for (final p in patterns) {
      final m = p.firstMatch(sms);
      if (m != null) {
        final raw = m.group(1)!
            .replaceAll(',', '')
            .replaceAllMapped(RegExp(r'[٠-٩]'),
              (x) => (x.group(0)!.codeUnitAt(0) - 0x0660).toString());
        return double.tryParse(raw);
      }
    }
    return null;
  }

  static String _extractMerchant(String sms) {
    // Pattern: "لدى MERCHANT_NAME" or "at MERCHANT"
    final m = RegExp(r'(?:لدى|عند|at|@)\s*([^\n،,]+)').firstMatch(sms);
    if (m != null) return m.group(1)!.trim();

    // Pattern: after POS/ATM keywords
    final pos = RegExp(r'(?:POS|ATM|نقاط البيع)\s*-?\s*([^\n،,]+)').firstMatch(sms);
    if (pos != null) return pos.group(1)!.trim();

    return 'غير محدد';
  }

  static String _extractDescription(String sms) {
    // Truncate to first 60 chars of clean text
    return sms.replaceAll(RegExp(r'\s+'), ' ').trim().substring(0, min(60, sms.length));
  }

  static String _generateId(String sms) =>
      '${DateTime.now().millisecondsSinceEpoch}_${sms.hashCode.abs()}';

  /// Suggest expense category from merchant/description
  static String suggestCategory(String merchant, String description) {
    final text = '$merchant $description'.toLowerCase();

    if (RegExp(r'مطعم|برجر|كافيه|بيتزا|ماكدو|kfc|coffee|cafe|restaurant').hasMatch(text))
      return 'restaurants';
    if (RegExp(r'بقالة|لولو|كارفور|سوبر|hypermarket|grocery|tamimi').hasMatch(text))
      return 'food';
    if (RegExp(r'كهرباء|ماء|اتصالات|موبايلي|stc|zain|utility').hasMatch(text))
      return 'utilities';
    if (RegExp(r'أوبر|كريم|باص|حافلة|uber|careem|taxi|transport').hasMatch(text))
      return 'transport';
    if (RegExp(r'صيدلية|مستشفى|عيادة|pharmacy|hospital|clinic').hasMatch(text))
      return 'health';
    if (RegExp(r'تعليم|مدرسة|جامعة|school|university|education').hasMatch(text))
      return 'education';

    return 'other';
  }
}
