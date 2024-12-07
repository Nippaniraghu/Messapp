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
  final List<Map<String, String>> _items = [
    {
      "name": "Fruit Salad",
      "description": "Refreshing and Juicy",
      "price": "\$20",
      "image": "images/burger.png"
    },
    {
      "name": "Greek Salad",
      "description": "Tangy and Crunchy",
      "price": "\$25",
      "image": "images/salad4.png"
    },
    {
      "name": "Avocado Salad",
      "description": "Healthy and Delicious",
      "price": "\$30",
      "image": "images/salad4.png"
    },
    {
      "name": "Caesar Salad",
      "description": "Classic and Creamy",
      "price": "\$22",
      "image": "images/salad4.png"
    },
  ];

  List<Map<String, String>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _items; // Initialize with all items.
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$value selected")),
    );
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
                          builder: (context) => const Details(
                            item: {},
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
                              Image.asset(
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
