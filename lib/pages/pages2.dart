import 'package:collegeproject/pages/page1.dart';
import 'package:collegeproject/pages/pages3.dart';
import 'package:flutter/material.dart';
import 'package:collegeproject/pages/details.dart';
import 'package:collegeproject/widget/widget_support.dart';

class Pages2 extends StatefulWidget {
  const Pages2({super.key});

  @override
  State<Pages2> createState() => _Pages2State();
}

class _Pages2State extends State<Pages2> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _items = [
    {
      "name": "Aloo Bhaji",
      "description": "Mildly spiced potato curry, a perfect comfort food.",
      "price": "₹60",
      "image": "images/aalo_bhaji.jpg"
    },
    {
      "name": "Kanda Poha",
      "description":
          "Light and flavorful flattened rice with onions, peanuts, and lemon.",
      "price": "₹50",
      "image": "images/kanda_poha.jpg"
    },
    {
      "name": "Misal Pav",
      "description": "Spicy sprouted lentil curry served with fresh pav bread.",
      "price": "₹70",
      "image": "images/misal_pav.jpg"
    },
    {
      "name": "Dhokla",
      "description":
          "Soft, spongy gram flour cakes topped with mustard seeds and green chilies.",
      "price": "₹40",
      "image": "images/dhokla.jpg"
    },
    {
      "name": "Masala Khichdi",
      "description":
          "Wholesome rice and lentil mixture seasoned with Indian spices.",
      "price": "₹60",
      "image": "images/masala_khichdi.jpg"
    },
    {
      "name": "Batata Vada",
      "description": "Crispy deep-fried potato fritters served with chutney.",
      "price": "₹50",
      "image": "images/batata_vada.jpg"
    },
    {
      "name": "Lemon Rice",
      "description":
          "Tangy rice infused with lemon juice and tempered with mustard seeds.",
      "price": "₹55",
      "image": "images/lemon_rice.jpg"
    },
    {
      "name": "Gulab Jamun",
      "description":
          "Soft, syrup-soaked sweet dumplings for a perfect end to the meal.",
      "price": "₹40",
      "image": "images/gulab_jamun.jpg"
    }
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
          builder: (context) => const Pages1(), // Navigate to Pages1
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
        title: const Text("Welcome to Durga Canteen"),
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
