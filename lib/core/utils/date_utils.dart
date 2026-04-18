import 'package:intl/intl.dart';

class MudabbirDateUtils {
  static const List<String> monthsAr = [
    'يناير','فبراير','مارس','أبريل','مايو','يونيو',
    'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر',
  ];
  static const List<String> daysAr = [
    'الأحد','الإثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت',
  ];

  static String monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  static String todayKey() => monthKey(DateTime.now());

  static String dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String todayDateKey() => dateKey(DateTime.now());

  static String formatMonthAr(DateTime date) =>
      '${monthsAr[date.month - 1]} ${date.year}';

  static String formatDayAr(DateTime date) =>
      '${daysAr[date.weekday % 7]} ${date.day} ${monthsAr[date.month - 1]}';

  static int daysLeftInMonth() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return lastDay.day - now.day;
  }

  static double monthProgress() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    return now.day / lastDay;
  }

  static String formatAmount(double amount, String currency) {
    final formatter = NumberFormat('#,##0.##', 'ar');
    return '${formatter.format(amount)} $currency';
  }
}
