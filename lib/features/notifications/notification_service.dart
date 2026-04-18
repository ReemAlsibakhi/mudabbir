import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
  }

  // إشعار الصباح اليومي
  static Future<void> scheduleMorningBrief(String userName) async {
    await _plugin.zonedSchedule(
      1,
      'مدبّر 💰',
      'صباح الخير يا $userName! تحقق من ميزانيتك اليوم',
      _nextInstanceOfTime(9, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails('morning', 'إشعار الصباح', importance: Importance.high),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // إشعار المساء
  static Future<void> scheduleEveningSummary(String userName) async {
    await _plugin.zonedSchedule(
      2,
      'مدبّر 🌙',
      'كيف كان يومك المالي يا $userName؟ سجّل مصاريفك الآن',
      _nextInstanceOfTime(21, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails('evening', 'ملخص المساء', importance: Importance.high),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // تنبيه تجاوز الميزانية
  static Future<void> showBudgetAlert(String category, double spent, double budget) async {
    await _plugin.show(
      3,
      '⚠️ تنبيه ميزانية',
      'استنفدت ${(spent/budget*100).toStringAsFixed(0)}% من ميزانية $category',
      const NotificationDetails(
        android: AndroidNotificationDetails('budget_alert', 'تنبيهات الميزانية', importance: Importance.max),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // تنبيه خطر السلسلة
  static Future<void> showStreakAlert(int streakCount) async {
    await _plugin.show(
      4,
      '🔥 سلسلتك في خطر!',
      'لا تكسر سلسلتك الـ $streakCount يوم! سجّل مصاريفك الآن',
      const NotificationDetails(
        android: AndroidNotificationDetails('streak', 'تنبيه السلسلة', importance: Importance.high),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<void> cancelAll() async => await _plugin.cancelAll();
}
