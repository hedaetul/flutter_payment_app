import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payment_app/screens/payment/transfer.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  void _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(300, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const TransferScreen()),
          ),
          child: const Text('Transfer Money'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text('Logout'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            minimumSize: const Size(300, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _logout,
        ),
      ],
    );
  }
}
