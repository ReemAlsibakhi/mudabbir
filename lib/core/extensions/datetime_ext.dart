extension DateTimeExt on DateTime {
  String get monthKey => '$year-${month.toString().padLeft(2, '0')}';
  String get dateKey  => '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  String get monthAr {
    const m = ['يناير','فبراير','مارس','أبريل','مايو','يونيو',
                'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    return '${m[month - 1]} $year';
  }

  String get dayFullAr {
    const d = ['الأحد','الإثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت'];
    const m = ['يناير','فبراير','مارس','أبريل','مايو','يونيو',
                'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    return '${d[weekday % 7]} $day ${m[month - 1]}';
  }

  bool get isToday {
    final n = DateTime.now();
    return year == n.year && month == n.month && day == n.day;
  }

  DateTime get startOfMonth => DateTime(year, month);
  DateTime get endOfMonth   => DateTime(year, month + 1, 0);
  int  get daysLeftInMonth  => endOfMonth.day - day;
  double get monthProgress  => day / endOfMonth.day;

  DateTime prevMonth() => month == 1 ? DateTime(year - 1, 12) : DateTime(year, month - 1);
  DateTime nextMonth() => month == 12 ? DateTime(year + 1, 1) : DateTime(year, month + 1);
}
