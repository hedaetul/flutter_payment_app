import 'package:flutter/material.dart';

class AmountInputWidget extends StatelessWidget {
  final TextEditingController controller;

  const AmountInputWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefix: const Text('\$'),
        hintText: 'Enter amount',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
