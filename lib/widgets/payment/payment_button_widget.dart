import 'package:flutter/material.dart';

class PaymentButtonWidget extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onPressed;

  const PaymentButtonWidget(
      {super.key, required this.isProcessing, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isProcessing ? null : onPressed,
        icon: const Icon(Icons.payment),
        label: Text(isProcessing ? 'Processing...' : 'Pay Now'),
      ),
    );
  }
}
