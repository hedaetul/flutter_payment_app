import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_app/providers/tabs_provider.dart';
import 'package:payment_app/providers/user_provider.dart';
import 'package:payment_app/screens/home.dart';
import 'package:payment_app/screens/profile.dart';
import 'package:payment_app/screens/qr.dart';

class TabsScreen extends ConsumerWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }
}
