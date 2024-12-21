import 'package:collegeproject/admin/OrderHistory.dart';
import 'package:flutter/material.dart';
import 'package:collegeproject/admin/add_food.dart';
import 'package:collegeproject/admin/inventory.dart';
import 'package:collegeproject/admin/pending_orders.dart';

class HomeAdmin extends StatelessWidget {
  final String adminID;

  const HomeAdmin(
      {super.key,
      required this.adminID}); // Receive adminID from the login page

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Color(0xFF373866),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Home Admin",
          style: TextStyle(
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Title Text
              const Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Add Food Button
              _buildAdminButton(
                context,
                icon: Icons.add_circle_outline,
                label: 'Add Food Items',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddFood(adminID: adminID),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),

              // Inventory Management Button
              _buildAdminButton(
                context,
                icon: Icons.inventory,
                label: 'Inventory Management',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InventoryPage(adminID: adminID),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),

              // Pending Orders Button
              _buildAdminButton(
                context,
                icon: Icons.pending_actions,
                label: 'Pending Orders',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PendingOrders(),
                    ),
                  );
                },
              ),
              _buildAdminButton(
                context,
                icon: Icons.history,
                label: 'Order History',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderHistoryPage(adminID: adminID),
                    ),
                  );
                },
              ),
              // Additional button (Analytics)
              // _buildAdminButton(
              //   context,
              //   icon: Icons.analytics,
              //   label: 'Analytics',
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => Analytics(adminID: adminID),
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom method to build the admin buttons with icons and text
  Widget _buildAdminButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        tileColor: Colors.white,
        leading: Icon(
          icon,
          size: 30,
          color: Colors.teal.shade700,
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        onTap: onPressed,
      ),
    );
  }
}
