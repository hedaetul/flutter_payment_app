import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _receiverUidController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> _handleTransfer() async {
    final receiverUid = _receiverUidController.text.trim();
    final amountStr = _amountController.text.trim();
    final amount = double.tryParse(amountStr);

    if (receiverUid.isEmpty || amount == null || amount <= 0) {
      _showMessage('Please provide a valid receiver UID and amount.');
      return;
    }

    final usersRef = FirebaseFirestore.instance.collection('users');

    try {
      final senderDoc = await usersRef.doc(user.uid).get();
      final receiverDoc = await usersRef.doc(receiverUid).get();

      print('Searching for receiver with UID: "$receiverUid"');

      if (!receiverDoc.exists) {
        print('Receiver not found for UID: "$receiverUid"');
        _showMessage('Receiver not found. Please check the UID.');
        return;
      }

      final senderBalance = (senderDoc.data()?['balance'] ?? 0.0).toDouble();
      final receiverBalance =
          (receiverDoc.data()?['balance'] ?? 0.0).toDouble();

      if (senderBalance < amount) {
        _showMessage('Insufficient balance.');
        return;
      }

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final senderRef = usersRef.doc(user.uid);
        final receiverRef = usersRef.doc(receiverUid);

        final senderSnapshot = await transaction.get(senderRef);
        final receiverSnapshot = await transaction.get(receiverRef);

        if (!receiverSnapshot.exists) {
          throw Exception('Receiver not found during transaction.');
        }

        final updatedSenderBalance =
            (senderSnapshot.data()?['balance'] ?? 0.0) - amount;
        final updatedReceiverBalance =
            (receiverSnapshot.data()?['balance'] ?? 0.0) + amount;

        transaction.update(senderRef, {'balance': updatedSenderBalance});
        transaction.update(receiverRef, {'balance': updatedReceiverBalance});
      });

      _showMessage('Transfer successful!', isSuccess: true);
    } catch (error) {
      print('Error during transfer: $error');
      _showMessage('Error: $error');
    }
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _receiverUidController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _receiverUidController,
                decoration: const InputDecoration(labelText: 'Receiver UID'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a receiver UID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an amount';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _handleTransfer();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Transfer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
