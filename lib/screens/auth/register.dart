import 'package:flutter/material.dart';
import 'package:payment_app/extensions/theme_extension.dart';
import 'package:payment_app/services/auth_service.dart';
import 'package:payment_app/widgets/auth/register_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  bool isLoading = false;

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
  }

  void onSubmit(String email, String password, String username) async {
    setState(() => isLoading = true);
    try {
      await _authService.signUpWithEmail(email, password, username);
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      _showError('SignUp with email-pass failed: $e');
    }
    setState(() => isLoading = false);
  }

  void onGoogleSignIn() async {
    setState(() => isLoading = true);
    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      _showError('Google signin failed:$e');
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 5, right: 20, left: 20, bottom: 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Register Here',
                  style: context.textTheme.titleLarge!.copyWith(fontSize: 36),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Create an account and join us!',
                  style: context.textTheme.bodyLarge!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                RegisterForm(
                  onSubmit: onSubmit,
                  isLoading: isLoading,
                  onGoogleSignIn: onGoogleSignIn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
