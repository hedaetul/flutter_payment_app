import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/auth/auth_form.dart';
import '../widgets/auth/logo_widget.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  bool _isLogin = true;
  bool _isLoading = false;

  void _toggleAuthMode() => setState(() => _isLogin = !_isLogin);

  Future<void> _handleAuth(String email, String password,
      [String? username]) async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await _authService.signInWithEmail(email, password);
      } else {
        await _authService.signUpWithEmail(email, password, username!);
      }
    } catch (e) {
      _showError('Authentication failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      _showError('Google Sign-In failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const LogoWidget(),
              AuthForm(
                isLogin: _isLogin,
                onSubmit: _handleAuth,
                isLoading: _isLoading,
                onToggle: _toggleAuthMode,
                onGoogleSignIn: _signInWithGoogle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
