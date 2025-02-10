import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/user_balance.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String qrData;

  const PaymentScreen({super.key, required this.qrData});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool isProcessing = false;
  String? senderId;

  @override
  void initState() {
    super.initState();
    _initializeSenderId();
  }

  Future<void> _initializeSenderId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      senderId = currentUser.uid;
      await ref.read(userBalanceProvider.notifier).fetchBalance(senderId!);
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _handlePayment() async {
    if (senderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sender ID not initialized")),
      );
      return;
    }

    double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid amount")),
      );
      return;
    }

    final senderBalance = ref.read(userBalanceProvider);
    if (senderBalance == null || amount > senderBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Insufficient Balance")),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.runTransaction((transaction) async {
        final senderRef = firestore.collection('users').doc(senderId);
        final receiverRef = firestore.collection('users').doc(widget.qrData);

        final senderSnapshot = await transaction.get(senderRef);
        final receiverSnapshot = await transaction.get(receiverRef);

        if (!senderSnapshot.exists) {
          throw Exception("Sender not found");
        }
        if (!receiverSnapshot.exists) {
          throw Exception("Receiver not found");
        }

        final senderBalance = (senderSnapshot['balance'] as num).toDouble();
        final receiverBalance = (receiverSnapshot['balance'] as num).toDouble();

        if (senderBalance < amount) {
          throw Exception("Insufficient balance");
        }

        transaction.update(senderRef, {'balance': senderBalance - amount});
        transaction.update(receiverRef, {'balance': receiverBalance + amount});
      });

      ref
          .read(userBalanceProvider.notifier)
          .updateBalance(senderId!, senderBalance - amount);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Successful!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Failed: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final senderBalance = ref.watch(userBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Payment Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: senderBalance == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Balance: \$${senderBalance.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  const Text("Enter amount"),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: "\$",
                      labelText: "Amount",
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isProcessing ? null : _handlePayment,
                    child: isProcessing
                        ? const CircularProgressIndicator()
                        : const Text("Pay"),
                  ),
                ],
              ),
            ),
    );
  }
}
