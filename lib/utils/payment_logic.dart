import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:payment_app/screens/invoice.dart';
import 'package:payment_app/services/notification_service.dart';
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

    String? senderUsername;
    String? senderEmail;
    String? receiverEmail;
    String? receiverUsername = receiverName;
    bool transactionSuccess = false;

    try {
      // Get user data
      final senderDoc = await senderRef.get();
      final receiverDoc = await receiverRef.get();

      if (!receiverDoc.exists) {
        if (context.mounted) {
          _showMessage(context, 'Receiver not found.');
        }
        return;
      }

      senderUsername = senderDoc.data()?['username'] ?? 'Unknown Sender';
      senderEmail = senderDoc.data()?['email'] ?? 'Unknown Email';
      receiverUsername = receiverDoc.data()?['username'] ?? receiverName;
      receiverEmail = receiverDoc.data()?['email'] ?? 'Unknown Email';

      // Run transaction for balance updates
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final senderSnapshot = await transaction.get(senderRef);
        final receiverSnapshot = await transaction.get(receiverRef);

        final senderBalance =
            (senderSnapshot.data()?['balance'] ?? 0.0).toDouble();
        if (senderBalance < amount) {
          throw Exception('Insufficient balance.');
        }

        final updatedSenderBalance = senderBalance - amount;
        final updatedReceiverBalance =
            (receiverSnapshot.data()?['balance'] ?? 0.0) + amount;

        transaction.update(senderRef, {'balance': updatedSenderBalance});
        transaction.update(receiverRef, {'balance': updatedReceiverBalance});
      });

      // Store transaction records
      await addTransactionToFirestore(
        userUid: senderUid,
        username: senderUsername!,
        amount: amount,
        counterUid: receiverUid,
        counterUsername: receiverUsername!,
        transactionType: 'cash-out',
      );

      await addTransactionToFirestore(
        userUid: receiverUid,
        username: receiverUsername,
        amount: amount,
        counterUid: senderUid,
        counterUsername: senderUsername,
        transactionType: 'cash-in',
      );

      transactionSuccess = true;

      // Send Notifications
      if (transactionSuccess) {
        try {
          // Send notification to the sender
          await _notificationService.showNotification(
            RemoteMessage(
              notification: RemoteNotification(
                title: "Payment Successful",
                body:
                    "You sent \$${amount.toStringAsFixed(2)} to $receiverUsername",
              ),
              data: {"transactionType": "cash-out"},
            ),
          );

          // Send notification to the receiver
        } catch (notificationError) {
          print('Error sending notifications: $notificationError');
        }

        _showMessage(context, 'Payment successful!', success: true);

        // Navigate to invoice screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => InvoiceScreen(
              senderUid: senderUid,
              senderEmail: senderEmail!,
              senderUsername: senderUsername!,
              receiverUid: receiverUid,
              receiverEmail: receiverEmail!,
              receiverUsername: receiverUsername!,
              amount: amount,
            ),
          ),
        );
      }
    } catch (e) {
      print('Transaction error: $e');
      _showMessage(
          context, 'Transaction failed: ${e.toString().split(':').last}');
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
