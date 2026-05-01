import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/core/utils/arabic_parser.dart';
import 'package:mudabbir/core/errors/result.dart';

void main() {
  group('ArabicParser.normalizeDigits', () {
    test('converts Arabic digits to ASCII', () {
      expect(ArabicParser.normalizeDigits('١٢٣'), '123');
    });
    test('converts Arabic decimal separator', () {
      expect(ArabicParser.normalizeDigits('١٥٫٥'), '15.5');
    });
    test('removes Arabic thousands separator', () {
      expect(ArabicParser.normalizeDigits('١٬٠٠٠'), '1000');
    });
    test('leaves ASCII digits unchanged', () {
      expect(ArabicParser.normalizeDigits('150.5'), '150.5');
    });
    test('handles empty string', () {
      expect(ArabicParser.normalizeDigits(''), '');
    });
  });

  group('ArabicParser.parseAmount', () {
    test('parses valid ASCII amount', () {
      final r = ArabicParser.parseAmount('150');
      expect(r.isSuccess, true);
      expect(r.valueOrNull, 150.0);
    });
    test('parses Arabic digits', () {
      final r = ArabicParser.parseAmount('١٥٠');
      expect(r.isSuccess, true);
      expect(r.valueOrNull, 150.0);
    });
    test('parses decimal amount', () {
      final r = ArabicParser.parseAmount('99.99');
      expect(r.isSuccess, true);
      expect(r.valueOrNull, 99.99);
    });
    test('rejects empty string', () {
      expect(ArabicParser.parseAmount('').isFailure, true);
    });
    test('rejects zero by default', () {
      expect(ArabicParser.parseAmount('0').isFailure, true);
    });
    test('allows zero when allowZero=true', () {
      expect(ArabicParser.parseAmount('0', allowZero: true).isSuccess, true);
    });
    test('rejects negative', () {
      expect(ArabicParser.parseAmount('-50').isFailure, true);
    });
    test('rejects above max', () {
      expect(ArabicParser.parseAmount('99999999').isFailure, true);
    });
    test('rejects NaN string', () {
      expect(ArabicParser.parseAmount('abc').isFailure, true);
    });
    test('custom max respected', () {
      expect(ArabicParser.parseAmount('500', max: 100).isFailure, true);
    });
  });

  group('ArabicParser.parseOptionalAmount', () {
    test('empty = Success(0)', () {
      final r = ArabicParser.parseOptionalAmount('');
      expect(r.isSuccess, true);
      expect(r.valueOrNull, 0.0);
    });
    test('valid amount parses correctly', () {
      expect(ArabicParser.parseOptionalAmount('200').valueOrNull, 200.0);
    });
  });

  group('ArabicParser.parsePositiveInt', () {
    test('parses valid int', () {
      expect(ArabicParser.parsePositiveInt('12').valueOrNull, 12);
    });
    test('rejects zero', () {
      expect(ArabicParser.parsePositiveInt('0').isFailure, true);
    });
    test('rejects negative', () {
      expect(ArabicParser.parsePositiveInt('-3').isFailure, true);
    });
    test('parses Arabic digits', () {
      expect(ArabicParser.parsePositiveInt('٢٤').valueOrNull, 24);
    });
  });
}
