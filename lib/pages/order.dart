import 'package:flutter/material.dart';
import 'package:collegeproject/widget/widget_support.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderPageState();
}

class _OrderPageState extends State<Order> {
  int totalPrice = 0;

  // Dummy cart data
  final List<Map<String, dynamic>> dummyCart = [
    {
      "Name": "Veg Thali",
      "Quantity": 1,
      "Image": "images/salad2.png", // Updated image reference
      "Price": 10
    },
    {
      "Name": "Curd Rice",
      "Quantity": 1,
      "Image": "images/salad4.png", // Updated image reference
      "Price": 10
    },
    {
      "Name": "Pasta",
      "Quantity": 1,
      "Image": "images/burger.png", // Updated image reference
      "Price": 15
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
      (sum, item) => sum + (item["Quantity"] as int) * (item["Price"] as int),
    );
  }

  void _increaseQuantity(int index) {
    setState(() {
      dummyCart[index]["Quantity"] += 1;
      _calculateTotal();
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (dummyCart[index]["Quantity"] > 1) {
        dummyCart[index]["Quantity"] -= 1;
        _calculateTotal();
      }
    });
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  item["Image"],
                  height: 90,
                  width: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["Name"],
                      style: AppWidget.semiBoldTextFeildStyle(),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      "Price: \$${item["Price"]}",
                      style: AppWidget.LightTextFeildStyle(),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      "Subtotal: \$${item["Price"] * item["Quantity"]}",
                      style: AppWidget.semiBoldTextFeildStyle(),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _decreaseQuantity(index),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    item["Quantity"].toString(),
                    style: AppWidget.boldTextFeildStyle(),
                  ),
                  IconButton(
                    onPressed: () => _increaseQuantity(index),
                    icon: const Icon(Icons.add_circle_outline),
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
        return _buildCartItem(dummyCart[index], index);
      },
    );
  }

  void _handleCheckout() {
    if (totalPrice == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your cart is empty!")),
      );
      return;
    }

    // Navigate to the PayPal Checkout Page
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => PaypalCheckout(
        sandboxMode: true,
        clientId:
            "ARtTBjurMSX6gL0Hir_lEUTudAZ-bq1zPCeMPQQhvmdQVLQqPhNRsmdz6ckzGD8Xx0ZkG7UDdbpYGRhn",
        secretKey:
            "EBpFs1fuki9cSgqjvYgy1cxuH3NznSrQxBSy0pJPsCWb4sbL1bU8myhir3KcXpyouH5xigqxoTfNqPLf",
        returnURL: "https://xyz123.ngrok.io/success",
        cancelURL: "https://xyz123.ngrok.io/cancel",
        transactions: [
          {
            "amount": {
              "total": totalPrice.toString(),
              "currency": "USD",
              "details": {
                "subtotal": totalPrice.toString(),
                "shipping": '0',
                "shipping_discount": 0,
              }
            },
            "description": "Food Cart Payment",
            "item_list": {
              "items": dummyCart.map((item) {
                return {
                  "name": item["Name"],
                  "quantity": item["Quantity"],
                  "price": item["Price"].toString(),
                  "currency": "USD",
                };
              }).toList(),
            }
          }
        ],
        note: "Thank you for your purchase!",
        onSuccess: (Map params) async {
          print("onSuccess: $params");

          setState(() {
            totalPrice = 0;
            dummyCart.clear();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Checkout successful!")),
          );
        },
        onError: (error) {
          print("onError: $error");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Checkout failed!")),
          );
          Navigator.pop(context);
        },
        onCancel: () {
          print('Cancelled');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Checkout cancelled!")),
          );
        },
      ),
    ));
  }

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("Checkout successful!")),
  //   );
  // }

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
              child: dummyCart.isNotEmpty
                  ? _buildFoodCart()
                  : const Center(
                      child: Text(
                        "Your cart is empty!",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
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
