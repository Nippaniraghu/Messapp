import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingOrders extends StatefulWidget {
  final String adminId;

  const PendingOrders({super.key, required this.adminId});

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
      // Show confirmation dialog before updating
      bool? confirmUpdate = await _showConfirmationDialog();
      if (confirmUpdate == true) {
        // Fetch the transaction document
        final transactionDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc(transactionId)
            .get();

        if (transactionDoc.exists) {
          final transactionData =
              transactionDoc.data() as Map<String, dynamic>?;

          // Check if the adminId matches
          if (transactionData != null &&
              transactionData['adminId'] == widget.adminId) {
            // Update the transaction's status
            await transactionDoc.reference.update({'verified': status});

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(status
                    ? 'Transaction verified successfully!'
                    : 'Transaction rejected successfully!'),
              ),
            );
            // Hide the transaction from the pending orders list by removing it
            setState(() {
              // _fetchTotalOrders() will be triggered to update the list
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'You are not authorized to update this transaction.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction not found.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating transaction: $e')),
      );
    }
  }

  // Function to fetch the total number of transactions (orders)
  Future<void> _fetchTotalOrders() async {
    int totalOrders = 0;
    try {
      final transactionSnapshot = await _firestore
          .collectionGroup('transactions')
          .where('adminId', isEqualTo: widget.adminId)
          .get();

      totalOrders = transactionSnapshot.docs.length;

      setState(() {
        _totalOrders = totalOrders;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching total orders: $e')),
      );
    }
  }

  // Function to show a confirmation dialog
  Future<bool?> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Order'),
          content: const Text('Do you want to confirm this order?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User pressed No
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User pressed Yes
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _fetchTotalOrders,
              child: const Text("Fetch Total Orders"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total Orders: $_totalOrders',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collectionGroup('transactions')
                  .where('adminId', isEqualTo: widget.adminId)
                  .snapshots(),
              builder: (context, transactionSnapshot) {
                if (transactionSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!transactionSnapshot.hasData ||
                    transactionSnapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No transactions found.'));
                }

                final transactionDocs = transactionSnapshot.data!.docs;

                return ListView.builder(
                  itemCount: transactionDocs.length,
                  itemBuilder: (context, index) {
                    final transactionDoc = transactionDocs[index];
                    final transactionData =
                        transactionDoc.data() as Map<String, dynamic>?;

                    if (transactionData == null) {
                      return const SizedBox();
                    }

                    final transactionId = transactionDoc.id;
                    final userRef = transactionDoc.reference.parent.parent;

                    return FutureBuilder<DocumentSnapshot>(
                      future: userRef!.get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const SizedBox();
                        }

                        final userData =
                            userSnapshot.data!.data() as Map<String, dynamic>?;

                        final username = userData?['name'] ?? 'Unknown';
                        final email = userData?['email'] ?? 'Unknown';
                        final transactionText =
                            transactionData['transactionId'] ?? 'N/A';
                        final createdAt = transactionData['createdAt'] != null
                            ? (transactionData['createdAt'] as Timestamp)
                                .toDate()
                                .toString()
                            : 'Unknown';
                        final isVerified = transactionData['verified'];

                        return ListTile(
                          title: Text(
                              "Transaction ID: $transactionText\nCreated At: $createdAt\nUsername: $username\nEmail: $email"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.green),
                                onPressed: () => _updateTransactionStatus(
                                    userRef.id, transactionId, true),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.cancel, color: Colors.red),
                                onPressed: () => _updateTransactionStatus(
                                    userRef.id, transactionId, false),
                              ),
                            ],
                          ),
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
