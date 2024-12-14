import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  runApp(const MaterialApp(home: Wallet())); // No need to pass uid
}

class Wallet extends StatefulWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  final TextEditingController _transactionIdController =
      TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _uid; // Store the UID here

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

  // Function to handle adding transaction ID
  Future<void> _addTransactionId() async {
    String transactionId = _transactionIdController.text.trim();

    // Check if the transactionId is not empty and UID is available
    if (transactionId.isNotEmpty && _uid != null) {
      try {
        // Reference the 'transactions' sub-collection inside the user's document
        await _firestore
            .collection('users') // Main collection
            .doc(_uid) // User document
            .collection('transactions') // Sub-collection
            .add({
          'transactionId': transactionId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Transaction ID added successfully: $transactionId')),
        );

        // Clear input field
        _transactionIdController.clear();
      } catch (e) {
        // Handle any other errors (including Firebase exceptions)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User UID not found')),
      );
    } else {
      // Show validation error if transaction ID is empty
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
            // Display Image Asset with fixed height and width
            Container(
              height: 250,
              width: 250,
              child: Image.asset('images/qr.jpg'),
            ),

            const Text(
              "QR Code",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // TextField for entering transaction ID
            TextField(
              controller: _transactionIdController,
              decoration: const InputDecoration(
                labelText: 'Enter Transaction ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Button to submit transaction ID
            ElevatedButton(
              onPressed: _addTransactionId,
              child: const Text('Submit Transaction ID'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
