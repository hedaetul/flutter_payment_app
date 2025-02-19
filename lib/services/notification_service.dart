import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:payment_app/screens/tabs.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

// For notification request
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
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      const SnackBar(
        content: Text('User declined or has not accepted permission'),
      );
      Future.delayed(
        const Duration(seconds: 2),
        () {
          AppSettings.openAppSettings(type: AppSettingsType.notification);
        },
      );
    }
  }

  // Get Token
  Future<String> getDeviceToken() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    String? token = await messaging.getToken();
    print('token=> $token');
    return token!;
  }

  // Init
  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    var androidInitSetting =
        const AndroidInitializationSettings("@mipmap/ic_launcher");

    var initializationSettings = InitializationSettings(
      android: androidInitSetting,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {
        handleMessage(context, message);
      },
    );
  }

  //firebase init
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen(
      (message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification!.android;

        if (kDebugMode) {
          print('notificationTitle: ${notification!.title}');
          print('notificationTitle: ${notification.body}');
        }
        if (Platform.isAndroid) {
          initLocalNotifications(context, message);
          //handleMessage(context, message);
          showNotification(message);
        }
      },
    );
  }

  // function to show notification
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(),
      message.notification!.android!.channelId.toString(),
      importance: Importance.high,
      showBadge: true,
      playSound: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: "Chanel description",
      importance: Importance.high,
      priority: Priority.high,
      sound: channel.sound,
    );

    //notification merge
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    //show notification
    Future.delayed(
      Duration.zero,
      () {
        _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails,
          payload: message.data.toString(),
        );
      },
    );
  }

  //background message
  Future<void> setupInteractMessage(BuildContext context) async {
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        handleMessage(context, message);
      },
    );

    // terminate state
    FirebaseMessaging.instance.getInitialMessage().then(
      (RemoteMessage? message) {
        if (message != null && message.data.isNotEmpty) {
          handleMessage(context, message);
        }
      },
    );
  }

  Future<void> handleMessage(
      BuildContext context, RemoteMessage message) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const TabsScreen(),
      ),
    );
  }
}
