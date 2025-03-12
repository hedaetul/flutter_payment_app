import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_app/helper/showcase_helper.dart';
import 'package:payment_app/screens/auth/auth_intro.dart';
import 'package:payment_app/screens/tabs.dart';
import 'package:payment_app/services/notification_service.dart';
import 'package:payment_app/theme/app_theme.dart';
import 'package:payment_app/utils/showcase_keys.dart';
import 'package:showcaseview/showcaseview.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(
      child: ShowCaseWidget(builder: (context) => const App()),
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

    // 🔹 Listen for authentication state changes and update UI instantly
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {}); // 🔹 Force UI update when user state changes
      }

      if (user != null) {
        NotificationService()
            .firebaseInit(NavigationService.navigatorKey.currentContext!);
        NotificationService().listenForBalanceChanges(user.uid);
      }
    });

    NotificationService().initLocalNotifications(context);
    NotificationService().requestNotificationPermission();

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null && mounted) {
        NotificationService().handleMessage(context);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(microseconds: 300));
      bool seen = await ShowcaseHelper.hasSeenShowcase();
      if (!seen && mounted) {
        ShowCaseWidget.of(context).startShowCase([
          ShowcaseKeys.firstShowcaseWidget,
          ShowcaseKeys.secondShowcaseWidget,
          ShowcaseKeys.thirdShowcaseWidget,
          ShowcaseKeys.fourthShowcaseWidget,
          ShowcaseKeys.fifthShowcaseWidget,
          ShowcaseKeys.sixthShowcaseWidget,
          ShowcaseKeys.lastShowcaseWidget
        ]);
        await ShowcaseHelper.markShowcaseSeen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment App',
      navigatorKey: NavigationService.navigatorKey,
      theme: AppTheme.lightTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            return const TabsScreen();
          }
          return const AuthIntroScreen();
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
