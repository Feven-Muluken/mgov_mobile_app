import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mgov_apps/core/utils/local_storage_stub.dart';
import 'package:mgov_apps/features/gov_connect/core/api_service.dart';

class NotificationService {
  static FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Ask for permission, set up notification display, and keep the backend's
  /// copy of this phone's token up to date.
  static Future<void> initialize() async {
    // 1. Ask the user for permission (shows the system prompt on Android 13+ and iOS).
    final settings = await _messaging.requestPermission();
    if (kDebugMode) print("🔔 Notification permission: ${settings.authorizationStatus}");

    // Android 13+: the local-notification plugin has its own permission request.
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // 2. Configure local notifications (used to show messages while the app is open)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // 3. Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) print("📩 Foreground message: ${message.notification?.title}");

      final notification = message.notification;
      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'General Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    // 4. Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 5. Google can change the token at any time; keep the backend in sync.
    _messaging.onTokenRefresh.listen((_) => registerTokenWithBackend());
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    if (kDebugMode) print("💬 Background message: ${message.messageId}");
  }

  static Future<String?> getDeviceToken() async {
    return await _messaging.getToken();
  }

  /// Save this phone's push token on the backend for the logged-in user.
  ///
  /// Does nothing for guests, when Firebase is not ready, or when the user has
  /// not allowed notifications. Safe to call repeatedly: the backend updates the
  /// existing record for the same token.
  static Future<void> registerTokenWithBackend() async {
    try {
      final accessToken = await getFromLocalStorage('access_token');
      if (accessToken == null || accessToken.isEmpty) return; // guest / logged out
      if (Firebase.apps.isEmpty) return;

      final settings = await _messaging.getNotificationSettings();
      final allowed = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!allowed) {
        if (kDebugMode) print("🔕 Notifications not allowed; token not saved on backend.");
        return;
      }

      final token = await _messaging.getToken();
      if (token == null) return;

      String deviceType = 'android';
      String? deviceName;
      String? deviceId;
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final a = await info.androidInfo;
        deviceName = '${a.manufacturer} ${a.model}';
        deviceId = a.id;
      } else if (Platform.isIOS) {
        final i = await info.iosInfo;
        deviceType = 'ios';
        deviceName = i.name;
        deviceId = i.identifierForVendor;
      }

      final response = await ApiService().registerDeviceToken(
        token: token,
        deviceType: deviceType,
        accessToken: accessToken,
        deviceName: deviceName,
        deviceId: deviceId,
      );
      if (kDebugMode) {
        print(response.success
            ? "✅ Device token saved on backend"
            : "❌ Device token not saved: ${response.message}");
      }
    } catch (e) {
      if (kDebugMode) print("❌ registerTokenWithBackend failed: $e");
    }
  }
}
