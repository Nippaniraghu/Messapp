import 'dart:io'; // Import dart:io to use File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'order_history.dart'; // Import OrderHistory Page

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? profile = "https://via.placeholder.com/150"; // Placeholder image
  String? name = "Loading..."; // Default name while loading
  String? email = "Loading..."; // Default email while loading

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    loadUserDetails(); // Load user details when the profile page is initialized
  }

  // Method to load user details from Firestore using UID
  void loadUserDetails() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          name = 'Guest User';
          email = 'Not Logged In';
          profile = 'https://via.placeholder.com/150'; // Default placeholder
        });
        return;
      }

      String userId = user.uid;

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!snapshot.exists) {
        setState(() {
          name = 'Unknown User';
          email = 'No Email';
          profile = 'https://via.placeholder.com/150'; // Default placeholder
        });
        return;
      }

      Map<String, dynamic>? userData = snapshot.data() as Map<String, dynamic>?;

      setState(() {
        name = userData?['name'] ?? 'Unknown User';
        email = userData?['email'] ?? 'No Email';
        profile = userData?['profile'] ??
            'https://media.istockphoto.com/id/1495088043/vector/user-profile-icon-avatar-or-person-icon-profile-picture-portrait-symbol-default-portrait.jpg?s=612x612&w=0&k=20&c=dhV2p1JwmloBTOaGAtaA3AW1KSnjsdMt7-U_3EZElZ0='; // Default placeholder
      });
    } catch (e) {
      print('Error loading user details: $e');
      setState(() {
        name = 'Error Loading User';
        email = 'Error Loading Email';
        profile = 'https://via.placeholder.com/150'; // Default placeholder
      });
    }
  }

  // Method to pick an image from the gallery
  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      selectedImage = File(image.path);
      setState(() {
        uploadItem();
      });
    }
  }

  // Simulate upload of image (this would typically be handled with Firebase Storage)
  uploadItem() async {
    if (selectedImage != null) {
      String addId = randomAlphaNumeric(10);
      profile = "UploadedImage_$addId"; // Simulated uploaded image URL

      setState(() {});
    }
  }

  // Method to handle logout
  Future<void> handleLogout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(
        context, '/login'); // Navigate to login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: name == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                            top: 45.0, left: 20.0, right: 20.0),
                        height: MediaQuery.of(context).size.height / 4.3,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.elliptical(
                                MediaQuery.of(context).size.width, 105.0),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 6.5),
                          child: Material(
                            elevation: 10.0,
                            borderRadius: BorderRadius.circular(60),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: GestureDetector(
                                onTap: getImage,
                                child: selectedImage == null
                                    ? FadeInImage.assetNetwork(
                                        placeholder: 'images/placeholder.png',
                                        image: profile!,
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        selectedImage!,
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 70.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 23.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  _buildProfileItem(Icons.person, "Name", name!),
                  const SizedBox(height: 30.0),
                  _buildProfileItem(Icons.email, "Email", email!),
                  const SizedBox(height: 30.0),
                  GestureDetector(
                    onTap: () {
                      // Show Order History Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OrderHistory()),
                      );
                    },
                    child:
                        _buildProfileItem(Icons.history, "Order History", ""),
                  ),
                  const SizedBox(height: 30.0),
                  GestureDetector(
                    onTap: handleLogout, // Handle logout
                    child: _buildProfileItem(Icons.logout, "Logout", ""),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 2.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (value.isNotEmpty)
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
