import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payment_app/utils/payment_logic.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _receiverUidController = TextEditingController();
  final _amountController = TextEditingController();
  double _selectedAmount = 0.0;
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser!;
  bool _isTransferring = false;
  String _receiverName = "Unknown";

  final List<double> _presetAmounts = [50, 100, 200, 500];

  void _updateAmount(String value) {
    setState(() {
      _selectedAmount = double.tryParse(value) ?? 0.0;
    });
  }

  Future<void> _fetchReceiverDetails() async {
    final receiverUid = _receiverUidController.text.trim();
    if (receiverUid.isNotEmpty) {
      PaymentLogic.fetchReceiverDetails(receiverUid, (name, email, valid) {
        if (valid) {
          setState(() => _receiverName = name);
        } else {
          setState(() => _receiverName = "Unknown");
        }
      });
    }
  }

  Future<void> _handleTransfer() async {
    setState(() => _isTransferring = true);
    final receiverUid = _receiverUidController.text.trim();
    final amountStr = _amountController.text.trim();

    await PaymentLogic.handlePayment(
      user.uid,
      receiverUid,
      _receiverName,
      amountStr,
      context,
    );

    setState(() => _isTransferring = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Money')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recipient`s Account Number',
                  style: TextStyle(color: colorScheme.primary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _receiverUidController,
                decoration: InputDecoration(
                  hintText: 'Enter account number',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (_) => _fetchReceiverDetails(),
              ),
              const SizedBox(height: 10),
              Text('Receiver: $_receiverName',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text('Amount to Transfer',
                  style: TextStyle(color: colorScheme.primary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefix: const Text('\$'),
                  hintText: 'Enter custom amount',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: _updateAmount,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _presetAmounts.map((amount) {
                  return ChoiceChip(
                    label: Text('\$${amount.toInt()}'),
                    selected: _selectedAmount == amount,
                    onSelected: (_) {
                      _amountController.text = amount.toStringAsFixed(2);
                      _updateAmount(amount.toString());
                    },
                    selectedColor: colorScheme.primary,
                    labelStyle: TextStyle(
                      color: _selectedAmount == amount
                          ? colorScheme.onPrimary
                          : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isTransferring ? null : _handleTransfer,
                  icon: const Icon(Icons.send),
                  label: _isTransferring
                      ? const Text('Transferring...')
                      : const Text('Transfer Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
