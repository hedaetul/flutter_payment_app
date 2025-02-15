import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addTransactionToFirestore({
  required String userUid,
  required String username,
  required double amount,
  required String counterUid,
  required String counterUsername,
  required String transactionType,
}) async {
  final transactionData = {
    'username': username,
    'amount': amount,
    'date': FieldValue.serverTimestamp(),
    'counterUser': {
      'uid': counterUid,
      'username': counterUsername,
    },
    'type': transactionType,
  };

  await FirebaseFirestore.instance
      .collection('users')
      .doc(userUid)
      .collection('transactions')
      .add(transactionData);
}
