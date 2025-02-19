import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission for notifications
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Handle notification tap when the app is opened
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("User tapped on notification: ${message.data}");
    });
  }

  // Save FCM token to Firestore
  Future<void> saveUserToken(String userId) async {
    final token = await _fcm.getToken();
    if (token == null) return;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'fcmToken': token,
    });
  }

  // Inside NotificationService class
  Future<void> sendPaymentNotification({
    required String receiverUid,
    required String senderName,
    required double amount,
    required String type, // 'sent' or 'received'
  }) async {
    try {
      final receiverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverUid)
          .get();

      final fcmToken = receiverDoc.data()?['fcmToken'];
      if (fcmToken == null) {
        print('No FCM token found for user $receiverUid');
        return;
      }

      final message = type == 'sent'
          ? 'You sent \$${amount.toStringAsFixed(2)} to $senderName'
          : 'You received \$${amount.toStringAsFixed(2)} from $senderName';

      await _sendFCMNotification(
        fcmToken: fcmToken,
        title: 'Payment ${type == 'sent' ? 'Sent' : 'Received'}',
        body: message,
        data: {
          'type': 'payment',
          'amount': amount.toString(),
          'sender': senderName,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Send push notification using Firebase Cloud Messaging (FCM)
  Future<void> _sendFCMNotification({
    required String fcmToken,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    const String serverKey =
        'YOUR_SERVER_KEY_HERE'; // Replace with your Firebase Server Key

    final Map<String, dynamic> payload = {
      'to': fcmToken,
      'notification': {
        'title': title,
        'body': body,
        'sound': 'default',
      },
      'data': data, // Custom data for app handling
    };

    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print("Notification sent successfully!");
      } else {
        print("Failed to send notification: ${response.body}");
      }
    } catch (e) {
      print("Error sending FCM notification: $e");
    }
  }

  // Handle foreground notifications
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await _showLocalNotification(
      title: message.notification?.title ?? 'Payment Notification',
      body: message.notification?.body ?? '',
    );
  }

  // Show a local notification for foreground messages
  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'payment_channel',
      'Payment Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      details,
    );
  }
}

// Background message handler (must be a top-level function)
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}
