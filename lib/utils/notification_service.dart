import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalNotificationService {
  Future<void> requestPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Notification permission not granted');
    }
  }

  final _currentUser = FirebaseAuth.instance.currentUser;
  final firebaseFirestore = FirebaseFirestore.instance;

  Future<void> uploadFcmToken() async {
    try {
      await FirebaseMessaging.instance.getToken().then((token) async {
        print('getToken:: $token');
        await firebaseFirestore.collection('users').doc(_currentUser!.uid).set({
          'notificationToken': token,
        }, SetOptions(merge: true));
      });
      FirebaseMessaging.instance.onTokenRefresh.listen(
        (token) async {
          print('onTokenRefresh:: $token');
          await firebaseFirestore
              .collection('users')
              .doc(_currentUser!.uid)
              .set({
            'notificationToken': token,
          }, SetOptions(merge: true));
        },
      );
    } catch (e) {
      print(e.toString());
    }
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
}
