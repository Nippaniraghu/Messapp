import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeleteItems extends StatefulWidget {
  final String adminID; // Receive adminID to filter items by admin

  const DeleteItems({super.key, required this.adminID});

  @override
  _DeleteItemsState createState() => _DeleteItemsState();
}

class _DeleteItemsState extends State<DeleteItems> {
  late Future<List<DocumentSnapshot>> items;

  // Fetch the items from Firestore
  Future<List<DocumentSnapshot>> fetchItems() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Admin")
        .doc(widget.adminID)
        .collection("menu")
        .get();
    return querySnapshot.docs;
  }

  // Delete an item
  Future<void> deleteItem(String itemId) async {
    try {
      await FirebaseFirestore.instance
          .collection("Admin")
          .doc(widget.adminID)
          .collection("menu")
          .doc(itemId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Item deleted successfully!"),
      ));
      setState(() {
        items = fetchItems(); // Refresh the item list
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error deleting item: $e"),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    items = fetchItems(); // Fetch items when the page is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delete Items"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.data!.isEmpty) {
            return const Center(child: Text("No items found"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var item = snapshot.data![index];
                return ListTile(
                  leading: Image.network(item["Image"]),
                  title: Text(item["Name"]),
                  subtitle: Text("Price: ${item["Price"]}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteItem(item.id),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
