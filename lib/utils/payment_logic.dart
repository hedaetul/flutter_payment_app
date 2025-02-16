import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:payment_app/screens/invoice.dart';
import 'package:payment_app/utils/notification_service.dart';
import 'package:payment_app/utils/store_transaction.dart';


class PaymentLogic {
  static final NotificationService _notificationService = NotificationService();

  static Future<void> fetchReceiverDetails(
    String receiverUid,
    Function(String name, String email, bool valid) callback,
  ) async {
    if (receiverUid.isEmpty) {
      callback("Invalid QR Code", "", false);
      return;
    }
    final receiverDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverUid)
        .get();
    if (receiverDoc.exists) {
      final data = receiverDoc.data();
      callback(data?['username'] ?? "Unknown User",
          data?['email'] ?? "Unknown Email", true);
    } else {
      callback("Unknown", "", false);
    }
  }

  static Future<void> handlePayment(
    String senderUid,
    String receiverUid,
    String receiverName,
    String amountStr,
    BuildContext context,
  ) async {
    final amount = double.tryParse(amountStr) ?? 0.0;
    if (amount <= 0) {
      _showMessage(context, 'Enter a valid amount.');
      return;
    }

    final senderRef =
        FirebaseFirestore.instance.collection('users').doc(senderUid);
    final receiverRef =
        FirebaseFirestore.instance.collection('users').doc(receiverUid);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final senderDoc = await transaction.get(senderRef);
        final receiverDoc = await transaction.get(receiverRef);
        if (!receiverDoc.exists) throw Exception('Receiver not found.');

        final senderBalance = (senderDoc.data()?['balance'] ?? 0.0).toDouble();
        if (senderBalance < amount) {
          throw Exception('Insufficient balance.');
        }

        final updatedSenderBalance = senderBalance - amount;
        final updatedReceiverBalance =
            (receiverDoc.data()?['balance'] ?? 0.0) + amount;

        transaction.update(senderRef, {'balance': updatedSenderBalance});
        transaction.update(receiverRef, {'balance': updatedReceiverBalance});

        // Store transactions
        await addTransactionToFirestore(
          userUid: senderUid,
          username: senderDoc.data()?['username'],
          amount: amount,
          counterUid: receiverUid,
          counterUsername: receiverName,
          transactionType: 'cash-out',
        );

        await addTransactionToFirestore(
          userUid: receiverUid,
          username: receiverName,
          amount: amount,
          counterUid: senderUid,
          counterUsername: senderDoc.data()?['username'],
          transactionType: 'cash-in',
        );

        final senderUsername =
            senderDoc.data()?['username'] ?? 'Unknown Sender';
        final senderEmail = senderDoc.data()?['email'] ?? 'Unknown Email';
        final receiverUsername =
            receiverDoc.data()?['username'] ?? 'Unknown Receiver';
        final receiverEmail = receiverDoc.data()?['email'] ?? 'Unknown Email';

        // Send notification to receiver
        await _notificationService.sendPaymentNotification(
          receiverUid: receiverUid,
          senderName: senderUsername,
          amount: amount,
          type: 'received',
        );

        // Send notification to sender
        await _notificationService.sendPaymentNotification(
          receiverUid: senderUid,
          senderName: receiverUsername,
          amount: amount,
          type: 'sent',
        );

        _showMessage(context, 'Payment successful!', success: true);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => InvoiceScreen(
              senderUid: senderUid,
              senderEmail: senderEmail,
              senderUsername: senderUsername,
              receiverUid: receiverUid,
              receiverEmail: receiverEmail,
              receiverUsername: receiverUsername,
              amount: amount,
            ),
          ),
        );
      });
    } catch (e) {
      _showMessage(context, 'Transaction failed: $e');
    }
  }

  static void _showMessage(BuildContext context, String message,
      {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}