import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'page_home.dart';
import '../models/data.dart'; // Import the data file

final double imageSizeOfButton = 200.0;
final double dynamicVerticalPadding = imageSizeOfButton * 0.05;

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  File? _profileImage;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Load profile image and user data
  void _loadProfileData() {
    if (userProfileImagePath != null && File(userProfileImagePath!).existsSync()) {
      _profileImage = File(userProfileImagePath!);
    }
    _nameController.text = userName;
    _bioController.text = userBio;
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        userProfileImagePath = pickedFile.path; // Save in data.dart
      });
    }
  }

  // Open the Edit Profile Dialog
  void _openEditProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF5E92A8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: const Text(
            "Edit Profile",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Chewy", fontSize: 20.0, color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name Input Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _bioController,
                minLines: 3, // Minimum height (3 lines)
                maxLines: 5, // Allows expansion up to 5 lines
                decoration: InputDecoration(
                  labelText: "Bio",
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0), // More space inside
                ),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 50),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    userName = _nameController.text;
                    userBio = _bioController.text;
                  });
                  Navigator.of(context).pop(); // Close dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontFamily: "Chewy", fontSize: 16.0, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF336B89),
      body: SafeArea(
        child: Column(
          children: [
            // -- START of Back Button & Edit Profile Button --
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  RawMaterialButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    fillColor: const Color(0xFF5E92A8),
                    constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                    shape: const CircleBorder(),
                    child: Image.asset('assets/buttons/back_arrow.png', width: 40, height: 40),
                  ),

                  // Edit Profile Button
                  ElevatedButton(
                    onPressed: _openEditProfileDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E92A8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(fontFamily: "Chewy", fontSize: 12.0, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            // -- END of Back Button & Edit Profile Button --

            const SizedBox(height: 20),

            // -- START of Profile Picture Section --
            GestureDetector(
              onTap: _pickImage, // Allow user to change profile picture
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/buttons/profile_icon_background.png',
                    width: imageSizeOfButton,
                    height: imageSizeOfButton,
                  ),
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white,
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? const Icon(Icons.camera_alt, size: 60, color: Colors.grey)
                        : null,
                  ),
                ],
              ),
            ),
            // -- END of Profile Picture Section --

            const SizedBox(height: 20),

            // -- START of User's Name & Bio Display --
            Text(
              userName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Chewy',
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              userBio,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'VarelaRound',
                fontSize: 14.0,
                color: Colors.white,
              ),
            ),
            // -- END of User's Name & Bio Display --

            const SizedBox(height: 10),

            // -- START of User Activity Sections --
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildProfileSection("Cooking Streaks & Achievements", "assets/buttons/profile_streaks.png", [
                    "🔥 5-Day Cooking Streak!",
                    "🏅 Completed 10 Recipes",
                    "⭐ First Community Post",
                  ]),
                  const SizedBox(height: 10),
                  _buildProfileSection("Completed Recipes", "assets/buttons/profile_recipes.png", [
                    "🥘 Classic Chicken Mushroom Risotto",
                    "🍛 Spicy Thai Basil Chicken",
                    "🍜 Homemade Ramen Noodles",
                  ]),
                  const SizedBox(height: 10),
                  _buildProfileSection("Community Contributions", "assets/buttons/profile_community.png", [
                    "📢 Shared 3 Recipes",
                    "💬 Commented on 5 Posts",
                    "🎉 Earned 'Community Helper' Badge",
                  ]),
                ],
              ),
            ),
            // -- END of User Activity Sections --
          ],
        ),
      ),
    );
  }

  // Widget to Build Sections Dynamically
  Widget _buildProfileSection(String title, String iconPath, List<String> items) {
    return Card(
      color: const Color(0xFF5E92A8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5.0),
            Row(
              children: [
                Image.asset(iconPath, width: 24, height: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontFamily: 'Chewy', fontSize: 18.0, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 7.5),
            ...items.map((item) => Text(item, style: const TextStyle(color: Colors.white))),
            const SizedBox(height: 7.5),
          ],
        ),
      ),
    );
  }
}
