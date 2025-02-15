import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredUsername = '';
  var _enteredPassword = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'profileImage': '',
          'balance': 100,
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication failed.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final doc = await userRef.get();

        // If user is signing in for the first time, save to Firestore
        if (!doc.exists) {
          await userRef.set({
            'username': user.displayName ?? 'Google User',
            'email': user.email,
            'profileImage': user.photoURL ?? '',
            'balance': 100,
          });
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 30, bottom: 20),
                width: 200,
                child: Image.asset('assets/images/konoha.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          key: const ValueKey('email'),
                          decoration:
                              const InputDecoration(labelText: 'Email Address'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                          onSaved: (value) => _enteredEmail = value!,
                        ),
                        if (!_isLogin)
                          TextFormField(
                            key: const ValueKey('username'),
                            decoration:
                                const InputDecoration(labelText: 'Username'),
                            validator: (value) {
                              if (value == null || value.length < 4) {
                                return 'Enter at least 4 characters.';
                              }
                              return null;
                            },
                            onSaved: (value) => _enteredUsername = value!,
                          ),
                        TextFormField(
                          key: const ValueKey('password'),
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                          onSaved: (value) => _enteredPassword = value!,
                        ),
                        const SizedBox(height: 12),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                                onPressed: _submit,
                                child: Text(_isLogin ? 'Login' : 'Signup'),
                              ),
                        TextButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          child: Text(_isLogin
                              ? 'Create an account'
                              : 'Already have an account? Login.'),
                        ),
                        const SizedBox(height: 8),
                        _isLoading
                            ? Container()
                            : OutlinedButton.icon(
                                onPressed: _signInWithGoogle,
                                icon: Image.asset(
                                  'assets/images/google.png',
                                  height: 20,
                                ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
