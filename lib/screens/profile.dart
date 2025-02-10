import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the currently authenticated user
    final currentUser = FirebaseAuth.instance.currentUser;

    // If there is no logged-in user, show an appropriate message.
    if (currentUser == null) {
      return const Center(child: Text('User not logged in.'));
    }

    // Use FutureBuilder to fetch the user's document from Firestore.
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get(),
      builder: (context, snapshot) {
        // While waiting for data, display a loading spinner.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // If an error occurred, display the error message.
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // If no data exists for the user, display a message.
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No user data found.'));
        }

        // Retrieve user data from the snapshot.
        final userData = snapshot.data!.data();
        final username = userData?['username'] ?? 'No username provided';
        final photoUrl = userData?['photoUrl'] as String?;
        final balance = userData?['balance'] as int?;

        return Center(
          child: Card(
            margin: const EdgeInsets.all(16.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display the user's profile picture
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                        ? NetworkImage(photoUrl)
                        : null,
                    child: (photoUrl == null || photoUrl.isEmpty)
                        ? const Icon(
                            Icons.person,
                            size: 50,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Display the user's username
                  Text(
                    username,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  // Display the user's email
                  Text(
                    currentUser.email ?? 'No email provided',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  // Display the user's email
                  Text(
                    'Balance: \$ $balance',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  // Additional user info can be added here.
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
