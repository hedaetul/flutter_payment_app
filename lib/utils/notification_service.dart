// lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(initializationSettings);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  // Store user's FCM token in Firestore
  Future<void> saveUserToken(String userId) async {
    final token = await _fcm.getToken();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'fcmToken': token});
  }

  // Send notification for payment
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
      if (fcmToken == null) return;

      final message = type == 'sent'
          ? 'You sent \$$amount to $senderName'
          : 'You received \$$amount from $senderName';

      await FirebaseFirestore.instance.collection('notifications').add({
        'to': fcmToken,
        'notification': {
          'title': 'Payment ${type == 'sent' ? 'Sent' : 'Received'}',
          'body': message,
        },
        'data': {
          'type': 'payment',
          'amount': amount.toString(),
          'sender': senderName,
        }
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await _showLocalNotification(
      title: message.notification?.title ?? 'Payment Notification',
      body: message.notification?.body ?? '',
    );
  }

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
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }
}

// This needs to be a top-level function
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}
