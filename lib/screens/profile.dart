import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payment_app/screens/transfer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'User not logged in.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      );
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

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'No user data found.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            );
          }

          final userData = snapshot.data!.data();
          final username = userData?['username'] ?? 'No username';
          final photoUrl = userData?['photoUrl'] as String?;
          final balance = userData?['balance'] ?? 0;
          final uid = currentUser.uid;

          return Container(
            decoration: BoxDecoration(color: Colors.purple.shade50),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 60,
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                      ? NetworkImage(photoUrl)
                      : null,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                const SizedBox(height: 16),

                // Username
                Text(
                  username,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),

                // Email
                Text(
                  currentUser.email ?? 'No email provided',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // UID with Copy Button
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Account Number'),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  uid,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: uid));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Account number copied to clipboard'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Divider(),
                        const SizedBox(height: 15),

                        // Balance
                        Text(
                          'Balance: \$${balance.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    minimumSize: const Size(300, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => const TransferScreen(),
                      ),
                    );
                  },
                  child: const Text('Transfer Money'),
                ),
                const SizedBox(height: 5),
                OutlinedButton.icon(
                  icon: Icon(
                    Icons.logout,
                    size: 24,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    foregroundColor: Theme.of(context).colorScheme.error,
                    minimumSize: const Size(300, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
