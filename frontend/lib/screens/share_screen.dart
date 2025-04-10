import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/main.dart';
import 'package:frontend/screens/homepage.dart';
import 'package:frontend/screens/design.dart';
import 'package:frontend/screens/community_screen.dart';
import 'package:frontend/screens/jwtDecodeService.dart';

class SharePage extends StatefulWidget {
  const SharePage({Key? key}) : super(key: key);

  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final JwtService _jwtService = JwtService(); // JWT Service for retrieving userID & token
  bool _isUploading = false;

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // Function to upload the image with JWT token authentication
  Future<void> _captureImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  // Upload image
  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      _showMessage("Please select an image first.");
      return;
    }

    setState(() => _isUploading = true);

    try {
      final int? userID = await _jwtService.getUserID();                        // Fetch logged-in user ID
      final String? token = await _jwtService.storage.read(key: "jwt_token");   // Get JWT token

      if (userID == null || token == null) {
        _showMessage("Authentication failed. Please log in again.");
        return;
      }

      final String apiUrl = "$URL/api/posts/upload";
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers['Authorization'] = "Bearer $token"                            // Send JWT token in the headers
        ..fields['userID'] = userID.toString()
        ..files.add(await http.MultipartFile.fromPath('imagePath', _selectedImage!.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        _showMessage("Photo shared successfully!");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CommunityPage()));
      } else {
        _showMessage("Failed to share photo. Error ${response.statusCode}");
      }
    } catch (e) {
      _showMessage("Error sharing photo. Please try again.");
      print("Upload error: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.center)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B98A9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B98A9),
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: canvaImage('back_arrow.png', width: 50, height: 50),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Connect me!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Chewy',
            ),
          ),
          const SizedBox(height: 16),

          // Image container
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: const Color(0xFFF6D9A6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _selectedImage == null
                  ? const Center(
                      child: Text(
                        'Tap to upload your photo',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontFamily: 'Chewy',
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),

          // Take a Photo button
          TextButton.icon(
            onPressed: _captureImage,
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: const Text(
              'Take a Photo',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Chewy',
                color: Colors.white,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF336A84),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
          ),
          const SizedBox(height: 16),

          // Disclaimer Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'By uploading a photo, you consent to its use on this platform and agree that it does not contain explicit or inappropriate content. Failure to comply may result in the removal of the photo and potential restrictions on your account.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontFamily: 'Chewy',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Share button
          ElevatedButton(
            onPressed: _isUploading ? null : _uploadImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF336A84),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
            ),
            child: _isUploading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'share my photo',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Chewy',
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
