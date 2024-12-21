import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];
  late String _userId; // User ID to uniquely identify the user

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Function? onErrorCallback; // Callback for error handling
  Function? onSuccessCallback; // Callback for success message
  bool isOperationSuccessful = true;

  // Constructor that retrieves the userId directly from FirebaseAuth
  CartModel() {
    _getUserId(); // Fetch the userId during initialization
  }

  List<Map<String, dynamic>> get items => _items;

  // Function to get the UID from FirebaseAuth
  Future<void> _getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      await fetchCartFromFirestore(); // Fetch cart items after getting the UID
    } else {
      print("User not logged in.");
    }
  }

  // Add item to cart and save to Firestore
  void addItem(Map<String, dynamic> item) {
    isOperationSuccessful = true;
    // Check if the item has the same adminid as items already in the cart
    if (_items.isEmpty) {
      _items.add(item); // If cart is empty, add the item
      notifyListeners();
      _saveItemToFirestore(item);
    } else {
      // Check if all existing items in the cart have the same adminid
      bool canAdd = true;
      for (var cartItem in _items) {
        if (cartItem['adminId'] != item['adminId']) {
          canAdd = false;
          break; // If there's a mismatch in adminid, stop checking
        }
      }

      if (canAdd) {
        _items.add(item); // Add item if adminid is consistent
        notifyListeners();
        _saveItemToFirestore(item);
        if (onSuccessCallback != null && isOperationSuccessful) {
          onSuccessCallback!();
        }
      } else {
        // If the adminid is different, show a message or handle accordingly
        if (onErrorCallback != null) {
          isOperationSuccessful = false;
          onErrorCallback!();
        }
        print("Cannot add item from different admin to cart.");
      }
    }
  }

  // Remove item from cart and save to Firestore
  void removeItem(Map<String, dynamic> item) {
    _items.remove(item);
    notifyListeners();
    _removeItemFromFirestore(item);
  }

  // Clear cart and save to Firebase
  void clearCart() {
    _items.clear();
    notifyListeners();
    _clearCartFromFirestore();
  }

  // Save an item to the user's cart in Firestore
  Future<void> _saveItemToFirestore(Map<String, dynamic> item) async {
    try {
      if (_userId.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('cart')
            .add(item);
      }
    } catch (e) {
      print("Error saving item to Firestore: $e");
    }
  }

  // Remove an item from the user's cart in Firestore
  Future<void> _removeItemFromFirestore(Map<String, dynamic> item) async {
    try {
      if (_userId.isNotEmpty) {
        final querySnapshot = await _firestore
            .collection('users')
            .doc(_userId)
            .collection('cart')
            .where('Name', isEqualTo: item['Name'])
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          await querySnapshot.docs.first.reference.delete();
        }
      }
    } catch (e) {
      print("Error removing item from Firestore: $e");
    }
  }

  // Clear the cart in Firestore
  Future<void> _clearCartFromFirestore() async {
    try {
      if (_userId.isNotEmpty) {
        final cartCollection = await _firestore
            .collection('users')
            .doc(_userId)
            .collection('cart')
            .get();
        for (var doc in cartCollection.docs) {
          await doc.reference.delete(); // Delete each document
        }
      }
    } catch (e) {
      print("Error clearing cart in Firestore: $e");
    }
  }

  // Fetch the cart data from Firestore when the user logs in
  Future<void> fetchCartFromFirestore() async {
    try {
      if (_userId.isNotEmpty) {
        final querySnapshot = await _firestore
            .collection('users')
            .doc(_userId)
            .collection('cart')
            .get();

        _items.clear();
        for (var doc in querySnapshot.docs) {
          _items.add(doc.data());
        }

        notifyListeners();
      }
    } catch (e) {
      print("Error fetching cart from Firestore: $e");
    }
  }
}
