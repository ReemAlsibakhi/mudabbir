import 'package:intl/intl.dart';

extension DoubleExt on double {
  /// 12345.6 → "12,345" 
  String toAr() => NumberFormat('#,##0.##', 'ar').format(this);

  /// مع العملة: "12,345 ريال"
  String toCurrency(String currency) => '${toAr()} $currency';

  /// نسبة: 0.45 → "45.0%"
  String toPercent([int decimals = 1]) =>
      '${(this * 100).toStringAsFixed(decimals)}%';
}

extension DoubleNullExt on double? {
  double get orZero => this ?? 0.0;
}
