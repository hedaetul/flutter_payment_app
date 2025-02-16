import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountInfoCard extends StatelessWidget {
  final String uid;
  final double balance;

  const AccountInfoCard({
    super.key,
    required this.uid,
    required this.balance,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: uid));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account number copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Account Number'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(uid, overflow: TextOverflow.ellipsis),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(context),
                )
              ],
            ),
            const Divider(),
            const SizedBox(height: 15),
            Text(
              'Balance: \$${balance.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
