import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeproject/pages/details.dart';
import 'package:flutter/material.dart';
import 'package:collegeproject/pages/pages2.dart'; // Import Pages2
import 'package:collegeproject/pages/pages3.dart'; // Import Pages3
import 'package:collegeproject/widget/widget_support.dart';

class Pages1 extends StatefulWidget {
  const Pages1({super.key});

  @override
  State<Pages1> createState() => _Pages1State();
}

class _Pages1State extends State<Pages1> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];
  List<Map<String, dynamic>> _items = [];
  final String adminId = "git";

  @override
  void initState() {
    super.initState();
    _fetchMenuItems(); // Fetch the menu items when the page loads
  }

  void _fetchMenuItems() async {
    try {
      // Fetch the documents from the Firestore collection
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .doc('git')
          .collection('menu') // Your Firestore collection name
          .get();

      List<Map<String, dynamic>> items = [];
      for (var doc in snapshot.docs) {
        double price = double.tryParse(doc['Price'].toString()) ?? 0.0;
        // Assuming the document has fields 'name', 'description', 'price', and 'image'
        Map<String, dynamic> item = {
          'name': doc['Name'],
          'description': doc['Detail'],
          'price': price,
          'image': doc['Image'], // You may need to store the image URL here
          'adminid': adminId,
        };
        items.add(item);
      }

      setState(() {
        _items = items;
        _filteredItems = items; // Initialize filteredItems with all items
      });
    } catch (e) {
      print("Error fetching menu items: $e");
    }
  }

  void _searchItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _items;
      } else {
        _filteredItems = _items
            .where((item) =>
                item["name"]!.toLowerCase().contains(query.toLowerCase()) ||
                item["description"]!
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onMenuOptionSelected(String value) {
    if (value == "Durga") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Pages2(), // Navigate to Pages2
        ),
      );
    } else if (value == "Shabari") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Pages3(), // Navigate to Pages3
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$value selected")),
      );
    }
  }

  Widget _buildHamburgerIcon() {
    return GestureDetector(
      onTapDown: (details) {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
              details.globalPosition.dx, details.globalPosition.dy, 0, 0),
          items: [
            const PopupMenuItem<String>(
              value: "GIT",
              child: Text("College mess"),
            ),
            const PopupMenuItem<String>(
              value: "Durga",
              child: Text("Durga"),
            ),
            const PopupMenuItem<String>(
              value: "Shabari",
              child: Text("Shabari"),
            ),
          ],
        ).then((value) {
          if (value != null) _onMenuOptionSelected(value);
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 5.0,
            width: 30.0,
            color: Colors.black,
            margin: const EdgeInsets.only(bottom: 4.0),
          ),
          Container(
            height: 5.0,
            width: 30.0,
            color: Colors.black,
            margin: const EdgeInsets.only(bottom: 4.0),
          ),
          Container(
            height: 5.0,
            width: 30.0,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("College mess"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: _buildHamburgerIcon(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              Text("Food Explorer", style: AppWidget.HeadlineTextFeildStyle()),
              Text("Find Your Favorite Dishes",
                  style: AppWidget.LightTextFeildStyle()),
              const SizedBox(height: 20.0),
              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: _searchItems,
                decoration: InputDecoration(
                  hintText: "Search for dishes...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              // Display Items
              ..._filteredItems.map((item) => GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Details(
                            name: item["name"]!,
                            description: item["description"]!,
                            price: item["price"].toString(),
                            imagePath: item["image"]!,
                            adminId: adminId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                item["image"]!,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 20.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item["name"]!,
                                        style:
                                            AppWidget.semiBoldTextFeildStyle(),
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 5.0),
                                    Text(item["description"]!,
                                        style: AppWidget.LightTextFeildStyle()),
                                    const SizedBox(height: 5.0),
                                    Text("₹ ${item["price"]}",
                                        style:
                                            AppWidget.semiBoldTextFeildStyle()),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
