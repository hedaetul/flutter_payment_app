import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String? photoUrl;

  const CustomAvatar({super.key, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 60,
      backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
          ? NetworkImage(photoUrl!)
          : null,
      child: photoUrl == null || photoUrl!.isEmpty
          ? const Icon(Icons.person, size: 60)
          : null,
    );
  }
}
