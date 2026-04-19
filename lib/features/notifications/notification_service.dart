import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../core/utils/logger.dart';

abstract final class NotificationService {
  static const _tag = 'NotificationService';
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    AppLogger.info(_tag, 'Initialized');
  }

  // ── Schedule morning brief ────────────────────────────
  static Future<void> scheduleMorningBrief(String userName) async {
    try {
      await _plugin.zonedSchedule(
        1, 'مدبّر 💰', 'صباح الخير يا $userName! تحقق من ميزانيتك اليوم',
        _nextTime(9, 0),
        const NotificationDetails(
          android: AndroidNotificationDetails('morning', 'إشعار الصباح',
            importance: Importance.high, priority: Priority.high),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      AppLogger.error(_tag, 'scheduleMorningBrief error', e);
    }
  }

  // ── Schedule evening summary ──────────────────────────
  static Future<void> scheduleEveningSummary(String userName) async {
    try {
      await _plugin.zonedSchedule(
        2, 'مدبّر 🌙', 'كيف كان يومك يا $userName؟ سجّل مصاريفك الآن',
        _nextTime(21, 0),
        const NotificationDetails(
          android: AndroidNotificationDetails('evening', 'ملخص المساء',
            importance: Importance.high, priority: Priority.high),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      AppLogger.error(_tag, 'scheduleEveningSummary error', e);
    }
  }

  // ── Budget 80% alert ──────────────────────────────────
  static Future<void> showBudgetAlert(String category, double pct) async {
    try {
      await _plugin.show(
        3, '⚠️ تنبيه ميزانية',
        'استنفدت ${pct.toStringAsFixed(0)}% من ميزانية $category',
        const NotificationDetails(
          android: AndroidNotificationDetails('budget', 'تنبيهات الميزانية',
            importance: Importance.max),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      AppLogger.error(_tag, 'showBudgetAlert error', e);
    }
  }

  // ── Streak at risk ────────────────────────────────────
  static Future<void> showStreakAlert(int count) async {
    if (count == 0) return; // Edge: no streak to protect
    try {
      await _plugin.show(
        4, '🔥 سلسلتك في خطر!',
        'لا تكسر سلسلتك الـ $count يوم! سجّل مصاريفك الآن',
        const NotificationDetails(
          android: AndroidNotificationDetails('streak', 'تنبيه السلسلة',
            importance: Importance.high),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      AppLogger.error(_tag, 'showStreakAlert error', e);
    }
  }

  // ── Fixed expense due ────────────────────────────────
  static Future<void> showDueAlert(String name, double amount, int daysLeft) async {
    try {
      final when = daysLeft == 0 ? 'اليوم' : 'بعد $daysLeft أيام';
      await _plugin.show(
        5, '📅 موعد دفع قريب',
        '$name ($amount) — موعده $when',
        const NotificationDetails(
          android: AndroidNotificationDetails('due', 'مواعيد الدفع',
            importance: Importance.high),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      AppLogger.error(_tag, 'showDueAlert error', e);
    }
  }

  static Future<void> cancelAll() async {
    try { await _plugin.cancelAll(); } catch (e) {
      AppLogger.error(_tag, 'cancelAll error', e);
    }
  }

  static tz.TZDateTime _nextTime(int hour, int minute) {
    final now       = tz.TZDateTime.now(tz.local);
    var   scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    // Edge: if time already passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    return scheduled;
  }
}
