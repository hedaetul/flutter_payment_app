import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for FirebaseFirestore instance
final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

/// StreamProvider for listening to real-time updates of the entire user document
final userProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, userId) {
  final firestore = ref.watch(firestoreProvider);

  return firestore.collection('users').doc(userId).snapshots().map((snapshot) {
    return snapshot.exists ? snapshot.data() : null;
  });
});

/// Notifier for manually updating user data in Firestore
class UserNotifier extends StateNotifier<Map<String, dynamic>?> {
  final FirebaseFirestore _firestore;

  UserNotifier(this._firestore) : super(null);

  /// Update specific fields in the user document
  Future<void> updateUser(
      String userId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('users').doc(userId).update(updatedData);
      state = {...?state, ...updatedData}; // Merge updated fields
    } catch (e) {
      print("Error updating user data: $e");
    }
  }
}

/// StateNotifierProvider for updating user data
final userNotifierProvider =
    StateNotifierProvider<UserNotifier, Map<String, dynamic>?>((ref) {
  return UserNotifier(ref.watch(firestoreProvider));
});
