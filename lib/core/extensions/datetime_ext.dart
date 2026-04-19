extension DateTimeExt on DateTime {
  /// "2025-04"
  String get monthKey =>
      '$year-${month.toString().padLeft(2, '0')}';

  /// "2025-04-18"
  String get dateKey =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  /// أبريل 2025
  String get monthAr {
    const months = [
      'يناير','فبراير','مارس','أبريل','مايو','يونيو',
      'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر',
    ];
    return '${months[month - 1]} $year';
  }

  /// الخميس 18 أبريل
  String get dayFullAr {
    const days = ['الأحد','الإثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت'];
    const months = [
      'يناير','فبراير','مارس','أبريل','مايو','يونيو',
      'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر',
    ];
    return '${days[weekday % 7]} $day ${months[month - 1]}';
  }

  bool get isToday {
    final n = DateTime.now();
    return year == n.year && month == n.month && day == n.day;
  }

  DateTime get startOfMonth => DateTime(year, month, 1);
  DateTime get endOfMonth   => DateTime(year, month + 1, 0);
  int get daysLeftInMonth   => endOfMonth.day - day;
}
