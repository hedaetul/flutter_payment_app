import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveTab extends StatelessWidget {
  const ReceiveTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final userData = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: userData,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData ||
            snapshot.data == null ||
            !snapshot.data!.exists) {
          return const Center(
            child: Text('No user data found.'),
          );
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        String username = userData['username'] ?? 'Unknown username';
        String email = userData['email'] ?? 'Unknown email';
        int balance = userData['balance'] ?? 0;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QrImageView(
                data:
                    'User ID: ${user.uid}\nEmail: $email\nUsername: $username\nBalance: \$ $balance ',
                version: QrVersions.auto,
                size: 200,
              ),
              const SizedBox(height: 20),
              const Text('Scan this QR code to receive payments.')
            ],
          ),
        );
      },
    );
  }
}
