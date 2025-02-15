import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For formatting date
import 'package:payment_app/providers/user_provider.dart';

class TransactionScreen extends ConsumerWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("User not logged in"));
    }

    final userAsync = ref.watch(userProvider(user.uid));

    return Scaffold(
      appBar: AppBar(title: const Text("Transaction History")),
      body: userAsync.when(
        data: (userData) {
          if (userData == null) {
            return const Center(child: Text("No transactions found"));
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('transactions')
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No transactions yet"));
              }

              final transactions = snapshot.data!.docs;

              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index].data();
                  final amount = transaction['amount'] as num;
                  final type = transaction['type'] as String;
                  final counterUser =
                      transaction['counterUser'] as Map<String, dynamic>;
                  final date = (transaction['date'] as Timestamp).toDate();
                  final formattedDate =
                      DateFormat.yMMMd().add_jm().format(date);

                  final isCashOut = type == 'cash-out';
                  final transactionColor =
                      isCashOut ? Colors.redAccent : Colors.greenAccent;
                  final sign = isCashOut ? '-' : '+';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transactionColor,
                      child: Icon(
                        isCashOut ? Icons.arrow_upward : Icons.arrow_downward,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      "${isCashOut ? "Sent to" : "Received from"} ${counterUser['username']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(formattedDate),
                    trailing: Text(
                      "$sign\$${amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: transactionColor,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
