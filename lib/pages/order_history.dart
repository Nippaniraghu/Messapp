import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _getUserUid(); // Fetch UID when the widget is initialized
  }

  // Function to get the UID from FirebaseAuth (if the user is logged in)
  Future<void> _getUserUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _uid = user.uid; // Assign UID
      });
    } else {
      // If no user is logged in, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
    }
  }

  // Stream to fetch user's orders from Firestore
  Stream<QuerySnapshot> _fetchOrderHistory() {
    if (_uid != null) {
      return _firestore
          .collection('users')
          .doc(_uid)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      // Return an empty stream if UID is null
      return const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: Colors.white,
      ),
      body: _uid == null
          ? const Center(child: Text("User not logged in"))
          : StreamBuilder<QuerySnapshot>(
              stream: _fetchOrderHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No orders found.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                // Display orders in a ListView
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> orderData = snapshot.data!.docs[index]
                        .data() as Map<String, dynamic>;

                    String transactionId = orderData['transactionId'] ?? "N/A";
                    String itemName = orderData['itemName'] ?? "Unknown Item";
                    int price =
                        int.tryParse(orderData['price']?.toString() ?? "0") ??
                            0;
                    int quantity = int.tryParse(
                            orderData['quantity']?.toString() ?? "0") ??
                        0;

                    Timestamp createdAt =
                        orderData['createdAt'] ?? Timestamp.now();
                    DateTime dateTime = createdAt.toDate();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          "Item: $itemName",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Transaction ID: $transactionId"),
                            Text("Price: ₹$price"),
                            Text("Quantity: $quantity"),
                            Text("Date: ${dateTime.toLocal()}"),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
