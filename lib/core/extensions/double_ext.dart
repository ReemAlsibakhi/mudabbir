import 'package:intl/intl.dart';

extension DoubleExt on double {
  String fmt()                    => NumberFormat('#,##0.##', 'ar').format(this);
  String withCurrency(String cur) => '${fmt()} $cur';
  String asPercent([int d = 1])   => '${toStringAsFixed(d)}%';
  bool   get isPositive           => this > 0;
  bool   get isNegative           => this < 0;
}

extension DoubleNullExt on double? {
  double get orZero => this ?? 0.0;
}
