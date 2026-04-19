extension StringExt on String {
  double get toDoubleOrZero => double.tryParse(trim()) ?? 0.0;
  bool   get isNotBlank     => trim().isNotEmpty;
  bool   get isBlank        => trim().isEmpty;
  String get capitalized    => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

extension StringNullExt on String? {
  bool   get isNullOrBlank  => this == null || this!.trim().isEmpty;
  String get orEmpty        => this ?? '';
}
