import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'pending_orders.dart'; // Ensure this import points to the PendingOrders file location.

class AddFood extends StatefulWidget {
  final String adminID; // Receive adminID as a parameter

  const AddFood(
      {super.key, required this.adminID}); // Pass adminID to the constructor

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final List<String> fooditems = ['Ice-cream', 'Burger', 'Salad', 'Pizza'];
  String? value;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController detailcontroller = TextEditingController();
  TextEditingController quantitycontroller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? selectedImage;

  Future getImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedImage = image;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No image selected.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error selecting image: $e")),
      );
    }
  }

  uploadItem() async {
    if (widget.adminID != null &&
        selectedImage != null &&
        namecontroller.text.isNotEmpty &&
        pricecontroller.text.isNotEmpty &&
        detailcontroller.text.isNotEmpty &&
        quantitycontroller.text.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      try {
        String addId = randomAlphaNumeric(10);

        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child("foodImages/$addId");
        final imageBytes = await selectedImage!.readAsBytes();

        UploadTask task = firebaseStorageRef.putData(imageBytes);
        await task;
        SettableMetadata metadata = SettableMetadata(contentType: "image/jpg");
        await firebaseStorageRef.updateMetadata(metadata);

        final downloadUrl = await (await task).ref.getDownloadURL();
        final adminMenuRef = FirebaseFirestore.instance
            .collection("Admin")
            .doc(widget.adminID) // Use the passed adminID
            .collection("menu");

        Map<String, dynamic> addItem = {
          "Image": downloadUrl,
          "Name": namecontroller.text,
          "Price": pricecontroller.text,
          "Detail": detailcontroller.text,
          "Category": value,
          "Quantity": quantitycontroller.text,
        };
        await adminMenuRef.add(addItem);

        Navigator.of(context).pop(); // Close the progress dialog
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Food item added successfully!"),
        ));

        // Clear inputs after successful upload
        setState(() {
          namecontroller.clear();
          pricecontroller.clear();
          detailcontroller.clear();
          quantitycontroller.clear();
          selectedImage = null;
          value = null;
        });
      } catch (e) {
        Navigator.of(context).pop(); // Close the progress dialog
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error uploading item: $e"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill in all fields and select an image."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Color(0xFF373866),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Add Item",
          style: TextStyle(
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 20.0, bottom: 50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Upload the Item Picture",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 20.0),
                  selectedImage == null
                      ? GestureDetector(
                          onTap: () {
                            getImage();
                          },
                          child: Center(
                            child: Material(
                              elevation: 4.0,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black, width: 1.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 1.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  selectedImage!.path,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 30.0),
                  buildTextField("Item Name", namecontroller),
                  const SizedBox(height: 30.0),
                  buildTextField("Item Price", pricecontroller),
                  const SizedBox(height: 30.0),
                  buildTextField("Item Quantity", quantitycontroller),
                  const SizedBox(height: 30.0),
                  buildTextField("Item Detail", detailcontroller, maxLines: 6),
                  const SizedBox(height: 20.0),
                  buildButton("Add", uploadItem),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for UI components
  Widget buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: const Color(0xFFececf8),
              borderRadius: BorderRadius.circular(10)),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Enter $label",
            ),
          ),
        ),
      ],
    );
  }

  Widget buildButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Center(
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            width: 150,
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
