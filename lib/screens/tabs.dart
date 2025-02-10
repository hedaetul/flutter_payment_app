import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payment_app/screens/home.dart';
import 'package:payment_app/screens/profile.dart';
import 'package:payment_app/screens/qr.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  var _selectedPageIndex = 0;

  void _selectedPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  // A helper method for signing out
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // Optionally, navigate to your login screen after signing out.
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = const HomeScreen();

    var activePageTitle = 'Homepage';

    if (_selectedPageIndex == 1) {
      activePageTitle = 'QR page';
      activePage = const QrScreen();
    }

    if (_selectedPageIndex == 2) {
      activePageTitle = 'Profile';
      activePage = const ProfileScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: _signOut,
          ),
        ],
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: _selectedPage,
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
