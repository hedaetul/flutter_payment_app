import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_app/providers/tabs_provider.dart';
import 'package:payment_app/providers/user_provider.dart';
import 'package:payment_app/screens/home.dart';
import 'package:payment_app/screens/profile.dart';
import 'package:payment_app/screens/qr.dart';
import 'package:payment_app/utils/showcase_keys.dart';
import 'package:showcaseview/showcaseview.dart';

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userAsyncValue = ref.watch(userProvider(userId));
    final selectedPageIndex = ref.watch(tabsProvider);

    Widget activePage = const HomeScreen();
    String activePageTitle = 'Homepage';

    if (selectedPageIndex == 1) {
      activePageTitle = 'QR page';
      activePage = const QrScreen();
    } else if (selectedPageIndex == 2) {
      activePageTitle = 'Profile';
      activePage = const ProfileScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: userAsyncValue.when(
          data: (userData) {
            final username = userData?['username'] ?? 'User';
            return Text('Hello, $username');
          },
          loading: () => Text(activePageTitle),
          error: (e, stack) => Text(activePageTitle),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.logout,
                color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedPageIndex,
        onTap: (index) {
          ref.read(tabsProvider.notifier).state = index;
        },
        items: [
          BottomNavigationBarItem(
            icon: Showcase(
                key: ShowcaseKeys.firstShowcaseWidget,
                description: 'This is homepage',
                targetPadding: const EdgeInsets.all(8),
                child: const Icon(Icons.home_outlined)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Showcase(
                key: ShowcaseKeys.secondShowcaseWidget,
                description: 'Tap here for scan QR code',
                targetPadding: const EdgeInsets.all(8),
                child: const Icon(Icons.qr_code_scanner)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Showcase(
                key: ShowcaseKeys.thirdShowcaseWidget,
                description: 'Tap here for view profile',
                targetPadding: const EdgeInsets.all(8),
                child: const Icon(Icons.person)),
            label: '',
          ),
        ],
      ),
    );
  }
}
