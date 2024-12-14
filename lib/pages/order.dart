import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collegeproject/widget/widget_support.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
import 'package:collegeproject/pages/cart_provider.dart'; // Import your CartModel

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderPageState();
}

class _OrderPageState extends State<Order> {
  int totalPrice = 0;

  @override
  void initState() {
    super.initState();
    // No need to calculate total here, as we will use the CartModel to calculate it dynamically.
  }

  void _calculateTotal(List<Map<String, dynamic>> cartItems) {
    totalPrice = cartItems.fold(
      0,
      (sum, item) {
        int price = item["Price"] is int
            ? item["Price"]
            : int.tryParse(item["Price"].toString()) ?? 0;
        int quantity = item["Quantity"] is int
            ? item["Quantity"]
            : int.tryParse(item["Quantity"].toString()) ?? 0;
        return sum + (price * quantity);
      },
    );
  }

  void _increaseQuantity(int index, List<Map<String, dynamic>> cartItems) {
    setState(() {
      cartItems[index]["Quantity"] = (cartItems[index]["Quantity"] as int) + 1;
      _calculateTotal(cartItems);
    });
  }

  void _decreaseQuantity(int index, List<Map<String, dynamic>> cartItems) {
    setState(() {
      int currentQuantity = cartItems[index]["Quantity"] as int;
      if (currentQuantity > 1) {
        cartItems[index]["Quantity"] =
            currentQuantity - 1; // Decrement quantity
        _calculateTotal(cartItems);
      }
    });
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index,
      List<Map<String, dynamic>> cartItems) {
    int price = item["Price"] is int
        ? item["Price"]
        : int.tryParse(item["Price"].toString()) ?? 0;
    int quantity = item["Quantity"] is int
        ? item["Quantity"]
        : int.tryParse(item["Quantity"].toString()) ?? 0;
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
                child: Image.network(
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
                      "Price: \$${price.toString()}",
                      style: AppWidget.LightTextFeildStyle(),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      "Subtotal: \$${(price * quantity).toString()}",
                      style: AppWidget.semiBoldTextFeildStyle(),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _decreaseQuantity(index, cartItems),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    item["Quantity"].toString(),
                    style: AppWidget.boldTextFeildStyle(),
                  ),
                  IconButton(
                    onPressed: () => _increaseQuantity(index, cartItems),
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

  Widget _buildFoodCart(List<Map<String, dynamic>> cartItems) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: cartItems.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return _buildCartItem(cartItems[index], index, cartItems);
      },
    );
  }

  void _handleCheckout(List<Map<String, dynamic>> cartItems) {
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
        clientId: "YOUR_PAYPAL_CLIENT_ID",
        secretKey: "YOUR_PAYPAL_SECRET_KEY",
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
              "items": cartItems.map((item) {
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
            cartItems.clear();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        _calculateTotal(cart.items); // Recalculate total dynamically
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
                  child: cart.items.isNotEmpty
                      ? _buildFoodCart(cart.items)
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
                  onTap: () => _handleCheckout(cart.items),
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
      },
    );
  }
}
