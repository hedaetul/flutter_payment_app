import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for FirebaseFirestore instance
final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

/// StateNotifierProvider that exposes a double? (the user balance)
final userBalanceProvider =
    StateNotifierProvider<UserBalanceNotifier, double?>((ref) {
  return UserBalanceNotifier(ref.watch(firestoreProvider));
});

class UserBalanceNotifier extends StateNotifier<double?> {
  final FirebaseFirestore _firestore;

  UserBalanceNotifier(this._firestore) : super(null);

  /// Fetch the user balance from Firestore using the given userId
  Future<void> fetchBalance(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        state = (userDoc['balance'] as num).toDouble();
      }
    } catch (e) {
      print("Error fetching balance: $e");
      state = null;
    }
  }

  /// Update the user balance in Firestore and update local state
  Future<void> updateBalance(String userId, double newBalance) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'balance': newBalance});
      state = newBalance;
    } catch (e) {
      print("Error updating balance: $e");
    }
  }
}
