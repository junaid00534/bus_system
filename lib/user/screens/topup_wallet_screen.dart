import 'package:flutter/material.dart';

class TopupWalletScreen extends StatelessWidget {
  const TopupWalletScreen({super.key});

  Widget paymentTile(String title, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // same logic jaisi ticket booking mein ki thi
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Topup Wallet"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            paymentTile("Account Number", Icons.confirmation_number),
            paymentTile("EasyPaisa", Icons.account_balance_wallet),
            paymentTile("JazzCash", Icons.payments),
            paymentTile("Bank Transfer", Icons.account_balance),
            paymentTile("Pay with Gmail", Icons.email),
          ],
        ),
      ),
    );
  }
}
