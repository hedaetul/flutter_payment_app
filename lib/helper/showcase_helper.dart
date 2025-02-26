import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowcaseHelper {
  static Future<bool> hasSeenShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return false; // No user logged in

    return prefs.getBool('showcase_seen_${user.uid}') ?? false;
  }

  static Future<void> markShowcaseSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await prefs.setBool('showcase_seen_${user.uid}', true);
  }
}
