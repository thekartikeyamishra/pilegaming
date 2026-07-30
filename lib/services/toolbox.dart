import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'store.dart';

/// Release-day countdown notifications for Hype entries: 7 days out + day of.
class Notify {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin
        .initialize(const InitializationSettings(android: android, iOS: ios));
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _ready = true;
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails('pile_hype', 'Release countdowns',
        channelDescription: 'Reminders for releases you\'re tracking',
        importance: Importance.defaultImportance),
    iOS: DarwinNotificationDetails(),
  );

  static Future<void> rescheduleAll() async {
    await _init();
    await _plugin.cancelAll();

    var id = 10;

    for (final h in PileStore.instance.hype) {
      final pct = h.targetPrice == 0
          ? 100
          : ((h.saved / h.targetPrice) * 100).clamp(0, 100).round();

      for (final days in [7, 0]) {
        final at = tz.TZDateTime.from(
            DateTime(h.releaseDate.year, h.releaseDate.month, h.releaseDate.day,
                    10)
                .subtract(Duration(days: days)),
            tz.local);

        if (at.isBefore(tz.TZDateTime.now(tz.local))) continue;

        String message;
        if (days == 7) {
          if (pct >= 100) {
            message = 'One week out! You are fully funded and ready to play.';
          } else {
            message =
                'One week out! You are $pct% funded. Keep saving to hit your goal!';
          }
        } else {
          if (pct >= 100) {
            message = 'Release day is here! Fully funded—enjoy the outcome!';
          } else {
            message =
                'Release day is here! You successfully saved $pct% of your goal.';
          }
        }

        await _plugin.zonedSchedule(
          id++,
          h.title,
          message,
          at,
          _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }
}
