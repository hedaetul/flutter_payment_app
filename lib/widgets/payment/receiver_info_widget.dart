import 'package:flutter/material.dart';

class ReceiverInfoWidget extends StatelessWidget {
  final String receiverName;
  final String qrData;

  const ReceiverInfoWidget({super.key, required this.receiverName, required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          const Text("Receiver:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(receiverName, style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 3),
          Text(qrData, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
