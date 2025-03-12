import 'package:flutter/material.dart';
import 'package:payment_app/screens/auth/register.dart';
import 'package:payment_app/widgets/custom-widgets/custom_text_form_field.dart';

class LoginForm extends StatefulWidget {
  final bool isLoading;
  final void Function(String email, String password) onSubmit;
  final VoidCallback onGoogleSignIn;

  const LoginForm({
    super.key,
    required this.onSubmit,
    required this.isLoading,
    required this.onGoogleSignIn,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _trySubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSubmit(_email, _password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFormField(
                labelText: 'Email Address',
                key: const ValueKey('email'),
                validator: (value) => value == null || !value.contains('@')
                    ? 'Enter a valid email'
                    : null,
                onSaved: (value) => _email = value!,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                key: const ValueKey('password'),
                obscureText: true,
                labelText: 'Password',
                validator: (value) => (value?.length ?? 0) < 6
                    ? 'Password must be at least 6 characters'
                    : null,
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _trySubmit,
                  child: widget.isLoading
                      ? const Text('Loading...')
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text('Crete new account'),
              ),
              const SizedBox(height: 20),
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
