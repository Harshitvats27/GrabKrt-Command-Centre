// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// 🔥 Background Handler MUST be outside the class (Top Level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message received: ${message.messageId}");
}

class NotificationService {
  // Singleton pattern so we don't create multiple instances
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // 🔥 ASLI initNotifications (Jo main.dart call karega)
  Future<void> initNotifications() async {
    // 1. Request Permission
    await requestNotificationPermission();

    // 2. Setup Background Message Listener
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Setup Local Notifications (Version 20.0.0 ke according)
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Notification click hone par yahan logic aayega
        print("Notification clicked in foreground!");
      },
    );

    // 4. Listen to Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground Message Title: ${message.notification?.title}");

      if (Platform.isIOS) {
        foregroundMessage();
      }
      if (Platform.isAndroid) {
        showNotification(message);
      }
    });
  }

  // 🔔 Request Permission
  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User denied permission');
    }
  }

  // 🔑 Get FCM Token (Database mein save karne ke liye)
  Future<String?> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token;
  }

  // 🔔 Show Local Notification (Jab app open ho)
  Future<void> showNotification(RemoteMessage message) async {
    String channelId = message.notification?.android?.channelId ?? "admin_alerts";

    AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      "Command Center Alerts",
      importance: Importance.max,
    );

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: "Notifications for new orders and stock updates",
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      color: const Color(0xFF00FFFF), // Tera Neon Cyan color
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails
    );

    // Random ID taaki har notification alag dikhe (id: 0 hone se overwrite ho jati hai)
    await _flutterLocalNotificationsPlugin.show(
      id: Random().nextInt(100000),
      title: message.notification?.title ?? "No Title",
      body: message.notification?.body ?? "No Body",
      notificationDetails: details,
    );
  }

  // 🍏 iOS Foreground Settings
  Future foregroundMessage() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // 🔄 Handle Click (Background / Terminated - Can be called from Splash Screen)
  Future<void> setupInteractMessage(BuildContext context) async {
    // App terminated
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        handleMessage(context, message);
      }
    });

    // App background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMessage(context, message);
    });
  }

  // 👉 Handle Navigation
  Future<void> handleMessage(BuildContext context, RemoteMessage message) async {
    print("Navigating via Message Click: ${message.data}");
    // Yahan apna Get.to(() => MainScreen()) laga dena zaroorat padne par
  }
}