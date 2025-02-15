import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_app/providers/user_provider.dart';
import 'package:payment_app/screens/transaction.dart';
import 'package:payment_app/screens/transfer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userAsyncValue = ref.watch(userProvider(userId));

    return Scaffold(
      body: userAsyncValue.when(
        data: (userData) {
          final username = userData?['username'] ?? 'User';
          final balance = (userData?['balance'] as num?)?.toDouble() ?? 0.0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Display
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  color: Theme.of(context).colorScheme.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Current Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Transfer & Transaction History Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(Icons.send, 'Transfer', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => const TransferScreen()),
                      );
                    }),
                    _buildActionButton(Icons.history, 'Transactions', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => const TransactionScreen()),
                      );
                    }),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}
