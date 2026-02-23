import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../core/constants/app_constants.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await _showLocalNotification(message);
}

Future<void> _showLocalNotification(RemoteMessage message) async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const androidDetails = AndroidNotificationDetails(
    'tango_live_channel',
    'Tango Live Notifications',
    channelDescription: 'Notifications from Tango Live',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );
  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  const notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title ?? '',
    message.notification?.body ?? '',
    notificationDetails,
    payload: message.data.toString(),
  );
}

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> initialize() async {
    await _requestPermission();
    await _initLocalNotifications();
    await _setupForegroundHandler();
    await _setupMessageOpenedHandler();
    await _saveFcmToken();
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'tango_live_channel',
        'General Notifications',
        description: 'General app notifications',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        'gifts_channel',
        'Gift Notifications',
        description: 'Notifications when you receive gifts',
        importance: Importance.max,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'stream_channel',
        'Stream Notifications',
        description: 'Notifications when followed streamers go live',
        importance: Importance.high,
      ),
    ];

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    for (final channel in channels) {
      await androidPlugin?.createNotificationChannel(channel);
    }
  }

  Future<void> _setupForegroundHandler() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showLocalNotification(message);
    });
  }

  Future<void> _setupMessageOpenedHandler() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data);
    });
  }

  Future<void> _saveFcmToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      final box = Hive.box(AppConstants.settingsBox);
      await box.put(AppConstants.fcmTokenKey, token);
    }

    _messaging.onTokenRefresh.listen((newToken) {
      Hive.box(AppConstants.settingsBox).put(AppConstants.fcmTokenKey, newToken);
    });
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {}
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'];
    final targetId = data['targetId'];

    switch (type) {
      case 'stream_live':
        Get.toNamed('/watch/$targetId');
        break;
      case 'gift_received':
        Get.toNamed('/wallet');
        break;
      case 'follow':
        Get.toNamed('/user/$targetId');
        break;
      case 'message':
        Get.toNamed('/dm/$targetId');
        break;
      default:
        break;
    }
  }

  Future<void> showGiftNotification({
    required String senderName,
    required String giftName,
    required double value,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'gifts_channel',
      'Gift Notifications',
      channelDescription: 'Notifications when you receive gifts',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      '🎁 New Gift!',
      '$senderName sent you $giftName worth $value coins',
      notificationDetails,
    );
  }

  Future<String?> getFcmToken() async {
    return _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
