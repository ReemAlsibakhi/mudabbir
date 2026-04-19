extension StringExt on String {
  double get toDoubleOrZero => double.tryParse(this) ?? 0.0;
  bool get isNotBlank => trim().isNotEmpty;
}
