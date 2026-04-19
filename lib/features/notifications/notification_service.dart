// ═══════════════════════════════════════════════════════════
// NotificationService — All cases handled
// ═══════════════════════════════════════════════════════════

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../core/utils/logger.dart';

abstract final class NotificationService {
  static const _tag = 'NotificationService';

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return; // Edge: prevent double init

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    try {
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: _onTap,
      );
      _initialized = true;
      AppLogger.info(_tag, 'Initialized ✅');
    } catch (e, st) {
      AppLogger.error(_tag, 'Init failed', e, st);
      // Edge: non-fatal — app works without notifications
    }
  }

  // ── Request Permission ────────────────────────────────

  static Future<bool> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      AppLogger.info(_tag, 'Permission granted: $granted');
      return granted ?? false;
    } catch (e) {
      AppLogger.error(_tag, 'Permission request failed', e);
      return false; // Edge: not fatal
    }
  }

  // ── Schedule Morning Brief (daily 9:00 AM) ────────────

  static Future<void> scheduleMorningBrief({
    required String userName,
    required double budgetRemaining,
    required String currency,
  }) async {
    if (!_initialized) return;
    // Edge: empty name
    final name = userName.isNotEmpty ? userName : 'صديقي';

    try {
      await _plugin.zonedSchedule(
        NotifId.morning,
        'مدبّر 💰',
        'صباح الخير يا $name! المتاح اليوم: '
        '${budgetRemaining.toStringAsFixed(0)} $currency',
        _nextTime(9, 0),
        _details('morning', 'إشعار الصباح'),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      AppLogger.info(_tag, 'Morning brief scheduled');
    } catch (e) {
      AppLogger.error(_tag, 'scheduleMorningBrief failed', e);
    }
  }

  // ── Schedule Evening Summary (daily 9:00 PM) ─────────

  static Future<void> scheduleEveningSummary({
    required String userName,
  }) async {
    if (!_initialized) return;
    final name = userName.isNotEmpty ? userName : 'صديقي';

    try {
      await _plugin.zonedSchedule(
        NotifId.evening,
        'مدبّر 🌙',
        'كيف كان يومك يا $name؟ سجّل مصاريفك الآن في 30 ثانية',
        _nextTime(21, 0),
        _details('evening', 'ملخص المساء'),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      AppLogger.error(_tag, 'scheduleEveningSummary failed', e);
    }
  }

  // ── Budget Alert (immediate, > 80%) ──────────────────

  static Future<void> showBudgetAlert({
    required String category,
    required double usedPct,
  }) async {
    if (!_initialized) return;
    if (usedPct < 80) return; // Edge: only show when > 80%

    try {
      await _plugin.show(
        NotifId.budgetAlert,
        '⚠️ تنبيه ميزانية',
        'استنفدت ${usedPct.toStringAsFixed(0)}% من ميزانية $category',
        _details('budget_alert', 'تنبيهات الميزانية', importance: Importance.max),
      );
    } catch (e) {
      AppLogger.error(_tag, 'showBudgetAlert failed', e);
    }
  }

  // ── Streak At Risk (8:00 PM if no log today) ─────────

  static Future<void> showStreakAlert(int streakCount) async {
    if (!_initialized) return;
    if (streakCount == 0) return; // Edge: no streak = no alert

    try {
      await _plugin.show(
        NotifId.streak,
        '🔥 سلسلتك في خطر!',
        'لا تكسر سلسلتك الـ $streakCount يوم! سجّل في 30 ثانية',
        _details('streak', 'تنبيه السلسلة'),
      );
    } catch (e) {
      AppLogger.error(_tag, 'showStreakAlert failed', e);
    }
  }

  // ── Fixed Expense Due (3 days before) ────────────────

  static Future<void> scheduleFixedExpenseReminder({
    required String expenseName,
    required double amount,
    required String currency,
    required DateTime dueDate,
  }) async {
    if (!_initialized) return;
    // Edge: due date in past
    if (dueDate.isBefore(DateTime.now())) return;

    try {
      final remindAt = dueDate.subtract(const Duration(days: 3));
      if (remindAt.isBefore(DateTime.now())) return; // Edge: too close

      await _plugin.zonedSchedule(
        NotifId.fixedExpense,
        '📅 موعد سداد قادم',
        '$expenseName ($amount $currency) موعده بعد 3 أيام',
        tz.TZDateTime.from(remindAt, tz.local),
        _details('fixed_expense', 'مواعيد السداد'),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      AppLogger.error(_tag, 'scheduleFixedExpenseReminder failed', e);
    }
  }

  // ── Cancel ────────────────────────────────────────────

  static Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
      AppLogger.info(_tag, 'All notifications cancelled');
    } catch (e) {
      AppLogger.error(_tag, 'cancelAll failed', e);
    }
  }

  static Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      AppLogger.error(_tag, 'cancel $id failed', e);
    }
  }

  // ── Helpers ───────────────────────────────────────────

  static tz.TZDateTime _nextTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static NotificationDetails _details(
    String channelId,
    String channelName, {
    Importance importance = Importance.high,
  }) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId, channelName,
          importance: importance,
          priority:   Priority.high,
          icon:       '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  static void _onTap(NotificationResponse response) {
    AppLogger.info(_tag, 'Notification tapped: ${response.id}');
    // In real app: navigate to relevant screen
  }
}

// ── Notification IDs ──────────────────────────────────────
abstract final class NotifId {
  static const int morning      = 1;
  static const int evening      = 2;
  static const int budgetAlert  = 3;
  static const int streak       = 4;
  static const int fixedExpense = 5;
}
