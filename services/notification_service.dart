import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

// 🔥 Background Handler (Must be outside class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message received: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    // 1. Request Permission
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // 2. Local Notification Setup
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    // 🛑 FIX 1: Version 20.0.0 ke according 'settings' explicitly define karna zaroori hai
    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Notification pe tap hone ke baad ka logic yahan daal sakta hai
      },
    );

    // 3. Listen to Background & Foreground Messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (message.notification != null) {
      AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
        'admin_alerts',
        'Command Center Alerts',
        importance: Importance.max,
        priority: Priority.high,
        color: Color(0xFF00FFFF), // Cyan Neon Glow
      );

      NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

      // 🛑 FIX 2: Version 20.0.0 ke according saare parameters named ho gaye hain
      await _localNotificationsPlugin.show(
        id: Random().nextInt(100000),
        title: message.notification!.title,
        body: message.notification!.body,
        notificationDetails: notificationDetails,
      );
    }
  }

  // 🔥 Get Token to save in Database
  Future<String?> getDeviceToken() async {
    return await messaging.getToken();
  }
}