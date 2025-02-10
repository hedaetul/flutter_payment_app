import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payment_app/screens/payment.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userDoc;

  @override
  void initState() {
    super.initState();
    // Fetch the user document from Firestore
    _userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userDoc,
        builder: (context, snapshot) {
          // Show a loading spinner while fetching data.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Display an error message if something went wrong.
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Handle the case when no data is available.
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User data not found.'));
          }

          // Retrieve the username from the fetched data.
          final userData = snapshot.data!.data();
          final username = userData?['username'] ?? 'No username';

          void payment() {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (ctx) => const PaymentScreen(
                          qrData: 'Invalid QR Code',
                        )));
          }

          // Compose the data string for the QR code.
          // final qrData =
          //     'User ID: ${user.uid}\nEmail: ${user.email}\nUsername: $username';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 24.0, horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hello $username !',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    TextButton(
                        onPressed: payment, child: const Text("payment page"))
                    // const SizedBox(height: 16.0),
                    // QrImageView(
                    //   data: qrData,
                    //   version: QrVersions.auto,
                    //   size: 200.0,
                    // ),
                    // const SizedBox(height: 16.0),
                    // Text(
                    //   'Scan this QR code to share your profile information securely.',
                    //   textAlign: TextAlign.center,
                    //   style: Theme.of(context).textTheme.bodyMedium,
                    // ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
