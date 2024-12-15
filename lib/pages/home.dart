import 'package:flutter/material.dart';
import 'package:collegeproject/pages/page1.dart'; // Import GIT page
import 'package:collegeproject/pages/pages2.dart'; // Import Durga page
import 'package:collegeproject/pages/pages3.dart'; // Import Shabari page
import 'package:collegeproject/pages/login.dart'; // Import Login page for logout
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeproject/widget/widget_support.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];
  List<Map<String, dynamic>> _items = [];
  String _userName = "Guest";

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
    _fetchUserName();
  }

  Future<void> _fetchMenuItems() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .doc('git')
          .collection('menu')
          .get();

      List<Map<String, dynamic>> items = snapshot.docs.map((doc) {
        return {
          'name': doc['Name'],
          'description': doc['Detail'],
          'price': double.tryParse(doc['Price'].toString()) ?? 0.0,
          'image': doc['Image'],
        };
      }).toList();

      setState(() {
        _items = items;
        _filteredItems = items;
      });
    } catch (e) {
      print("Error fetching menu items: $e");
    }
  }

  Future<void> _fetchUserName() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        setState(() {
          _userName = userDoc['name'] ?? currentUser.displayName ?? "Guest";
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  void _searchItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _items;
      } else {
        _filteredItems = _items
            .where((item) =>
                item['name'].toLowerCase().contains(query.toLowerCase()) ||
                item['description'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onMenuOptionSelected(String value) {
    if (value == "Logout") {
      _signOut();
    } else if (value == "GIT") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Pages1()),
      );
    } else if (value == "Durga") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Pages2()),
      );
    } else if (value == "Shabari") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Pages3()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$value selected")),
      );
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LogIn()),
    );
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
            const PopupMenuItem<String>(
              value: "Logout",
              child: Text("Logout"),
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
        title: Text(
          "Welcome, $_userName!",
          style: AppWidget.semiBoldTextFeildStyle(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: _buildHamburgerIcon(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: _signOut, // Logout functionality
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                decoration: BoxDecoration(
                  color: Colors.red, // Background color
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white, // Text color
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Text size
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              Text("Food Explorer", style: AppWidget.HeadlineTextFeildStyle()),
              Text("Find Your Favorite Dishes From College Mess",
                  style: AppWidget.LightTextFeildStyle()),
              const SizedBox(height: 20.0),
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
              ..._filteredItems.map((item) => GestureDetector(
                    onTap: () {
                      // Navigate to details or further handling
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
                                item['image'],
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 20.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'],
                                        style:
                                            AppWidget.semiBoldTextFeildStyle(),
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 5.0),
                                    Text(item['description'],
                                        style: AppWidget.LightTextFeildStyle()),
                                    const SizedBox(height: 5.0),
                                    Text("₹ ${item['price']}",
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
