import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/observability/logging_service.dart';
import '../../core/observability/metrics_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> showLocalAlert({
    required String title,
    required String body,
  }) async {
    metrics.increment('aeon.push.local_alert.shown');
    log.info('Notifications', 'showLocalAlert', extra: {'title': title});
    await _notifications.show(
      1,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alert_channel',
          'Alertas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> initialize() async {
    log.info('Notifications', 'initializing');

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await _notifications.initialize(
      const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: (details) {
        metrics.increment('aeon.push.tapped.count');
        log.info('Notifications', 'notification tapped',
            extra: {'payload': details.payload});
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      metrics.increment('aeon.push.received.foreground');
      log.info('Notifications', 'FCM foreground message', extra: {
        'title': message.notification?.title,
        'from': message.from,
      });
      _notifications.show(
        0,
        message.notification?.title,
        message.notification?.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'alert_channel',
            'Alertas',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      metrics.increment('aeon.push.tapped.count');
      log.info('Notifications', 'notification opened app',
          extra: {'title': message.notification?.title});
    });

    log.info('Notifications', 'initialized');
  }
}
