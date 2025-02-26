import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payment_app/widgets/profile/account_info_card.dart';
import 'package:payment_app/widgets/profile/logout_button.dart';
import 'package:payment_app/widgets/profile/profile_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('User not logged in.'));
    }

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(child: Text('Failed to load profile data.'));
          }

          final userData = snapshot.data!.data()!;
          return Container(
            color: Colors.purple.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileHeader(
                  username: userData['username'] ?? 'No username',
                  email: currentUser.email ?? 'No email',
                  photoUrl: userData['photoUrl'],
                ),
                const SizedBox(height: 16),
                AccountInfoCard(
                  uid: currentUser.uid,
                  balance: (userData['balance'] as num?)?.toDouble() ?? 0.0,
                ),
                const SizedBox(height: 30),
                const LogoutButton(),
              ],
            ),
          );
        },
      ),
    );
  }
}
