import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeproject/admin/Orderdetails.dart';
import 'package:flutter/material.dart';

class OrderHistoryPage extends StatefulWidget {
  final String adminID;

  const OrderHistoryPage({Key? key, required this.adminID}) : super(key: key);

  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late double totalAmountEarned = 0.0;
  late List<DocumentSnapshot> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where('adminId', isEqualTo: widget.adminID)
          .get();

      double total = 0.0;
      List<DocumentSnapshot> orderList = [];

      for (var doc in snapshot.docs) {
        double price =
            double.tryParse(doc['totalPrice']?.toString() ?? '0') ?? 0.0;
        total += price;
        orderList.add(doc);
      }

      setState(() {
        orders = orderList;
        totalAmountEarned = total;
      });
    } catch (e) {
      print("Error fetching order history: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Amount Earned: ₹${totalAmountEarned.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: orders.isEmpty
                  ? const Center(
                      child: Text('No orders yet.'),
                    )
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        var order = orders[index];
                        return Card(
                          elevation: 5.0,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12.0),
                            title: Text(
                              'Order #${order.id}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'Total: ₹${order['totalPrice']?.toString() ?? '0'}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.teal,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.teal,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailPage(
                                    orderId: order.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
