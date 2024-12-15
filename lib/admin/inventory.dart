import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  final String adminID;

  const InventoryPage({super.key, required this.adminID});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController thresholdController = TextEditingController();

  List<Map<String, dynamic>> inventory = [];

  // Fetch inventory items from Firestore
  Future<void> fetchInventory() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .doc(widget.adminID)
          .collection('inventory')
          .get();

      setState(() {
        inventory = snapshot.docs
            .map((doc) => {
                  'name': doc['name'],
                  'quantity': doc['quantity'],
                  'threshold': doc['threshold'],
                })
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching inventory: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchInventory(); // Load inventory when the page is initialized
  }

  // Add new inventory item to Firestore
  void addInventoryItem() async {
    String name = nameController.text.trim();
    double quantity = double.tryParse(quantityController.text.trim()) ?? 0.0;
    double threshold = double.tryParse(thresholdController.text.trim()) ?? 0.0;

    if (name.isNotEmpty && quantity > 0 && threshold > 0) {
      try {
        // Add the new inventory item to Firestore
        await FirebaseFirestore.instance
            .collection('Admin')
            .doc(widget.adminID)
            .collection('inventory')
            .add({
          'name': name,
          'quantity': quantity,
          'threshold': threshold,
        });

        // Update the local list and show success message
        setState(() {
          inventory.add({
            'name': name,
            'quantity': quantity,
            'threshold': threshold,
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name added successfully!')),
        );

        // Clear input fields after adding item
        nameController.clear();
        quantityController.clear();
        thresholdController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding item: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid inputs!')),
      );
    }
  }

  // Notify if stock is low based on the threshold
  void notifyLowStock(String name, double quantity, double threshold) {
    if (quantity <= threshold) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('ALERT: $name is low on stock! ($quantity kg left)'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$name has sufficient stock. ($quantity kg left)'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventory Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Input Fields with Cards for Better UI
              Card(
                color: Colors.white.withOpacity(0.9),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity (kg)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: thresholdController,
                        decoration: const InputDecoration(
                          labelText: 'Threshold (kg)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Add Item Button
              ElevatedButton(
                onPressed: addInventoryItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Add Item',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 15),

              // Inventory List Header
              const Text(
                'Inventory List',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),

              // Inventory List Display
              Expanded(
                child: ListView.builder(
                  itemCount: inventory.length,
                  itemBuilder: (context, index) {
                    final item = inventory[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(
                          item['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Quantity: ${item['quantity']} kg | Threshold: ${item['threshold']} kg',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            notifyLowStock(item['name'], item['quantity'],
                                item['threshold']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                          ),
                          child: const Text(
                            'Check Stock',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
