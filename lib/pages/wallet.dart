import 'package:collegeproject/pages/cart_provider.dart';
import 'package:collegeproject/pages/ratings_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: Wallet()));
}

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  final TextEditingController _transactionIdController =
      TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _uid;
  bool _isPaid = false;
  int _totalAmount = 0;
  String? _adminId;

  @override
  void initState() {
    super.initState();
    _getUserUid();
  }

  Future<void> _getUserUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _uid = user.uid;
      });
      _calculateTotalAmount(); // Fetch total amount after UID is set
      _getAdminId();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
    }
  }

  // Calculate total amount based on the user's cart items
  Future<void> _calculateTotalAmount() async {
    if (_uid != null) {
      try {
        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(_uid)
            .collection('cart') // Reference the 'cart' collection
            .get();

        int total = 0;
        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Safely parse price and quantity
          int price = int.tryParse(data['Price']?.toString() ?? "0") ?? 0;
          int quantity = int.tryParse(data['Quantity']?.toString() ?? "1") ?? 1;

          total += price * quantity;

          // Debugging print statements
          print("Item: ${data['Name']}, Price: $price, Quantity: $quantity");
        }

        setState(() {
          _totalAmount = total; // Update total amount
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error calculating total: $e')),
        );
      }
    }
  }

  Future<void> _getAdminId() async {
    if (_uid != null) {
      try {
        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(_uid)
            .collection('cart')
            .limit(1) // Assuming there's at least one item in the cart
            .get();

        if (snapshot.docs.isNotEmpty) {
          setState(() {
            _adminId = snapshot
                .docs.first['adminId']; // Get adminId from the first cart item
          });
        }
      } catch (e) {
        print('Error fetching adminId: $e');
      }
    }
  }

  void _simulatePayment() {
    setState(() {
      _isPaid = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Payment successful! Please enter the transaction ID.')),
    );
  }

  Future<void> _addTransactionIdAndOrder() async {
    String transactionId = _transactionIdController.text.trim();

    if (transactionId.isNotEmpty && _uid != null) {
      try {
        await _firestore
            .collection('users')
            .doc(_uid)
            .collection('transactions')
            .add({
          'transactionId': transactionId,
          'createdAt': FieldValue.serverTimestamp(),
          'adminId': _adminId,
        });

        // Calculate total amount for the order
        int totalPrice = _totalAmount;

        // Create a new order ID, could be a custom string or auto-generated
        String orderId = _firestore.collection('Orders').doc().id;

        // Save the cart as an order
        QuerySnapshot cartSnapshot = await _firestore
            .collection('users')
            .doc(_uid)
            .collection('cart')
            .get();
        List<Map<String, dynamic>> orderItems = [];

        for (var doc in cartSnapshot.docs) {
          Map<String, dynamic> item = doc.data() as Map<String, dynamic>;

          // Safely parse price and quantity
          int price = int.tryParse(item['Price']!.toString()) ?? 0;
          int quantity = int.tryParse(item['Quantity']!.toString() ?? "1") ?? 1;

          orderItems.add({
            'itemName': item['Name'],
            'price': price,
            'quantity': quantity,
          });

          await _firestore
              .collection('users')
              .doc(_uid)
              .collection('orders')
              .add({
            'transactionId': transactionId,
            'itemName': item['Name'],
            'price': price,
            'quantity': quantity,
            'createdAt': FieldValue.serverTimestamp(),
            'adminId': _adminId,
            'orderId': orderId,
          });
        }
        // Add order details to the "Orders" collection with total price and adminId
        await _firestore.collection('Orders').doc(orderId).set({
          'orderId': orderId,
          'transactionId': transactionId,
          'totalPrice': totalPrice,
          'adminId': _adminId,
          'userId': _uid,
          'items': orderItems,
          'createdAt': FieldValue.serverTimestamp(),
        });
        final cartProvider = Provider.of<CartModel>(context, listen: false);
        cartProvider.clearCart();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order details saved successfully!')),
        );

        _transactionIdController.clear();
        setState(() {
          _isPaid = false;
        });

        // Navigate to the RatingPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RatingPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User UID not found')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid transaction ID')),
      );
    }
  }

  // Future<void> _clearCart() async {
  //   if (_uid != null) {
  //     try {
  //       QuerySnapshot cartSnapshot = await _firestore
  //           .collection('users')
  //           .doc(_uid)
  //           .collection('cart')
  //           .get();

  //       for (var doc in cartSnapshot.docs) {
  //         await doc.reference.delete();
  //       }

  //       // Optionally update the UI here
  //       setState(() {
  //         _totalAmount = 0;
  //       });

  //       print("Cart cleared!");
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error clearing cart: $e')),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Wallet",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          automaticallyImplyLeading: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Amount: ₹$_totalAmount",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              width: 250,
              child: Image.asset('images/qr.jpg'),
            ),
            const Text(
              "Scan and Pay",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _simulatePayment,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text('Scan and Pay'),
            ),
            const SizedBox(height: 20),
            if (_isPaid) ...[
              TextField(
                controller: _transactionIdController,
                decoration: const InputDecoration(
                  labelText: 'Enter Transaction ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTransactionIdAndOrder,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('Submit Transaction ID'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
