import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payment_app/utils/payment_logic.dart';
import 'package:payment_app/widgets/payment/amount_input_widget.dart';
import 'package:payment_app/widgets/payment/payment_button_widget.dart';
import 'package:payment_app/widgets/payment/receiver_info_widget.dart';

class PaymentScreen extends StatefulWidget {
  final String qrData;
  const PaymentScreen({super.key, required this.qrData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _amountController = TextEditingController();
  String receiverName = "";
  String receiverEmail = "";
  bool isReceiverValid = false;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    PaymentLogic.fetchReceiverDetails(widget.qrData, (name, email, valid) {
      setState(() {
        receiverName = name;
        receiverEmail = email;
        isReceiverValid = valid;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(title: const Text('Send Payment')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ReceiverInfoWidget(
                receiverName: receiverName, qrData: widget.qrData),
            const SizedBox(height: 20),
            AmountInputWidget(controller: _amountController),
            const SizedBox(height: 20),
            PaymentButtonWidget(
              isProcessing: isProcessing,
              onPressed: () async {
                setState(() => isProcessing = true);
                await PaymentLogic.handlePayment(
                  user.uid,
                  widget.qrData,
                  receiverName,
                  _amountController.text,
                  context,
                );
                setState(() => isProcessing = false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
