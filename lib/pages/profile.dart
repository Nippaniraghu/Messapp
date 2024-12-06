import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Dummy data
  String? profile = "https://via.placeholder.com/150"; // Placeholder image
  String? name = "Shivam Gupta"; // Dummy name
  String? email = "shivam@gmail.com"; // Dummy email

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      selectedImage = File(image.path);
      setState(() {
        uploadItem();
      });
    }
  }

  uploadItem() async {
    if (selectedImage != null) {
      // Simulating upload
      String addId = randomAlphaNumeric(10);
      profile = "UploadedImage_$addId"; // Simulated uploaded image URL

      // Updating profile picture
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: name == null
          ? const CircularProgressIndicator()
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
                                    ? Image.network(
                                        profile!,
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
                  _buildProfileItem(
                      Icons.description, "Terms and Condition", ""),
                  const SizedBox(height: 30.0),
                  GestureDetector(
                    onTap: () {
                      // Simulated account deletion
                      setState(() {
                        name = null;
                        email = null;
                        profile = null;
                      });
                    },
                    child:
                        _buildProfileItem(Icons.delete, "Delete Account", ""),
                  ),
                  const SizedBox(height: 30.0),
                  GestureDetector(
                    onTap: () {
                      // Simulated logout action
                      setState(() {
                        name = "Logged Out User";
                        email = "shivam@gmail.com";
                        profile = "https://via.placeholder.com/150";
                      });
                    },
                    child: _buildProfileItem(Icons.logout, "LogOut", ""),
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
