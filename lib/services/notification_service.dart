import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:payment_app/screens/tabs.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 🔹 Singleton Pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // 🔹 Request Notification Permission
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('⚠️ User granted provisional permission');
    } else {
      print('❌ User declined permission');
      Future.delayed(
        const Duration(seconds: 2),
        () {
          AppSettings.openAppSettings(type: AppSettingsType.notification);
        },
      );
    }
  }

  // 🔹 Get Device Token for Firebase Messaging
  Future<String?> getDeviceToken() async {
    String? token = await messaging.getToken();
    print('🔹 FCM Token: $token');
    return token;
  }

  // 🔹 Initialize Local Notifications
  void initLocalNotifications(BuildContext context) async {
    var androidInitSetting =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    var initializationSettings =
        InitializationSettings(android: androidInitSetting);
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {
        handleMessage(context);
      },
    );
  }

  // 🔹 Initialize Firebase Messaging Listeners
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        showNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMessage(context);
    });
  }

  // 🔹 Show Notification
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message.notification?.android?.channelId ?? "high_importance_channel",
      message.notification?.android?.channelId ?? "high_importance_channel",
      importance: Importance.high,
      showBadge: true,
      playSound: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: "Transaction Notifications",
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    _flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  // 🔹 Listen for Balance Changes (Receiver Notification)
  void listenForBalanceChanges(String receiverUid) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(receiverUid)
        .collection('transactions')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null && data['type'] == 'cash-in') {
            double amount = (data['amount'] ?? 0.0).toDouble();
            String senderName = data['senderName'] ?? "Someone";

            // 🔹 Notify receiver about received payment
            showNotification(
              RemoteMessage(
                notification: RemoteNotification(
                  title: "💰 Payment Received",
                  body:
                      "You received \$${amount.toStringAsFixed(2)} from $senderName",
                ),
                data: {"transactionType": "cash-in"},
              ),
            );
          }
        }
      }
    });
  }

  // 🔹 Handle Notification Clicks
  Future<void> handleMessage(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const TabsScreen()),
    );
  }
}
