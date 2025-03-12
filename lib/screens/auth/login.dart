import 'package:flutter/material.dart';
import 'package:payment_app/extensions/theme_extension.dart';
import 'package:payment_app/services/auth_service.dart';
import 'package:payment_app/widgets/auth/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
  }

  Future<void> _onSubmit(String email, String password) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _authService.signInWithEmail(email, password);
      if (mounted) {
       
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      _showError('Authentication failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      _showError('Google Sign-In failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [],
      ), //
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 5, right: 20, left: 20, bottom: 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Login Here',
                  style: context.textTheme.titleLarge!.copyWith(fontSize: 36),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome back. You\'ve\n been missed',
                  style: context.textTheme.bodyLarge!.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                LoginForm(
                    onSubmit: _onSubmit,
                    isLoading: _isLoading,
                    onGoogleSignIn: _signInWithGoogle)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
