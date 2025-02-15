import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payment_app/screens/invoice.dart';

class PaymentScreen extends StatefulWidget {
  final String qrData;
  const PaymentScreen({super.key, required this.qrData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _amountController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  String receiverName = "";
  String receiverEmail = "";
  String senderUsername = "";
  String senderEmail = "";
  bool isReceiverValid = false;
  double _selectedAmount = 0.0;
  final List<double> _presetAmounts = [50, 100, 200, 500];

  @override
  void initState() {
    super.initState();
    _fetchReceiverDetails();
    _fetchSenderDetails();
  }

  Future<void> _fetchReceiverDetails() async {
    final receiverUid = widget.qrData.trim();
    if (receiverUid.isEmpty || receiverUid == user.uid) {
      setState(() {
        receiverName = "Invalid QR Code";
        isReceiverValid = false;
      });
      return;
    }

    final receiverRef = FirebaseFirestore.instance.collection('users').doc(receiverUid);
    final receiverDoc = await receiverRef.get();

    if (receiverDoc.exists) {
      setState(() {
        receiverName = receiverDoc.data()?['username'] ?? "Unknown User";
        receiverEmail = receiverDoc.data()?['email'] ?? "Unknown Email";
        isReceiverValid = true;
      });
    } else {
      setState(() {
        receiverName = "User not found";
        isReceiverValid = false;
      });
    }
  }

  Future<void> _fetchSenderDetails() async {
    final senderRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final senderDoc = await senderRef.get();
    if (senderDoc.exists) {
      setState(() {
        senderUsername = senderDoc.data()?['username'] ?? "Unknown User";
        senderEmail = senderDoc.data()?['email'] ?? "Unknown Email";
      });
    }
  }

  void _updateAmount(String value) {
    setState(() {
      _selectedAmount = double.tryParse(value) ?? 0.0;
    });
  }

  Future<void> _handlePayment() async {
    if (!isReceiverValid) {
      _showMessage('Invalid receiver. Please scan a valid QR code.');
      return;
    }

    final receiverUid = widget.qrData.trim();
    final amountStr = _amountController.text.trim();
    final amount = double.tryParse(amountStr);

    if (amount == null || amount <= 0) {
      _showMessage('Please enter a valid amount.');
      return;
    }

    final usersRef = FirebaseFirestore.instance.collection('users');

    try {
      final senderDoc = await usersRef.doc(user.uid).get();
      final senderBalance = (senderDoc.data()?['balance'] ?? 0.0).toDouble();

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

        final updatedSenderBalance = (senderSnapshot.data()?['balance'] ?? 0.0) - amount;
        final updatedReceiverBalance = (receiverSnapshot.data()?['balance'] ?? 0.0) + amount;

        transaction.update(senderRef, {'balance': updatedSenderBalance});
        transaction.update(receiverRef, {'balance': updatedReceiverBalance});

        final transactionData = {
          'current_username': senderUsername,
          'transaction_amount': amount,
          'date': FieldValue.serverTimestamp(),
          'counterparty': {
            'uid': receiverUid,
            'username': receiverName,
          },
          'type': 'cash-out',
        };

        final reverseTransactionData = {
          'current_username': receiverName,
          'amount': amount,
          'date': FieldValue.serverTimestamp(),
          'counterUser': {
            'uid': user.uid,
            'username': senderUsername,
          },
          'type': 'cash-in',
        };

        transaction.set(senderRef.collection('transactions').doc(), transactionData);
        transaction.set(receiverRef.collection('transactions').doc(), reverseTransactionData);
      });

      _showMessage('Payment successful!', isSuccess: true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => InvoiceScreen(
            senderUid: user.uid,
            senderEmail: senderEmail,
            senderUsername: senderUsername,
            receiverUid: receiverUid,
            receiverEmail: receiverEmail,
            receiverUsername: receiverName,
            amount: amount,
          ),
        ),
      );
    } catch (error) {
      _showMessage('Transaction failed: $error');
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Send Payment')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text("Receiver:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(receiverName, style: TextStyle(fontSize: 18, color: colorScheme.primary)),
                  const SizedBox(height: 3),
                  Text(widget.qrData, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefix: const Text('\$'),
                hintText: 'Enter amount',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _updateAmount,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _handlePayment,
              icon: const Icon(Icons.payment),
              label: const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}
