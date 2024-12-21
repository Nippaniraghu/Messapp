import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key, required String adminID});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController targetController = TextEditingController();

  List<Map<String, dynamic>> inventory = [];
  bool isLowStock = false;

  // Add an item to the inventory
  void addInventoryItem() {
    String name = nameController.text.trim();
    double quantity = double.tryParse(quantityController.text.trim()) ?? 0.0;
    double target = double.tryParse(targetController.text.trim()) ?? 0.0;

    // Ensure inputs are valid
    if (name.isNotEmpty && quantity > 0 && target > 0) {
      setState(() {
        inventory.add({
          'name': name,
          'quantity': quantity,
          'target': target,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name added successfully!')),
      );

      // Clear fields after adding item
      nameController.clear();
      quantityController.clear();
      targetController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid inputs!')),
      );
    }
  }

  // Update stock and check if it's below the target
  void updateStock(int index) {
    String quantityText = quantityController.text.trim();

    if (quantityText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity!')),
      );
      return;
    }

    double newQuantity = double.tryParse(quantityText) ?? 0.0;

    // Validate if the new quantity is positive
    if (newQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be greater than zero!')),
      );
      return;
    }

    setState(() {
      inventory[index]['quantity'] = newQuantity;

      // Check if stock is below target
      isLowStock = newQuantity < inventory[index]['target'];
    });

    quantityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Container(
        // Stylish gradient background
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
              // Input fields to add an item
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity (kg)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: targetController,
                decoration: const InputDecoration(labelText: 'Target (kg)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addInventoryItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Add Item'),
              ),
              const SizedBox(height: 20),
              // Inventory List
              const Text(
                'Inventory List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: inventory.length,
                  itemBuilder: (context, index) {
                    final item = inventory[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 4,
                      child: ListTile(
                        title: Text(
                          item['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Quantity: ${item['quantity']} kg | Target: ${item['target']} kg',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            updateStock(index);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                          ),
                          child: const Text('Update Stock'),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Big Red or Green Button for Stock Status
              inventory.isNotEmpty
                  ? isLowStock
                      ? ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                          ),
                          child: const Text(
                            'ALERT: Low Stock!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                          ),
                          child: const Text(
                            'Stock is Sufficient!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
