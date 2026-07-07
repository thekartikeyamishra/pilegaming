import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import '../models/game.dart';
import 'store.dart';

/// ------------------------------------------------------------------
/// DEALS TOOLBOX — same non-predatory constitution as the portfolio:
/// "PARTNER LINK" labeled before the tap (FTC / ASCI), one screen,
/// nothing gated. Gaming-specific hard rule: AUTHORIZED retailers only
/// (their own affiliate programs) — no gray-market key resellers, whose
/// keys are often bought with stolen cards; promoting them fails your
/// "nothing immoral/scam" bar and invites chargeback-fraud adjacency.
/// Fill `url` with approved affiliate links; empty rows don't render.
/// ------------------------------------------------------------------
class ToolboxItem {
  final String category;
  final String name;
  final String pitch;
  final String url;
  final bool isPartner;
  const ToolboxItem(this.category, this.name, this.pitch, this.url,
      {this.isPartner = true});
}

class Toolbox {
  static const items = <ToolboxItem>[
    ToolboxItem('PC deals', 'Humble Bundle',
        'Authorized keys; bundles fund charity.', ''),
    ToolboxItem('PC deals', 'Fanatical',
        'Authorized reseller with deep sale rotations.', ''),
    ToolboxItem('PC deals', 'Green Man Gaming',
        'Authorized keys, frequent pre-order discounts.', ''),
    ToolboxItem('Consoles & gift cards', 'Amazon',
        'PSN/Xbox/eShop credit and hardware.', ''),
    ToolboxItem('Price history', 'IsThereAnyDeal / DekuDeals',
        'Check the historical low before you buy.', '',
        isPartner: false),
  ];

  static Future<void> open(ToolboxItem item) async {
    if (item.url.isEmpty) return;
    final uri = Uri.parse(item.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Release-day countdown notifications for Hype entries: 7 days out + day of.
/// Nothing else — no engagement spam, ever.
class Notify {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios));
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
      for (final (days, msg) in [
        (7, 'One week out. Funded: '),
        (0, 'Release day! Funded: ')
      ]) {
        final at = tz.TZDateTime.from(
            DateTime(h.releaseDate.year, h.releaseDate.month,
                    h.releaseDate.day, 10)
                .subtract(Duration(days: days)),
            tz.local);
        if (at.isBefore(tz.TZDateTime.now(tz.local))) continue;
        final pct = h.targetPrice == 0
            ? 100
            : ((h.saved / h.targetPrice) * 100).clamp(0, 100).round();
        await _plugin.zonedSchedule(
          id++,
          h.title,
          '$msg$pct%.',
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
