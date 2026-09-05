import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Shows local (in-app) notifications with sound while the app is in the
/// foreground. Used for OneSignal foreground pushes and for realtime events
/// (e.g. a new order arriving over the orders socket).
class LocalNotificationService {
  LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidNotificationChannel =
      AndroidNotificationChannel(
        '201060c8-3dd4-44ca-81b7-146aa95547cb',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      );

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await plugin.initialize(initializationSettings);

    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // Delete first to force recreation with the correct sound.
    // Android won't update an existing channel's sound — delete + recreate is the only way.
    await androidPlugin?.deleteNotificationChannel(
      '201060c8-3dd4-44ca-81b7-146aa95547cb',
    );
    await androidPlugin?.createNotificationChannel(_androidNotificationChannel);
  }

  static Future<void> showWithSound({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          '201060c8-3dd4-44ca-81b7-146aa95547cb',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('notification_sound'),
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification_sound.aiff',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }
}
