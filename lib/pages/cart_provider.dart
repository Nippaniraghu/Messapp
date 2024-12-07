// cart_model.dart
import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  final List<Map<String, String>> _items = [];

  List<Map<String, String>> get items => _items;

  void addItem(Map<String, String> item) {
    _items.add(item);
    notifyListeners(); // Notify listeners that the state has changed.
  }

  void removeItem(Map<String, String> item) {
    _items.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
