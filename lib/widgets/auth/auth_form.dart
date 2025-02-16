import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final bool isLogin;
  final bool isLoading;
  final void Function(String email, String password, [String? username])
      onSubmit;
  final VoidCallback onToggle;
  final VoidCallback onGoogleSignIn;

  const AuthForm({
    super.key,
    required this.isLogin,
    required this.onSubmit,
    required this.isLoading,
    required this.onToggle,
    required this.onGoogleSignIn,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _username = '';

  void _trySubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.isLogin
          ? widget.onSubmit(_email, _password)
          : widget.onSubmit(_email, _password, _username);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const ValueKey('email'),
                decoration: const InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || !value.contains('@')
                    ? 'Enter a valid email'
                    : null,
                onSaved: (value) => _email = value!,
              ),
              if (!widget.isLogin)
                TextFormField(
                  key: const ValueKey('username'),
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) => value == null || value.length < 4
                      ? 'Enter at least 4 characters.'
                      : null,
                  onSaved: (value) => _username = value!,
                ),
              TextFormField(
                key: const ValueKey('password'),
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => (value?.length ?? 0) < 6
                    ? 'Password must be at least 6 characters'
                    : null,
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 12),
              widget.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _trySubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: Text(widget.isLogin ? 'Login' : 'Signup'),
                    ),
              TextButton(
                onPressed: widget.onToggle,
                child: Text(widget.isLogin
                    ? 'Create an account'
                    : 'Already have an account? Login.'),
              ),
              const SizedBox(height: 8),
              widget.isLoading
                  ? Container()
                  : OutlinedButton.icon(
                      onPressed: widget.onGoogleSignIn,
                      icon: Image.asset('assets/images/google.png', height: 20),
                      label: const Text('Continue with Google'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
