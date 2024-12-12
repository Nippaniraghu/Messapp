import 'package:flutter/material.dart';

class Wallet extends StatelessWidget {
  const Wallet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet"),
        backgroundColor: Colors.black, // Customize the app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment Options",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.black),
              title: const Text("Credit Card / Debit Card"),
              onTap: () {
                // Add action if needed in the future
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.black),
              title: const Text("Net Banking"),
              onTap: () {
                // Add action if needed in the future
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.account_balance_wallet, color: Colors.black),
              title: const Text("UPI (Google Pay, PhonePe, Paytm, etc.)"),
              onTap: () {
                // Add action if needed in the future
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.black),
              title: const Text("QR Code"),
              onTap: () {
                // Add action if needed in the future
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.black),
              title: const Text("Cash on Delivery"),
              onTap: () {
                // Add action if needed in the future
              },
            ),
          ],
        ),
      ),
    );
  }
}
