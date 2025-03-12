import 'package:flutter/material.dart';
import 'package:payment_app/widgets/pay_tab.dart';
import 'package:payment_app/widgets/receive_tab.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        body: Column(
          children: [
            // TabBar at the top
            Container(
              // Background color
              child: const TabBar(
                labelColor: Colors.black, // Selected tab text/icon color
                unselectedLabelColor: Colors.black12, // Unselected tab color
                indicatorColor: Colors.black, // Indicator color
                tabs: [
                  Tab(text: 'Pay'),
                  Tab(text: 'Receive'),
                ],
              ),
            ),
            // Expanded TabBarView to take the remaining space
            const Expanded(
              child: TabBarView(
                children: [
                  PayTab(),
                  ReceiveTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
