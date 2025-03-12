import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30, bottom: 20),
      width: 400,
      child: Image.asset('assets/images/starting_wallpaper.png'),
    );
  }
}
