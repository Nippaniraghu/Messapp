import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pending_orders.dart'; // Ensure this import points to the PendingOrders file location.

class AddFood extends StatefulWidget {
  final String adminID;
  const AddFood({super.key, required this.adminID});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final List<String> fooditems = ['Ice-cream', 'Burger', 'Salad', 'Pizza'];
  String? value;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController detailcontroller = TextEditingController();
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
    if (selectedImage != null &&
        namecontroller.text.isNotEmpty &&
        pricecontroller.text.isNotEmpty &&
        detailcontroller.text.isNotEmpty) {
      // final price = double.tryParse(pricecontroller.text);
      // if (price == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text("Please enter a valid numerical value for price."),
      //   ));
      //   return;
      // }
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      try {
        String addId = randomAlphaNumeric(10);

        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child("blogImages/$addId");
        final imageBytes = await selectedImage!.readAsBytes();

        UploadTask task = firebaseStorageRef.putData(imageBytes);
        await task;
        SettableMetadata metadata = SettableMetadata(contentType: "image/jpg");
        await firebaseStorageRef.updateMetadata(metadata);

        final downloadUrl = await (await task).ref.getDownloadURL();
        final adminMenuRef = FirebaseFirestore.instance
            .collection("Admin")
            .doc(widget.adminID) // Use the dynamic Admin ID
            .collection("menu");

        Map<String, dynamic> addItem = {
          "Image": downloadUrl,
          "Name": namecontroller.text,
          "Price": pricecontroller.text,
          "Detail": detailcontroller.text,
          "Category": value,
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

  // Function to open a web page
  Future<void> openWebPage(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
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
        actions: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PendingOrders()),
                );
              },
              child: const Text(
                "Orders",
                style: TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
            ),
          ),
        ],
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
                  buildTextField("Item Detail", detailcontroller, maxLines: 6),
                  const SizedBox(height: 20.0),
                  //   const Text(
                  //     "Select Category",
                  //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  //   ),
                  //   const SizedBox(height: 20.0),
                  //   buildDropdown(),
                  //   const SizedBox(height: 30.0),
                  buildButton("Add", uploadItem),
                ],
              ),
            ),
          ),
          Positioned(
            top: 80, // Adjust to move the button slightly down
            right: 20, // Keep the button aligned to the right
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Background color
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                openWebPage(
                    "https://console.firebase.google.com/project/mess-app-ec79e/analytics/app/android:com.example.messapp/overview/reports~2Fdashboard%3Fr%3Dfirebase-overview&fpn%3D433969056606?fb_gclid=Cj0KCQiAgdC6BhCgARIsAPWNWH2i4OTOouzQ33Hafd75EmlEPx5_TrmLZS0a1oalFqfiSxnOg0_rumYaAkXoEALw_wcB");
              },
              icon: const Icon(Icons.analytics_outlined, color: Colors.white),
              label: const Text(
                "Analytics",
                style: TextStyle(fontSize: 16, color: Colors.white),
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

  // Widget buildDropdown() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //     width: MediaQuery.of(context).size.width,
  //     decoration: BoxDecoration(
  //         color: const Color(0xFFececf8),
  //         borderRadius: BorderRadius.circular(10)),
  //     child: DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //         items: fooditems
  //             .map((item) => DropdownMenuItem<String>(
  //                   value: item,
  //                   child: Text(
  //                     item,
  //                     style:
  //                         const TextStyle(fontSize: 18.0, color: Colors.black),
  //                   ),
  //                 ))
  //             .toList(),
  //         onChanged: ((value) => setState(() {
  //               this.value = value;
  //             })),
  //         dropdownColor: Colors.white,
  //         hint: const Text("Select Category"),
  //         iconSize: 36,
  //         icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
  //         value: value,
  //       ),
  //     ),
  //   );
  // }

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
