import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeproject/pages/page1.dart';
import 'package:collegeproject/pages/pages2.dart';
import 'package:flutter/material.dart';
import 'package:collegeproject/pages/details.dart';
import 'package:collegeproject/widget/widget_support.dart';

class Pages3 extends StatefulWidget {
  const Pages3({super.key});

  @override
  State<Pages3> createState() => _Pages3State();
}

class _Pages3State extends State<Pages3> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredItems = [];
  List<Map<String, String>> _items = [];

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
          .doc('shabari')
          .collection('menu') // Your Firestore collection name
          .get();

      List<Map<String, String>> items = [];
      for (var doc in snapshot.docs) {
        // Assuming the document has fields 'name', 'description', 'price', and 'image'
        Map<String, String> item = {
          'name': doc['Name'],
          'description': doc['Detail'],
          'price': doc['Price'],
          'image': doc['Image'], // You may need to store the image URL here
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
    if (value == "GIT") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Pages1(), // Navigate to Pages1
        ),
      );
    } else if (value == "Durga") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Pages2(), // Navigate to Pages3
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$value selected")),
      );
    }
    // Add logic for specific option selection here if needed.
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
              child: Text("GIT"),
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
        title: const Text("Welcome to Shabari Mess"),
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
                            price: item["price"]!,
                            imagePath: item["image"]!,
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
                                    Text(item["price"]!,
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
