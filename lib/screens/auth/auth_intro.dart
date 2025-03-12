import 'package:flutter/material.dart';
import 'package:payment_app/extensions/theme_extension.dart';
import 'package:payment_app/screens/auth/login.dart';
import 'package:payment_app/screens/auth/register.dart';
import 'package:payment_app/widgets/auth/logo_widget.dart';

class AuthIntroScreen extends StatelessWidget {
  const AuthIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 5, right: 20, left: 20, bottom: 80),
        child: Column(
          children: [
            const LogoWidget(),
            const SizedBox(height: 40),
            Text(
              'Make your payments easy!',
              style: context.textTheme.titleLarge!.copyWith(fontSize: 36),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Explore our payment app! Make your payments with qr scanning and account number',
              style: context.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: context.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    )),
                OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
