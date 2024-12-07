import 'package:collegeproject/pages/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:collegeproject/pages/details.dart';
import 'package:collegeproject/pages/page1.dart';
import 'package:collegeproject/pages/pages2.dart';
import 'package:collegeproject/pages/pages3.dart';
import 'package:provider/provider.dart';
import 'package:collegeproject/pages/cart_provider.dart';
import 'package:collegeproject/widget/widget_support.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _items = [
    {
      "name": "Veggie Taco Hash",
      "description": "Fresh and Healthy",
      "price": "\$25",
      "image": "images/burger.png"
    },
    {
      "name": "Mix Veg Salad",
      "description": "Spicy with Onion",
      "price": "\$28",
      "image": "images/salad4.png"
    },
    {
      "name": "Mediterranean Chickpea Salad",
      "description": "Honey goat cheese",
      "price": "\$28",
      "image": "images/salad4.png"
    },
    {
      "name": "Veggie Taco Hash",
      "description": "Honey goat cheese",
      "price": "\$28",
      "image": "images/salad2.png"
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
    if (value == "GIT") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Pages1(), // Navigate to Page1
        ),
      );
    } else if (value == "Durga") {
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
        title: const Text("Welcome!"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/order'); // Navigate to cart
            },
          ),
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
              Text("Delicious Food", style: AppWidget.HeadlineTextFeildStyle()),
              Text("Discover and Get Great Food",
                  style: AppWidget.LightTextFeildStyle()),
              const SizedBox(height: 20.0),
              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: _searchItems,
                decoration: InputDecoration(
                  hintText: "Search for food...",
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
                          builder: (context) => Details(item: item),
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
                                    const SizedBox(height: 10.0),
                                    ElevatedButton(
                                      onPressed: () {
                                        Provider.of<CartModel>(context,
                                                listen: false)
                                            .addItem(item);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  '${item["name"]} added to cart!')),
                                        );
                                      },
                                      child: const Text("Add to Cart"),
                                    ),
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
