import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingOrders extends StatefulWidget {
  const PendingOrders({super.key});

  @override
  _PendingOrdersState createState() => _PendingOrdersState();
}

class _PendingOrdersState extends State<PendingOrders> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _totalOrders = 0;

  // Function to update the status of a transaction (verified or rejected)
  Future<void> _updateTransactionStatus(
      String userId, String transactionId, bool status) async {
    try {
      // Update the specific transaction document with the "verified" status
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .update({'verified': status});

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status
              ? 'Transaction verified successfully!'
              : 'Transaction rejected successfully!'),
        ),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating transaction: $e')),
      );
    }
  }

  // Function to fetch total number of transactions (orders)
  Future<void> _fetchTotalOrders() async {
    int totalOrders = 0;
    try {
      // Stream to fetch all user documents
      final userSnapshot = await _firestore.collection('users').get();

      for (var userDoc in userSnapshot.docs) {
        final userId = userDoc.id;

        // Fetch the transactions for each user
        final transactionSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .get();

        totalOrders += transactionSnapshot.docs.length;
      }

      setState(() {
        _totalOrders = totalOrders;
      });
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching total orders: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        backgroundColor: const Color.fromARGB(255, 220, 63, 63),
      ),
      body: Column(
        children: [
          // Button to fetch the total number of orders
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _fetchTotalOrders,
              child: const Text("Fetch Total Orders"),
            ),
          ),
          // Display total orders
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total Orders: $_totalOrders',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Stream to fetch all user documents from Firestore
              stream: _firestore.collection('users').snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No transactions found.'));
                }

                final userDocs = userSnapshot.data!.docs;

                return ListView.builder(
                  itemCount: userDocs.length,
                  itemBuilder: (context, index) {
                    final userDoc = userDocs[index];
                    final userId = userDoc.id;

                    return StreamBuilder<QuerySnapshot>(
                      // Stream to fetch transactions for the current user
                      stream: _firestore
                          .collection('users')
                          .doc(userId)
                          .collection('transactions')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, transactionSnapshot) {
                        if (transactionSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ListTile(
                            title: Text("Loading transactions..."),
                          );
                        }

                        if (!transactionSnapshot.hasData ||
                            transactionSnapshot.data!.docs.isEmpty) {
                          return const SizedBox(); // Skip if no transactions
                        }

                        final transactionDocs = transactionSnapshot.data!.docs;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "User ID: $userId",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ...transactionDocs.map((transactionDoc) {
                              // Ensure data is safely cast to a Map<String, dynamic>
                              final transactionData = transactionDoc.data()
                                  as Map<String, dynamic>?;

                              if (transactionData == null) {
                                return const SizedBox(); // Skip if data is null
                              }

                              final transactionId = transactionDoc.id;
                              final transactionText =
                                  transactionData['transactionId'] ?? 'N/A';
                              final createdAt = transactionData['createdAt'] !=
                                      null
                                  ? (transactionData['createdAt'] as Timestamp)
                                      .toDate()
                                      .toString()
                                  : 'Unknown';
                              final isVerified =
                                  transactionData['verified']; // Status field

                              return ListTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Transaction ID: $transactionText\nCreated At: $createdAt",
                                      ),
                                    ),
                                    if (isVerified == true)
                                      const Icon(Icons.check_circle,
                                          color: Colors.green) // Green Check
                                    else if (isVerified == false)
                                      const Icon(Icons.cancel,
                                          color: Colors.red) // Red Cross
                                    else
                                      const SizedBox(), // No status yet
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Green Button (Mark as Verified)
                                    IconButton(
                                      icon: const Icon(Icons.check_circle,
                                          color: Colors.green),
                                      onPressed: () => _updateTransactionStatus(
                                          userId, transactionId, true),
                                    ),
                                    // Red Button (Mark as Rejected)
                                    IconButton(
                                      icon: const Icon(Icons.cancel,
                                          color: Colors.red),
                                      onPressed: () => _updateTransactionStatus(
                                          userId, transactionId, false),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const Divider(),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
