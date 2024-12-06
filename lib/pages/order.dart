import 'package:flutter/material.dart';
import 'package:collegeproject/widget/widget_support.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderPageState();
}

class _OrderPageState extends State<Order> {
  int totalPrice = 0;
  int finalAmount = 0;

  // Dummy cart data
  final List<Map<String, String>> dummyCart = [
    {
      "Name": "Veg Thali",
      "Quantity": "2",
      "Image": "https://via.placeholder.com/90",
      "Total": "20"
    },
    {
      "Name": "Curd Rice",
      "Quantity": "1",
      "Image": "https://via.placeholder.com/90",
      "Total": "10"
    },
    {
      "Name": "Pasta",
      "Quantity": "3",
      "Image": "https://via.placeholder.com/90",
      "Total": "30"
    },
  ];

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  void _calculateTotal() {
    totalPrice = dummyCart.fold(
      0,
      (sum, item) => sum + int.parse(item["Total"]!),
    );
    finalAmount = totalPrice;
  }

  Widget _buildCartItem(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                height: 90,
                width: 40,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text(item["Quantity"]!)),
              ),
              const SizedBox(width: 20.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.network(
                  item["Image"]!,
                  height: 90,
                  width: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["Name"]!,
                    style: AppWidget.semiBoldTextFeildStyle(),
                  ),
                  Text(
                    "\$${item["Total"]}",
                    style: AppWidget.semiBoldTextFeildStyle(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodCart() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: dummyCart.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return _buildCartItem(dummyCart[index]);
      },
    );
  }

  void _handleCheckout() {
    setState(() {
      totalPrice = 0;
      finalAmount = 0;
      dummyCart.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Checkout successful!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Cart"),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFoodCart(),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Price",
                    style: AppWidget.boldTextFeildStyle(),
                  ),
                  Text(
                    "\$$totalPrice",
                    style: AppWidget.semiBoldTextFeildStyle(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: _handleCheckout,
              child: Container(
                margin: const EdgeInsets.all(20.0),
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    "CheckOut",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
