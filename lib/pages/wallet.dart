import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          int price = data['price'] ?? 0;
          int quantity = data['quantity'] ?? 1;
          total += price * quantity;
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
        });

        // Save the cart as an order
        QuerySnapshot cartSnapshot = await _firestore
            .collection('users')
            .doc(_uid)
            .collection('cart')
            .get();

        for (var doc in cartSnapshot.docs) {
          Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
          await _firestore
              .collection('users')
              .doc(_uid)
              .collection(
                  'orders') // Save order items in 'orders' subcollection
              .add({
            'transactionId': transactionId,
            'itemName': item['Name'],
            'price': item['Price'],
            'quantity': item['Quantity'],
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order details saved successfully!')),
        );

        _transactionIdController.clear();
        setState(() {
          _isPaid = false;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet"),
        backgroundColor: Colors.black,
      ),
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
