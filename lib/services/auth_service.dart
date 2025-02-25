import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:payment_app/services/notification_service.dart';

final notificationService = NotificationService();

class AuthService {
  final _firebase = FirebaseAuth.instance;

  Future<void> signInWithEmail(String email, String password) async {
    await _firebase.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signUpWithEmail(
      String email, String password, String username) async {
    final userCredentials = await _firebase.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final fcmToken = await notificationService.getDeviceToken();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredentials.user!.uid)
        .set({
      'username': username,
      'email': email,
      'profileImage': '',
      'balance': 100,
      'fcmToken': fcmToken
    });
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebase.signInWithCredential(credential);
    final user = userCredential.user;
    final fcmToken = await notificationService.getDeviceToken();

    if (user != null) {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      if (!(await userRef.get()).exists) {
        await userRef.set({
          'username': user.displayName ?? 'Google User',
          'email': user.email,
          'profileImage': user.photoURL ?? '',
          'balance': 100,
          'fcmToken': fcmToken
        });
      }
    }
  }
}
