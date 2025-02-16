import 'package:flutter/material.dart';
import 'package:payment_app/widgets/profile/custom_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  final String? photoUrl;

  const ProfileHeader({
    super.key,
    required this.username,
    required this.email,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAvatar(photoUrl: photoUrl),
        const SizedBox(height: 16),
        Text(username, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(email, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
