import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_app/screens/auth.dart';
import 'package:payment_app/screens/tabs.dart';
import 'package:payment_app/services/notification_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔹 Start listening for authentication state changes
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      NotificationService()
          .firebaseInit(NavigationService.navigatorKey.currentContext!);
      NotificationService().listenForBalanceChanges(user.uid);
    }
  });

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    // 🔹 Now the context is available
    NotificationService().initLocalNotifications(context);
    NotificationService().requestNotificationPermission();

    // 🔹 Handle Notification Clicks When App is Terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        NotificationService().handleMessage(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment App',
      navigatorKey: NavigationService.navigatorKey,
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 17, 177),
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            return const TabsScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}

// 🔹 Navigation Service to Handle Background Notifications
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
