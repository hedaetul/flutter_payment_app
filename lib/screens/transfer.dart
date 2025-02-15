import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payment_app/screens/invoice.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _receiverUidController = TextEditingController();
  final _amountController = TextEditingController();
  double _selectedAmount = 0.0;
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser!;
  bool _isTransferring = false;
  final List<double> _presetAmounts = [50, 100, 200, 500];

  void _updateAmount(String value) {
    setState(() {
      _selectedAmount = double.tryParse(value) ?? 0.0;
    });
  }

  Future<void> _handleTransfer() async {
    setState(() => _isTransferring = true);
    final receiverUid = _receiverUidController.text.trim();

    if (receiverUid.isEmpty || _selectedAmount <= 0) {
      _showMessage('Enter a valid receiver UID and amount.');
      setState(() => _isTransferring = false);
      return;
    }

    final usersRef = FirebaseFirestore.instance.collection('users');

    try {
      final senderDoc = await usersRef.doc(user.uid).get();
      final receiverDoc = await usersRef.doc(receiverUid).get();

      if (!receiverDoc.exists) {
        _showMessage('Receiver not found.');
        setState(() => _isTransferring = false);
        return;
      }

      final senderBalance = (senderDoc.data()?['balance'] ?? 0.0).toDouble();
      final receiverBalance =
          (receiverDoc.data()?['balance'] ?? 0.0).toDouble();

      if (senderBalance < _selectedAmount) {
        _showMessage('Insufficient balance.');
        setState(() => _isTransferring = false);
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
            (senderSnapshot.data()?['balance'] ?? 0.0) - _selectedAmount;
        final updatedReceiverBalance =
            (receiverSnapshot.data()?['balance'] ?? 0.0) + _selectedAmount;

        transaction.update(senderRef, {'balance': updatedSenderBalance});
        transaction.update(receiverRef, {'balance': updatedReceiverBalance});
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InvoiceScreen(
            senderUid: user.uid,
            senderEmail: senderDoc.data()?['email'] ?? 'No email',
            senderUsername: senderDoc.data()?['username'] ?? 'No username',
            receiverUid: receiverUid,
            receiverEmail: receiverDoc.data()?['email'] ?? 'No email',
            receiverUsername: receiverDoc.data()?['username'] ?? 'No username',
            amount: _selectedAmount,
          ),
        ),
      );
    } catch (error) {
      _showMessage('Error: $error');
    } finally {
      setState(() => _isTransferring = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Money')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recipient`s Account Number',
                  style: TextStyle(color: colorScheme.primary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _receiverUidController,
                decoration: InputDecoration(
                  hintText: 'Enter account number',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Amount to Transfer',
                  style: TextStyle(color: colorScheme.primary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefix: const Text('\$'),
                  hintText: 'Enter custom amount',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: _updateAmount,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _presetAmounts.map((amount) {
                  return ChoiceChip(
                    label: Text('\$${amount.toInt()}'),
                    selected: _selectedAmount == amount,
                    onSelected: (_) {
                      _amountController.text = amount.toStringAsFixed(2);
                      _updateAmount(amount.toString());
                    },
                    selectedColor: colorScheme.primary,
                    labelStyle: TextStyle(
                      color: _selectedAmount == amount
                          ? colorScheme.onPrimary
                          : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isTransferring ? null : _handleTransfer,
                  icon: const Icon(Icons.send),
                  label: _isTransferring
                      ? const Text('Transferring')
                      : const Text('Transfer Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
        ),
        ),
      ),
    );
  }
}
